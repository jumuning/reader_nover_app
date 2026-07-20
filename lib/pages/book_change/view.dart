import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/service/book/models/source_book_info.dart';

import 'logic.dart';
import 'state.dart';

/// 换源页面
class BookChangePage extends StatelessWidget {
  const BookChangePage({
    super.key,
    required this.logic,
  });

  final BookChangeLogic logic;

  BookChangeState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookChangeLogic>(
      init: logic,
      global: false,
      builder: (_) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('换源', style: TextStyle(fontSize: 18)),
                Text(
                  state.bookName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            actions: [
              if (state.isSearching)
                TextButton.icon(
                  onPressed: logic.stopSearch,
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text('停止'),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: '重新搜索',
                  onPressed: logic.searchAvailableSources,
                ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchProgress(logic, state, theme, primaryColor),
              _buildCurrentSource(state),
              _buildSectionHeader(state, theme),
              Expanded(
                child: _buildSourceList(logic, state, primaryColor),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 搜索进度
  Widget _buildSearchProgress(
    BookChangeLogic logic,
    BookChangeState state,
    ThemeData theme,
    Color primaryColor,
  ) {
    if (!state.isSearching && state.searchedCount == 0) {
      return const SizedBox.shrink();
    }

    final progress = state.totalSourceCount > 0
        ? state.searchedCount / state.totalSourceCount
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (state.isSearching)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                ),
              if (state.isSearching) const SizedBox(width: 10),
              Text(
                state.isSearching ? '正在搜索可用书源' : '搜索完成',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const Spacer(),
              Text(
                '${state.searchedCount}/${state.totalSourceCount}',
                style: TextStyle(
                  fontSize: 12,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.7),
                      primaryColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (state.loginRequiredSourceCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '有 ${state.loginRequiredSourceCount} 个书源需要登录',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: state.loginRequiredSources.map((source) {
                final canLogin = logic.hasOpenableSourceLoginEntry(source);
                return ActionChip(
                  label: Text(
                    source.bookSourceName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  avatar: Icon(
                    canLogin ? Icons.lock_open : Icons.lock_outline,
                    size: 16,
                  ),
                  onPressed: canLogin
                      ? () => logic.loginAndRetrySource(source)
                      : null,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 当前书源
  Widget _buildCurrentSource(BookChangeState state) {
    const successColor = Colors.green;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: successColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: successColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.currentSourceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.currentSourceUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: successColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '当前',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 分区标题
  Widget _buildSectionHeader(BookChangeState state, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '可用书源',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${state.availableSources.length}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 书源列表
  Widget _buildSourceList(
    BookChangeLogic logic,
    BookChangeState state,
    Color primaryColor,
  ) {
    if (state.availableSources.isEmpty) {
      return Center(
        child: state.isSearching
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    '正在搜索可用书源...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无其他可用书源',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: logic.searchAvailableSources,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新搜索'),
                  ),
                ],
              ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.availableSources.length,
      itemBuilder: (context, index) {
        final source = state.availableSources[index];
        return _buildSourceItem(logic, source, primaryColor);
      },
    );
  }

  /// 单个书源项
  Widget _buildSourceItem(
    BookChangeLogic logic,
    SourceBookInfo source,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: primaryColor.withValues(alpha: 0.08),
          highlightColor: primaryColor.withValues(alpha: 0.05),
          onTap: () => logic.selectSource(source),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.public_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.bookSource.bookSourceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (source.lastChapter?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          source.lastChapter!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
