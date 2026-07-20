import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/service/source/source_check_policy.dart';

import '../logic.dart';
import '../state.dart';

Future<void> showSourceCheckConfigDialog(
  BuildContext context,
  SourceLogic logic,
) async {
  final initial = await logic.getCheckConfig();
  if (!context.mounted) return;

  final keywordController = TextEditingController(text: initial.keyword);
  final timeoutController =
      TextEditingController(text: initial.timeoutSeconds.toString());
  final concurrencyController =
      TextEditingController(text: initial.concurrency.toString());

  bool fastMode = initial.fastMode;
  bool checkSearch = initial.checkSearch;
  bool checkDiscovery = initial.checkDiscovery;
  bool checkInfo = initial.checkInfo;
  bool checkCategory = initial.checkCategory;
  bool checkContent = initial.checkContent;

  await Get.dialog(
    StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('校验设置'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: keywordController,
                    decoration: const InputDecoration(
                      labelText: '校验关键词',
                      hintText: '默认：我的',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timeoutController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '单源超时（秒）',
                      hintText: '必须大于 0，默认 180',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: concurrencyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '批量并发数',
                      hintText: '1-16，默认 9',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('快速校验'),
                    subtitle: const Text('搜索通过后，发现只校验列表'),
                    value: fastMode,
                    onChanged: (value) => setState(() => fastMode = value),
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('校验搜索'),
                    value: checkSearch,
                    onChanged: (value) => setState(() {
                      checkSearch = value;
                      if (!checkSearch && !checkDiscovery) {
                        checkDiscovery = true;
                      }
                    }),
                  ),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('校验发现'),
                    value: checkDiscovery,
                    onChanged: (value) => setState(() {
                      checkDiscovery = value;
                      if (!checkSearch && !checkDiscovery) {
                        checkSearch = true;
                      }
                    }),
                  ),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('校验详情'),
                    value: checkInfo,
                    onChanged: (value) => setState(() {
                      checkInfo = value;
                      if (!checkInfo) {
                        checkCategory = false;
                        checkContent = false;
                      }
                    }),
                  ),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('校验目录'),
                    value: checkCategory,
                    onChanged: checkInfo
                        ? (value) => setState(() {
                              checkCategory = value;
                              if (!checkCategory) {
                                checkContent = false;
                              }
                            })
                        : null,
                  ),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('校验正文'),
                    value: checkContent,
                    onChanged: (checkInfo && checkCategory)
                        ? (value) => setState(() => checkContent = value)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final parsedTimeout = int.tryParse(
                  timeoutController.text.trim(),
                );
                if (parsedTimeout == null ||
                    !SourceCheckPolicy.isValidTimeoutSeconds(parsedTimeout)) {
                  Get.snackbar(
                    '校验设置',
                    '超时时间必须大于 0 秒',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.orange.withValues(alpha: 0.9),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                  return;
                }
                final parsedConcurrency = int.tryParse(
                  concurrencyController.text.trim(),
                );
                if (parsedConcurrency == null ||
                    !SourceCheckPolicy.isValidConcurrency(parsedConcurrency)) {
                  Get.snackbar(
                    '校验设置',
                    '批量并发数必须在 ${SourceCheckPolicy.minConcurrency}-${SourceCheckPolicy.maxConcurrency} 之间',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.orange.withValues(alpha: 0.9),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                  return;
                }
                await logic.saveCheckConfig(
                  CheckSourceConfig(
                    timeoutSeconds: parsedTimeout,
                    concurrency: parsedConcurrency,
                    keyword: keywordController.text,
                    fastMode: fastMode,
                    checkSearch: checkSearch,
                    checkDiscovery: checkDiscovery,
                    checkInfo: checkInfo,
                    checkCategory: checkCategory,
                    checkContent: checkContent,
                  ),
                );
                Get.back();
                Get.snackbar(
                  '校验设置',
                  '保存成功',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green.withValues(alpha: 0.9),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    ),
  );

  keywordController.dispose();
  timeoutController.dispose();
  concurrencyController.dispose();
}
