import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/routes/route_args.dart';
import 'package:reader_nover/util/book_help.dart';
import 'package:reader_nover/util/color_utils.dart';

import '../../app/constants/assets.dart';
import '../../app/database/drift/app_database.dart' as db;
import '../../app/database/models/models.dart';
import '../../app/routes/app_routes.dart';
import '../../app/service/source/source_check_report.dart';
import '../../pages/common/decoded_network_image.dart';
import '../../util/dialog/dialog_utils.dart';
import '../../util/gap.dart';
import 'logic.dart';
import 'state.dart';

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({
    super.key,
    required this.logic,
  });

  final BookSearchLogic logic;

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  BookSearchLogic get logic => widget.logic;
  BookSearchState get state => logic.state;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: state.searchKeyword);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookSearchLogic>(
      init: logic,
      global: false,
      builder: (logic) {
        _syncSearchController();
        return Scaffold(
          appBar: AppBar(
            title: const Text('搜索书籍'),
          ),
          body: Column(
            children: [
              _buildSearchInput(context, logic),
              _buildSearchHistory(context, logic),
              _buildSearchProgress(context),
              const Divider(),
              Expanded(child: _buildSearchResultList(context, logic)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchInput(BuildContext context, BookSearchLogic logic) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final secondaryColor = ColorUtils.getContrastSecondaryTextColor(bgColor);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          textInputAction: TextInputAction.search,
          textAlign: TextAlign.center,
          onSubmitted: (value) async {
            if (value.isNotEmpty) {
              await logic.search(value);
              if (state.bookInfoList.isEmpty && !_hasLoginRequiredSource()) {
                DialogUtils.waring('没有搜索到相关书籍');
              }
            } else {
              DialogUtils.waring('搜索内容不能为空');
            }
          },
          decoration: InputDecoration(
            hintText: '请输入书名或作者名',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            filled: true,
            fillColor: secondaryColor.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  BorderSide(color: secondaryColor.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchProgress(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final secondaryColor = ColorUtils.getContrastSecondaryTextColor(bgColor);

    if (!state.isSearching && state.sourceResults.isEmpty) {
      return const SizedBox.shrink();
    }

    final completed = state.completedSourceCount;
    final total = state.totalSourceCount;
    final resultCount = state.bookInfoList.length;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (state.isSearching) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                const Gap.hs(),
              ],
              Text(
                state.isSearching
                    ? '搜索中 $completed/$total 个书源，已找到 $resultCount 本'
                    : '共搜索 $total 个书源，找到 $resultCount 本',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          if (state.isSearching && total > 0) ...[
            const Gap.vs(),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: total > 0 ? completed / total : 0,
                minHeight: 3,
                backgroundColor: secondaryColor.withValues(alpha: 0.12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResultList(BuildContext context, BookSearchLogic logic) {
    final loginRequiredResults =
        state.sourceResults.values.where((result) => result.loginRequired);
    final failedResults = state.sourceResults.values
        .where(
          (result) =>
              !result.isLoading &&
              !result.loginRequired &&
              (result.error?.trim().isNotEmpty ?? false),
        )
        .toList(growable: false);

    if (state.bookInfoList.isEmpty &&
        loginRequiredResults.isEmpty &&
        failedResults.isEmpty) {
      return const SizedBox.shrink();
    }

    final loginRequiredList = loginRequiredResults.toList();
    final failureHeader = failedResults.isEmpty ? 0 : 1;
    final itemCount = loginRequiredList.length +
        failureHeader +
        failedResults.length +
        state.bookInfoList.length;

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical &&
            notification.metrics.extentAfter < 320) {
          logic.loadMore();
        }
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index < loginRequiredList.length) {
            final result = loginRequiredList[index];
            return _SourceLoginRequiredItem(
              result: result,
              canOpenLogin: logic.hasOpenableSourceLoginEntry(result.source),
              onLoginAndRetry: () => logic.loginAndRetrySource(result.source),
            );
          }

          var cursor = index - loginRequiredList.length;
          if (failedResults.isNotEmpty) {
            if (cursor == 0) {
              return _FailedSourcesHeader(count: failedResults.length);
            }
            cursor -= 1;
            if (cursor < failedResults.length) {
              return _SourceFailedItem(result: failedResults[cursor]);
            }
            cursor -= failedResults.length;
          }

          final book = state.bookInfoList[cursor];
          final source = state.bookSources
              .firstWhere((value) => value.id == book.bookSourceId);
          return _SearchBookItem(
            searchBook: book,
            sourceName: source.bookSourceName,
            source: source,
            onRefreshBookshelf: logic.onRefreshBookshelf,
          );
        },
        itemCount: itemCount,
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context, BookSearchLogic logic) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final textColor = ColorUtils.getContrastTextColor(bgColor);
    final secondaryColor = ColorUtils.getContrastSecondaryTextColor(bgColor);

    if (state.searchHistories.isEmpty || !state.showHistory) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: [
            ...state.searchHistories.map(
              (history) => GestureDetector(
                onTap: () async {
                  await logic.search(history.keyword);
                  if (state.bookInfoList.isEmpty &&
                      !_hasLoginRequiredSource()) {
                    DialogUtils.waring('没有搜索到相关书籍');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    history.keyword,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: logic.clearSearchHistory,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFFE53935),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasLoginRequiredSource() {
    return state.sourceResults.values.any((result) => result.loginRequired);
  }

  void _syncSearchController() {
    final keyword = state.searchKeyword;
    if (_searchFocusNode.hasFocus || _searchController.text == keyword) {
      return;
    }

    _searchController.value = _searchController.value.copyWith(
      text: keyword,
      selection: TextSelection.collapsed(offset: keyword.length),
      composing: TextRange.empty,
    );
  }
}

class _SourceLoginRequiredItem extends StatelessWidget {
  const _SourceLoginRequiredItem({
    required this.result,
    required this.canOpenLogin,
    required this.onLoginAndRetry,
  });

  final SourceSearchResult result;
  final bool canOpenLogin;
  final VoidCallback onLoginAndRetry;

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final secondaryTextColor =
        ColorUtils.getContrastSecondaryTextColor(bgColor);
    final sourceName = result.source.bookSourceName;
    final message = result.error ?? '该书源需要登录后重试';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 22,
            color: Colors.orange.shade700,
          ),
          const Gap.hn(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sourceName,
                  style: context.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap.vs(),
                Text(
                  message,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Gap.hn(),
          TextButton(
            onPressed: canOpenLogin ? onLoginAndRetry : null,
            child: const Text('登录后重试'),
          ),
        ],
      ),
    );
  }
}

class _FailedSourcesHeader extends StatelessWidget {
  const _FailedSourcesHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final secondary = ColorUtils.getContrastSecondaryTextColor(
      Theme.of(context).colorScheme.surface,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        '失败书源 $count 个（可按类型排查）',
        style: context.textTheme.labelMedium?.copyWith(color: secondary),
      ),
    );
  }
}

class _SourceFailedItem extends StatelessWidget {
  const _SourceFailedItem({required this.result});

  final SourceSearchResult result;

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final secondaryTextColor =
        ColorUtils.getContrastSecondaryTextColor(bgColor);
    final failureClass = result.failureClass;
    final label = failureClass == null
        ? '失败'
        : SourceCheckReport.failureLabel(failureClass);
    final message = result.error ?? '搜索失败';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 20, color: Colors.red.shade400),
          const Gap.hn(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        result.source.bookSourceName,
                        style: context.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap.hs(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap.vs(),
                Text(
                  message,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBookItem extends StatelessWidget {
  const _SearchBookItem({
    required this.searchBook,
    required this.sourceName,
    required this.source,
    this.onRefreshBookshelf,
  });

  final BookInfo searchBook;
  final String sourceName;
  final db.BookSource source;
  final VoidCallback? onRefreshBookshelf;

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final secondaryTextColor =
        ColorUtils.getContrastSecondaryTextColor(bgColor);
    final introText = BookHelp.formatIntro(searchBook.intro);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Get.toNamed(
          AppRoutes.bookDetail,
          arguments: BookDetailArgs(
            bookInfo: searchBook,
            onRefreshBookshelf: onRefreshBookshelf,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: DecodedCoverImage(
                imageUrl: searchBook.cover ?? Assets.defaultBook,
                source: source,
                height: 80,
                width: 56,
                fit: BoxFit.cover,
                errorWidget: Image.asset(
                  Assets.defaultBook,
                  height: 80,
                  width: 56,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Gap.hn(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    searchBook.name,
                    style: context.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap.vs(),
                  if (introText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        introText,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        searchBook.author ?? '未知',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                      _Tag(
                        label: sourceName,
                        color: Colors.orange,
                      ),
                      if (searchBook.kind != null &&
                          searchBook.kind!.isNotEmpty)
                        ..._buildKindTags(searchBook.kind!),
                      if (searchBook.wordCount != null &&
                          searchBook.wordCount!.isNotEmpty)
                        _Tag(
                          label: searchBook.wordCount!,
                          color: Colors.teal,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKindTags(String kind) {
    return kind
        .split(RegExp(r'[,，、/\\s]+'))
        .where((tag) => tag.isNotEmpty)
        .take(3)
        .map((tag) => _Tag(label: tag, color: Colors.blueGrey))
        .toList();
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color),
      ),
    );
  }
}
