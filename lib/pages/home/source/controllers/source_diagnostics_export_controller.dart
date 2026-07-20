import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/service/source/source_check_diagnostics_store.dart';
import '../../../../util/log_utils.dart';

class SourceDiagnosticsExportController {
  SourceDiagnosticsExportController({
    SourceCheckDiagnosticsStore? diagnosticsStore,
  }) : _diagnosticsStore =
            diagnosticsStore ?? SourceCheckDiagnosticsStore.instance;

  final SourceCheckDiagnosticsStore _diagnosticsStore;

  Future<void> exportCheckDiagnostics({int limit = 100}) async {
    try {
      final jsonLines = await _diagnosticsStore.exportJsonLines(limit: limit);
      if (jsonLines.trim().isEmpty) {
        Get.snackbar(
          '导出诊断',
          '暂无可导出的书源校验诊断',
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      final documentsDir = await getApplicationDocumentsDirectory();
      final fileName =
          'source_check_diagnostics_${_formatTimestamp(DateTime.now())}.jsonl';
      final file = File('${documentsDir.path}/$fileName');
      await file.writeAsString(jsonLines);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '书源校验诊断日志（最近 $limit 条，已脱敏）',
        subject: 'reader_nover 书源校验诊断',
      );

      Get.snackbar(
        '导出完成',
        '已导出脱敏诊断日志\n${file.path}',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (error, stackTrace) {
      LogUtils.e('导出书源校验诊断失败: $error\n$stackTrace');
      Get.snackbar(
        '导出失败',
        '$error',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  String _formatTimestamp(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}_'
        '${two(time.hour)}${two(time.minute)}${two(time.second)}';
  }
}
