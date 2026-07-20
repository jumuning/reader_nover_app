import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/book_read_ui_refresh_controller.dart';
import '../logic.dart';

class BookReadTtsFloatingBar extends StatelessWidget {
  const BookReadTtsFloatingBar({
    super.key,
    required this.logic,
  });

  final BookReadLogic logic;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookReadLogic>(
      init: logic,
      global: false,
      id: BookReadUiRefreshController.ttsFloatingUpdateId,
      builder: (logic) {
        final state = logic.state;
        final isActive = state.isTtsPlaying && !state.isTtsPaused;
        final isVisible = state.isTtsPlaying || state.isTtsPaused;
        final shouldShow = state.isAppBarVisible;
        final isStoppingByLongPress = state.isTtsLongPressStopping && isVisible;
        final isTransitioningChapter =
            state.isTtsTransitioningChapter && isVisible;
        final accentColor =
            ThemeData.estimateBrightnessForColor(state.backgroundColor) ==
                    Brightness.dark
                ? const Color(0xFFE7C46A)
                : const Color(0xFF8B6B3F);
        const stopAccentColor = Color(0xFFE2574C);
        const transitionAccentColor = Color(0xFFF08A24);
        final effectiveAccentColor = isStoppingByLongPress
            ? stopAccentColor
            : isTransitioningChapter
                ? transitionAccentColor
                : accentColor;
        final tooltip =
            isVisible ? '${isActive ? '暂停朗读' : '开始朗读'}，长按停止朗读' : '开始朗读';
        final badgeIcon = isStoppingByLongPress
            ? Icons.stop_rounded
            : isActive
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded;

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          right: 18,
          bottom: shouldShow ? 136 : -96,
          child: IgnorePointer(
            ignoring: !shouldShow,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: shouldShow ? 1 : 0,
              child: Tooltip(
                message: tooltip,
                child: GestureDetector(
                  onTap: () async {
                    logic.setTtsLongPressStopping(false);
                    await logic.toggleTts();
                    if (state.isAppBarVisible) {
                      logic.toggleAppBarVisibility();
                    }
                  },
                  onLongPressStart: isVisible
                      ? (_) {
                          logic.setTtsLongPressStopping(true);
                        }
                      : null,
                  onLongPressEnd: isVisible
                      ? (_) {
                          logic.setTtsLongPressStopping(false);
                        }
                      : null,
                  onLongPress: isVisible
                      ? () async {
                          HapticFeedback.mediumImpact();
                          await logic.stopTts(showFeedback: true);
                        }
                      : null,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: isStoppingByLongPress ? 60 : 56,
                          height: isStoppingByLongPress ? 60 : 56,
                          decoration: BoxDecoration(
                            color:
                                state.backgroundColor.withValues(alpha: 0.96),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isStoppingByLongPress
                                        ? stopAccentColor
                                        : Colors.black)
                                    .withValues(
                                  alpha: isStoppingByLongPress ? 0.22 : 0.14,
                                ),
                                blurRadius: isStoppingByLongPress ? 18 : 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(
                              color: isVisible
                                  ? effectiveAccentColor.withValues(alpha: 0.24)
                                  : state.textColor.withValues(alpha: 0.14),
                              width: 2,
                            ),
                          ),
                        ),
                        if (isActive || isTransitioningChapter)
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                effectiveAccentColor,
                              ),
                              backgroundColor:
                                  effectiveAccentColor.withValues(alpha: 0.10),
                            ),
                          ),
                        Icon(
                          isStoppingByLongPress
                              ? Icons.stop_circle_outlined
                              : Icons.hearing_rounded,
                          size: 26,
                          color: isVisible
                              ? effectiveAccentColor
                              : state.textColor,
                        ),
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isVisible
                                  ? effectiveAccentColor
                                  : state.textColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              badgeIcon,
                              size: 14,
                              color: state.backgroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
