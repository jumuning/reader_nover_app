import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../../../util/color_utils.dart';
import '../logic.dart';
import '../state.dart';

class BookReadColorsPickerSheet extends StatefulWidget {
  final BookReadLogic logic;
  final BookReadState state;

  const BookReadColorsPickerSheet({
    super.key,
    required this.logic,
    required this.state,
  });

  /// 显示颜色选择器
  static void show(
    BuildContext context,
    BookReadLogic logic,
    BookReadState state,
  ) {
    Get.dialog(
      Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: 1,
          child: BookReadColorsPickerSheet(
            logic: logic,
            state: state,
          ),
        ),
      ),
      barrierColor: Colors.black54,
      barrierDismissible: true,
      useSafeArea: false,
    );
  }

  @override
  State<BookReadColorsPickerSheet> createState() =>
      _BookReadColorsPickerSheetState();
}

class _BookReadColorsPickerSheetState extends State<BookReadColorsPickerSheet> {
  late Color _currentColor;

  /// 预设颜色
  static const List<Color> _presetColors = [
    Color(0xFFF5F5DC),
    Color(0xFFE0F7FA),
    Color(0xFFBBDEFB),
    Color(0xFFF8F9E8),
    Color(0xFFFFE4C4),
    Color(0xFFE8E4D9),
    Color(0xFFD4EDDA),
    Color(0xFFFFF0F5),
    Color(0xFFF0E6FA),
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.state.backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.state.backgroundColor;
    final textColor = ColorUtils.getContrastTextColor(bgColor);
    final secondaryTextColor =
        ColorUtils.getContrastSecondaryTextColor(bgColor);

    return Container(
      width: double.infinity,
      height: _sheetHeight(context),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ───── 顶部拖拽条 ─────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: secondaryTextColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ───── 标题栏 ─────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
            child: Row(
              children: [
                Text(
                  '背景颜色',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    widget.logic.updateBackgroundColor(_currentColor);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '确定',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ───── 内容区 ─────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 预设颜色
                  Text(
                    '预设',
                    style: TextStyle(
                      color: secondaryTextColor.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPresetColors(),

                  const SizedBox(height: 14),

                  // 自定义颜色
                  Text(
                    '自定义',
                    style: TextStyle(
                      color: secondaryTextColor.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildColorPicker(context, bgColor, secondaryTextColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 预设颜色区
  Widget _buildPresetColors() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _presetColors.map((color) {
        final isSelected = _currentColor.toARGB32() == color.toARGB32();
        final isWhite = color == Colors.white;
        final isDark = color.computeLuminance() < 0.5;

        return GestureDetector(
          onTap: () {
            setState(() => _currentColor = color);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.blue
                    : (isWhite ? Colors.grey.shade300 : Colors.transparent),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: isSelected ? 0.12 : 0.06),
                  blurRadius: isSelected ? 6 : 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isDark ? Colors.white : Colors.blue,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  /// 自定义取色器
  Widget _buildColorPicker(
      BuildContext context, Color bgColor, Color secondaryTextColor) {
    final width = MediaQuery.of(context).size.width;
    // 根据系统主题决定取色器容器背景
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pickerBgColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final pickerBorderColor =
        isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pickerBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pickerBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🎨 上层取色主面板
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(6),
              color: pickerBgColor,
              child: ColorPicker(
                pickerColor: _currentColor,
                onColorChanged: (color) {
                  setState(() => _currentColor = color);
                },
                colorPickerWidth: width - 76,
                pickerAreaHeightPercent: 0.22,
                enableAlpha: false,
                displayThumbColor: false,
                labelTypes: const [],
                hexInputBar: false,
                pickerAreaBorderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 面板高度
  double _sheetHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPad = size.shortestSide >= 600;
    final isLandscape = size.width > size.height;

    if (!isPad) {
      return size.height * 0.4;
    }
    return isLandscape ? size.height * 0.3 : size.height * 0.35;
  }
}
