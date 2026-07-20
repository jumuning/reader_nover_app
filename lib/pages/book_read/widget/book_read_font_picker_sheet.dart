import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/fonts.dart';
import '../../../util/color_utils.dart';
import '../logic.dart';
import '../state.dart';

class BookReadFontPickerSheet extends StatelessWidget {
  final BookReadLogic logic;
  final BookReadState state;

  const BookReadFontPickerSheet({
    super.key,
    required this.logic,
    required this.state,
  });

  /// 显示字体选择器
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
          child: BookReadFontPickerSheet(
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
  Widget build(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖拽条
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: secondaryTextColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Text(
                  '选择字体',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 字体列表
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: Fonts.availableFonts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final font = Fonts.availableFonts[index];
                final isSelected = state.fontFamily == font['family'];

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    logic.updateFontFamily(font['family']);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? textColor.withValues(alpha: 0.08)
                          : bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? textColor.withValues(alpha: 0.4)
                            : secondaryTextColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 左侧选中指示点
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? textColor : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),

                        // 字体名
                        Expanded(
                          child: Text(
                            font['name']!,
                            style: TextStyle(
                              fontFamily: font['family'],
                              fontSize: 16,
                              color: textColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),

                        // 右侧勾选
                        if (isSelected)
                          Icon(
                            Icons.check_rounded,
                            color: textColor,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 底部安全区
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + 12,
          ),
        ],
      ),
    );
  }

  double _sheetHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPad = size.shortestSide >= 600;
    final isLandscape = size.width > size.height;

    if (!isPad) {
      return size.height * 0.3;
    }

    return isLandscape ? size.height * 0.35 : size.height * 0.25;
  }
}
