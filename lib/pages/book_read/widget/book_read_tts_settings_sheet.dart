import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/color_utils.dart';
import '../controllers/book_read_ui_refresh_controller.dart';
import '../logic.dart';
import '../state.dart';

class BookReadTtsSettingsSheet extends StatelessWidget {
  const BookReadTtsSettingsSheet({
    super.key,
    required this.logic,
    required this.state,
  });

  final BookReadLogic logic;
  final BookReadState state;

  static void show(
      BuildContext context, BookReadLogic logic, BookReadState state) {
    Get.dialog(
      Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: 1,
          child: BookReadTtsSettingsSheet(logic: logic, state: state),
        ),
      ),
      barrierColor: Colors.black54,
      useSafeArea: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookReadLogic>(
      init: logic,
      global: false,
      id: BookReadUiRefreshController.overlayUpdateId,
      builder: (_) {
        final textColor =
            ColorUtils.getContrastTextColor(state.backgroundColor);
        final secondaryColor =
            ColorUtils.getContrastSecondaryTextColor(state.backgroundColor);
        final names = state.ttsVoices.map((voice) => voice.name).toSet();
        final value =
            names.contains(state.ttsVoiceName) ? state.ttsVoiceName : null;
        return Material(
          color: state.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.volume_up_outlined, color: textColor),
                      const SizedBox(width: 10),
                      Text('系统发音人',
                          style: TextStyle(color: textColor, fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        tooltip: '刷新发音人',
                        onPressed: state.isTtsLoadingVoices
                            ? null
                            : logic.loadTtsVoices,
                        icon: const Icon(Icons.refresh_rounded),
                        color: textColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: value,
                    isExpanded: true,
                    dropdownColor: state.backgroundColor,
                    decoration: InputDecoration(
                      hintText: state.isTtsLoadingVoices ? '正在加载' : '使用系统默认',
                      hintStyle: TextStyle(color: secondaryColor),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('系统默认', style: TextStyle(color: textColor)),
                      ),
                      for (final voice in state.ttsVoices)
                        DropdownMenuItem<String>(
                          value: voice.name,
                          child: Text(
                            voice.locale?.isNotEmpty == true
                                ? '${voice.name} (${voice.locale})'
                                : voice.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                    ],
                    onChanged: names.isEmpty
                        ? null
                        : (next) {
                            logic.updateTtsVoice(
                                next?.isEmpty == true ? null : next);
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
