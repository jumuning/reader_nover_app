import 'package:flutter/material.dart';

import '../../../../common/app_empty_state.dart';
import '../logic.dart';
import 'store_detail_book_grid.dart';

/// 分类结果：加载 / 空态 / 错误 / 网格 + 上拉加载更多。
class StoreDetailBody extends StatelessWidget {
  const StoreDetailBody({
    super.key,
    required this.logic,
  });

  final StoreDetailLogic logic;

  @override
  Widget build(BuildContext context) {
    if (logic.state.isLoading && logic.state.books.isEmpty) {
      return _StoreDetailLoading(kindTitle: logic.kind.title);
    }

    if (logic.state.books.isEmpty &&
        logic.state.errorMessage?.isNotEmpty == true) {
      final isNetwork = _looksLikeNetworkError(logic.state.errorMessage!);
      final isLogin = logic.state.loginRequired;
      return AppEmptyState(
        icon: isLogin
            ? Icons.lock_outline_rounded
            : (isNetwork
                ? Icons.wifi_off_rounded
                : Icons.error_outline_rounded),
        title: isLogin
            ? '需要登录'
            : (isNetwork ? '网络异常' : '加载失败'),
        subtitle: logic.state.errorMessage,
        actions: [
          FilledButton.tonalIcon(
            onPressed: isLogin ? logic.loginAndRetry : logic.loadBooks,
            icon: Icon(isLogin ? Icons.login_rounded : Icons.refresh_rounded),
            label: Text(isLogin ? '登录后重试' : '重试'),
          ),
        ],
      );
    }

    if (logic.state.books.isEmpty) {
      return AppEmptyState(
        icon: Icons.menu_book_outlined,
        title: '暂无书籍',
        subtitle:
            '「${logic.kind.title}」下没有可展示内容\n${logic.source.bookSourceName}',
        actions: [
          FilledButton.tonalIcon(
            onPressed: logic.loadBooks,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新加载'),
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.metrics.extentAfter < 800 &&
            !logic.state.isLoading &&
            logic.state.hasMore) {
          logic.loadBooks(loadMore: true);
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: logic.refreshBooks,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            StoreDetailBookGrid(logic: logic),
            SliverToBoxAdapter(
              child: _StoreDetailLoadFooter(
                isLoading: logic.state.isLoading,
                hasMore: logic.state.hasMore,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreDetailLoading extends StatelessWidget {
  const _StoreDetailLoading({required this.kindTitle});

  final String kindTitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '正在加载「$kindTitle」',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _StoreDetailLoadFooter extends StatelessWidget {
  const _StoreDetailLoadFooter({
    required this.isLoading,
    required this.hasMore,
  });

  final bool isLoading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!hasMore && !isLoading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Center(
          child: Text(
            '已经到底了',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
          ),
        ),
      );
    }
    if (!isLoading) {
      return const SizedBox(height: 24);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '加载更多…',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

bool _looksLikeNetworkError(String message) {
  final m = message.toLowerCase();
  return message.contains('网络') ||
      message.contains('超时') ||
      m.contains('timeout') ||
      m.contains('connection');
}
