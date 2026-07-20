import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/constants/default_setting.dart';
import 'logic.dart';
import 'page_turn/page_turn_widget.dart';
import 'state.dart';
import 'controllers/book_read_ui_refresh_controller.dart';
import 'widget/book_read_app_bar.dart';
import 'widget/book_read_bottom_navigation_bar.dart';
import 'widget/book_read_context_sheet.dart';
import 'widget/book_read_directory_sheet.dart';
import 'widget/book_read_settings_sheet.dart';
import 'widget/book_read_tts_floating_bar.dart';

class BookReadPage extends StatelessWidget {
  const BookReadPage({
    super.key,
    required this.logic,
  });

  final BookReadLogic logic;

  BookReadState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        unawaited(logic.exitReadPage());
      },
      child: GetBuilder<BookReadLogic>(
        init: logic,
        global: false,
        id: BookReadUiRefreshController.shellUpdateId,
        builder: (logic) {
          final bg = state.isEyeProtectionMode
              ? const Color(0xFFF0F1E0)
              : state.backgroundColor;
          final brightness = ThemeData.estimateBrightnessForColor(bg);
          final statusBarBrightness = brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: statusBarBrightness,
              statusBarBrightness: brightness,
            ),
            child: Scaffold(
              backgroundColor: bg,
              extendBodyBehindAppBar: true,
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      _buildContent(constraints),
                      BookReadAppBar(logic: logic),
                      BookReadTtsFloatingBar(logic: logic),
                      BookReadBottomNavigationBar(
                        logic: logic,
                        onShowDirectory: () => showDirectorySideSheet(context),
                        onShowSettings: () => showSettingsBottomSheet(context),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    return GetBuilder<BookReadLogic>(
      init: logic,
      global: false,
      id: BookReadUiRefreshController.contentUpdateId,
      builder: (logic) {
        if (state.isInitialLoading) {
          return _buildInitialLoadingView();
        }

        if (state.initialLoadErrorMessage != null &&
            state.bookContentList.isEmpty) {
          return _buildInitialLoadErrorView();
        }

        final isVerticalMode =
            state.pageTurnType == DefaultSetting.pageTurnTypeVertical;
        if (isVerticalMode) {
          return GestureDetector(
            onTap: () {
              if (logic.consumeParagraphTapSuppression()) return;
              logic.toggleAppBarVisibility();
            },
            behavior: HitTestBehavior.translucent,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: PageTurnWidget(
                logic: logic,
                state: state,
                constraints: constraints,
                currentPageWidget: _buildPageSurface(showTargetPage: false),
                targetPageWidget: _buildPageSurface(showTargetPage: true),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            if (logic.consumeParagraphTapSuppression()) return;
            logic.toggleAppBarVisibility();
          },
          onHorizontalDragStart: (details) {
            if (!state.isAnimating) {
              logic.onDragStart(details, constraints);
            }
          },
          onHorizontalDragUpdate: (details) {
            if (!state.isAnimating) {
              logic.onDragUpdate(details, constraints);
            }
          },
          onHorizontalDragEnd: (details) {
            if (!state.isAnimating) {
              logic.onDragEnd(details, constraints);
            }
          },
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: PageTurnWidget(
              logic: logic,
              state: state,
              constraints: constraints,
              currentPageWidget:
                  BookReadContextSheet(logic: logic, state: state),
              targetPageWidget: BookReadContextSheet(
                logic: logic,
                state: state,
                showTargetPage: true,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageSurface({required bool showTargetPage}) {
    if (!state.isTwoPageMode) {
      return BookReadContextSheet(
        logic: logic,
        state: state,
        showTargetPage: showTargetPage,
      );
    }
    return Row(
      children: [
        Expanded(
          child: BookReadContextSheet(
            logic: logic,
            state: state,
            showTargetPage: showTargetPage,
          ),
        ),
        Container(width: 1, color: state.iconColor.withValues(alpha: 0.12)),
        Expanded(
          child: BookReadContextSheet(
            logic: logic,
            state: state,
            showTargetPage: showTargetPage,
            pageOffset: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialLoadingView() {
    return SizedBox.expand(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 4,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: state.iconColor),
                onPressed: () {
                  unawaited(logic.exitReadPage());
                },
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(strokeWidth: 2.4),
                  const SizedBox(height: 16),
                  Text(
                    '正在加载正文',
                    style: TextStyle(
                      color: state.iconColor.withValues(alpha: 0.72),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialLoadErrorView() {
    final textColor = state.iconColor;
    return SizedBox.expand(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 40, color: textColor),
              const SizedBox(height: 16),
              Text(
                state.initialLoadErrorMessage ?? '正文加载失败',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      unawaited(logic.exitReadPage());
                    },
                    child: const Text('返回'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: logic.retryInitialLoad,
                    child: const Text('重试'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDirectorySideSheet(BuildContext context) {
    logic.hideAppBar();
    showGeneralDialog(
      context: context,
      barrierLabel: 'Directory Side Sheet',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerLeft,
          child: BookReadDirectorySheet(
            logic: logic,
            state: state,
            onClose: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(-1, 0), end: Offset.zero)
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  void showSettingsBottomSheet(BuildContext context) {
    logic.hideAppBar();
    Get.dialog(
      Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: 1,
          child: BookReadSettingsSheet(
            logic: logic,
            state: state,
          ),
        ),
      ),
      barrierColor: Colors.black54,
      barrierDismissible: true,
      useSafeArea: false,
    ).whenComplete(() {
      logic.showAppBar();
    });
  }
}
