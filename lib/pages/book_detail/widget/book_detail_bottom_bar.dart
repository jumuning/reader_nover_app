import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/util/gap.dart';

import '../state.dart';

class BookDetailBottomBar extends StatelessWidget {
  const BookDetailBottomBar({
    super.key,
    required this.state,
    required this.onStartOrContinueRead,
    required this.onAddToBookshelf,
    required this.onRemoveFromBookshelf,
  });

  final BookDetailState state;
  final Future<void> Function() onStartOrContinueRead;
  final Future<void> Function() onAddToBookshelf;
  final Future<void> Function() onRemoveFromBookshelf;

  @override
  Widget build(BuildContext context) {
    final busy = state.isBottomBarBusy;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () async {
                        if (state.isInBookshelf) {
                          await onRemoveFromBookshelf();
                        } else {
                          await onAddToBookshelf();
                        }
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        state.isInBookshelf ? '移出书架' : '加入书架',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const Gap.h(value: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: busy ? null : onStartOrContinueRead,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        state.currentReadChapterIndex != null ? '继续阅读' : '开始阅读',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
