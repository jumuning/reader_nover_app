import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/default_setting.dart';
import '../../../app/l10n/generated/l10n.dart';
import '../../../util/color_utils.dart';
import '../controllers/book_read_ui_refresh_controller.dart';
import '../logic.dart';
import '../state.dart';
import 'book_read_colors_picker_sheet.dart';
import 'book_read_font_picker_sheet.dart';
import 'book_read_more_settings_sheet.dart';

class BookReadSettingsSheet extends StatelessWidget {
  final BookReadLogic logic;
  final BookReadState state;

  const BookReadSettingsSheet({
    super.key,
    required this.logic,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookReadLogic>(
      init: logic,
      global: false,
      id: BookReadUiRefreshController.overlayUpdateId,
      builder: (l) {
        final bgColor = state.backgroundColor;
        final textColor = ColorUtils.getContrastTextColor(bgColor);
        final secondaryTextColor =
            ColorUtils.getContrastSecondaryTextColor(bgColor);

        return Container(
          width: double.infinity,
          height: _sheetHeight(context),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBrightness(l, textColor, secondaryTextColor),
                  const SizedBox(height: 8),
                  _buildFont(context, l, textColor),
                  const SizedBox(height: 8),
                  _buildSpacing(l, textColor),
                  const SizedBox(height: 8),
                  _buildBackground(context, l, textColor),
                  const SizedBox(height: 8),
                  _buildFlip(context, l, textColor, secondaryTextColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================== 高度策略 ==================

  double _sheetHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPad = size.shortestSide >= 600;
    final isLandscape = size.width > size.height;

    if (!isPad) {
      return size.height * 0.38;
    }

    // Pad 横屏更保守
    return isLandscape ? size.height * 0.44 : size.height * 0.34;
  }

  // ================== 各模块 ==================

  // 标签固定宽度，保证对齐
  static const double _labelWidth = 36.0;

  Widget _buildBrightness(BookReadLogic l, Color textColor, Color iconColor) {
    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text('亮度', style: TextStyle(color: textColor)),
        ),
        Expanded(
          child: Slider(
            value: state.brightness,
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: l.updateBrightness,
          ),
        ),
        Text(
          '${(state.brightness * 100).toInt()}%',
          style: TextStyle(color: textColor),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: l.updateEyeProtectionMode,
          child: Row(
            children: [
              Text('护眼', style: TextStyle(color: textColor)),
              const SizedBox(width: 4),
              Icon(
                state.isEyeProtectionMode
                    ? Icons.visibility
                    : Icons.visibility_off,
                size: 22,
                color: iconColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFont(BuildContext context, BookReadLogic l, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text('字体', style: TextStyle(color: textColor)),
        ),
        _stepper(
          onMinus: () => l.updateFontSize(state.fontSize - 1),
          value: state.fontSize.toInt().toString(),
          onPlus: () => l.updateFontSize(state.fontSize + 1),
          textColor: textColor,
        ),
        const SizedBox(width: 32),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionButton(
                  label: '选择字体',
                  textColor: textColor,
                  onPressed: () {
                    _openFollowupSheet(
                      context,
                      () => BookReadFontPickerSheet.show(
                        _rootContext(context),
                        l,
                        state,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  label: '朗读设置',
                  textColor: textColor,
                  onPressed: () {
                    _openFollowupSheet(
                      context,
                      () => BookReadMoreSettingsSheet.show(
                        _rootContext(context),
                        l,
                        state,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpacing(BookReadLogic l, Color textColor) {
    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text('行距', style: TextStyle(color: textColor)),
        ),
        _stepper(
          onMinus: () => l.updateLineSpacing(state.lineSpacing - 0.1),
          value: state.lineSpacing.toStringAsFixed(1),
          onPlus: () => l.updateLineSpacing(state.lineSpacing + 0.1),
          textColor: textColor,
        ),
        const SizedBox(width: 32),
        SizedBox(
          width: _labelWidth,
          child: Text('字距', style: TextStyle(color: textColor)),
        ),
        _stepper(
          onMinus: () => l.updateLetterSpacing(state.letterSpacing - 0.1),
          value: state.letterSpacing.toStringAsFixed(1),
          onPlus: () => l.updateLetterSpacing(state.letterSpacing + 0.1),
          textColor: textColor,
        ),
      ],
    );
  }

  Widget _buildBackground(
      BuildContext context, BookReadLogic l, Color textColor) {
    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text('背景', style: TextStyle(color: textColor)),
        ),
        _ColorOption(color: Colors.white, logic: l),
        _ColorOption(color: const Color(0xFFE0F7FA), logic: l),
        _ColorOption(color: const Color(0xFFBBDEFB), logic: l),
        _ColorOption(color: const Color(0xFFF8F9E8), logic: l),
        const Spacer(),
        TextButton(
          onPressed: () {
            _openFollowupSheet(
              context,
              () => BookReadColorsPickerSheet.show(
                _rootContext(context),
                l,
                state,
              ),
            );
          },
          child: Text(
            '更多 >',
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    );
  }

  BuildContext _rootContext(BuildContext context) {
    return Get.overlayContext ?? Get.context ?? context;
  }

  void _openFollowupSheet(
    BuildContext context,
    VoidCallback openSheet,
  ) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      openSheet();
    });
  }

  Widget _buildFlip(
    BuildContext context,
    BookReadLogic l,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text('翻页', style: TextStyle(color: textColor)),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FlipOption(
                  label: S.of(context).simulation,
                  value: DefaultSetting.pageTurnTypeSimulation,
                  logic: l,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
                const SizedBox(width: 10),
                _FlipOption(
                  label: S.of(context).cover,
                  value: DefaultSetting.pageTurnTypeCover,
                  logic: l,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
                const SizedBox(width: 10),
                _FlipOption(
                  label: S.of(context).slide,
                  value: DefaultSetting.pageTurnTypeSlide,
                  logic: l,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
                const SizedBox(width: 10),
                _FlipOption(
                  label: S.of(context).vertical,
                  value: DefaultSetting.pageTurnTypeVertical,
                  logic: l,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
                const SizedBox(width: 10),
                _FlipOption(
                  label: S.of(context).noAnimation,
                  value: DefaultSetting.pageTurnTypeNoAnimation,
                  logic: l,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: textColor,
        backgroundColor: textColor.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _stepper({
    required VoidCallback onMinus,
    required String value,
    required VoidCallback onPlus,
    required Color textColor,
  }) {
    return Row(
      children: [
        _btn('-', onMinus, textColor),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: 32,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
        _btn('+', onPlus, textColor),
      ],
    );
  }

  Widget _btn(String text, VoidCallback onTap, Color textColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
        ),
      ),
    );
  }
}

// ================== 子组件 ==================

class _ColorOption extends StatelessWidget {
  final Color color;
  final BookReadLogic logic;
  const _ColorOption({required this.color, required this.logic});

  @override
  Widget build(BuildContext context) {
    final isSelected = logic.state.backgroundColor == color;
    final isWhite = color == Colors.white;

    return GestureDetector(
      onTap: () => logic.updateBackgroundColor(color),
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (isWhite ? Colors.grey.shade300 : Colors.transparent),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 16,
                color:
                    color.computeLuminance() > 0.5 ? Colors.blue : Colors.white,
              )
            : null,
      ),
    );
  }
}

class _FlipOption extends StatelessWidget {
  final String label;
  final String value;
  final BookReadLogic logic;
  final Color textColor;
  final Color secondaryTextColor;

  const _FlipOption({
    required this.label,
    required this.value,
    required this.logic,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final selected = logic.state.pageTurnType == value;

    return GestureDetector(
      onTap: () => logic.updatePageTurnType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border:
              Border.all(color: selected ? Colors.blue : secondaryTextColor),
          borderRadius: BorderRadius.circular(6),
          color: selected ? Colors.blue.withValues(alpha: 0.15) : null,
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.blue : textColor),
        ),
      ),
    );
  }
}
