import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/l10n/generated/l10n.dart';
import '../../../util/gap.dart';
import '../controllers/book_read_ui_refresh_controller.dart';
import '../logic.dart';
import 'book_read_page_bottom_button.dart';

class BookReadBottomNavigationBar extends StatelessWidget {
  const BookReadBottomNavigationBar({
    super.key,
    required this.logic,
    required this.onShowDirectory,
    required this.onShowSettings,
  });

  final BookReadLogic logic;
  final VoidCallback onShowDirectory;
  final VoidCallback onShowSettings;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookReadLogic>(
      init: logic,
      global: false,
      id: BookReadUiRefreshController.chromeUpdateId,
      builder: (logic) {
        final state = logic.state;
        final maxPage =
            state.pageSize > 1 ? state.pageSize.toDouble() - 1 : 1.0;
        final sliderValue = state.currentPage.toDouble().clamp(0.0, maxPage);
        final isNightMode = logic.isNightMode();

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          bottom: state.isAppBarVisible ? 0 : -95,
          left: 0,
          right: 0,
          child: state.isAppBarVisible
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: state.backgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => logic.previousChapter(false),
                            child: Text(
                              S.of(context).previousChapter,
                              style: TextStyle(color: state.textColor),
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                                activeTrackColor:
                                    state.textColor.withValues(alpha: 0.4),
                                inactiveTrackColor:
                                    state.textColor.withValues(alpha: 0.12),
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: sliderValue,
                                min: 0,
                                max: maxPage,
                                divisions: maxPage > 0 ? maxPage.toInt() : null,
                                label:
                                    '${state.currentPage + 1}/${state.pageSize}',
                                onChanged: (value) {
                                  logic.jumpToPage(value.round());
                                },
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => logic.nextChapter(false),
                            child: Text(
                              S.of(context).nextChapter,
                              style: TextStyle(color: state.textColor),
                            ),
                          ),
                        ],
                      ),
                      const Gap.vn(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          BookReadPageBottomButton(
                            text: S.of(context).directory,
                            icon: Icons.menu_book,
                            color: state.textColor,
                            onPressed: onShowDirectory,
                          ),
                          BookReadPageBottomButton(
                            text: isNightMode ? '日间' : '夜间',
                            icon: isNightMode
                                ? Icons.wb_sunny
                                : Icons.nightlight_round,
                            color: state.textColor,
                            onPressed: logic.toggleNightMode,
                          ),
                          BookReadPageBottomButton(
                            text: S.of(context).setting,
                            icon: Icons.settings,
                            color: state.textColor,
                            onPressed: onShowSettings,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }
}
