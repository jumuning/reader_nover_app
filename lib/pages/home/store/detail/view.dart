import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/database/drift/app_database.dart' as db;
import '../state.dart';
import 'logic.dart';
import 'widget/store_detail_body.dart';

class StoreDetailPage extends StatelessWidget {
  StoreDetailPage({
    super.key,
    required this.source,
    required this.kind,
  });

  final db.BookSource source;
  final ExploreKind kind;
  late final StoreDetailLogic logic =
      StoreDetailLogic(source: source, kind: kind);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GetBuilder<StoreDetailLogic>(
      init: logic,
      global: false,
      builder: (logic) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            titleSpacing: 0,
            title: _StoreDetailTitle(logic: logic),
            actions: [
              IconButton(
                tooltip: '刷新',
                onPressed: logic.state.isLoading ? null : logic.refreshBooks,
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: StoreDetailBody(logic: logic),
        );
      },
    );
  }
}

class _StoreDetailTitle extends StatelessWidget {
  const _StoreDetailTitle({required this.logic});

  final StoreDetailLogic logic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          logic.kind.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 12,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                logic.source.bookSourceName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
