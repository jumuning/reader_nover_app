import 'dart:async';

import 'package:dio/dio.dart';
import 'package:reader_nover/app/service/source/source_http.dart';

enum SourceCheckStage { search, discovery, detail, toc, content }

enum SourceCheckFailureClass {
  timeout,
  network,
  emptyResult,
  ruleParse,
  javascript,
  webviewRequired,
  tinyContent,
  cancelled,
  other,
}

class SourceCheckStageReport {
  const SourceCheckStageReport({
    required this.stage,
    required this.ok,
    required this.elapsedMs,
    this.message,
    this.failureClass,
    this.diagnostics = const <String, Object?>{},
  });

  final SourceCheckStage stage;
  final bool ok;
  final int elapsedMs;
  final String? message;
  final SourceCheckFailureClass? failureClass;
  final Map<String, Object?> diagnostics;

  String get stageName => SourceCheckReport.stageLabel(stage);
}

class SourceCheckReportBuilder {
  final List<SourceCheckStageReport> _stages = <SourceCheckStageReport>[];

  List<SourceCheckStageReport> build() => List.unmodifiable(_stages);

  Future<T> record<T>({
    required SourceCheckStage stage,
    required Future<T> Function() action,
    String Function(T value)? successMessage,
    Map<String, Object?> Function(T value)? successDiagnostics,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      stopwatch.stop();
      _stages.add(
        SourceCheckStageReport(
          stage: stage,
          ok: true,
          elapsedMs: stopwatch.elapsedMilliseconds,
          message: successMessage?.call(result),
          diagnostics: SourceCheckReport.sanitizeDiagnostics(
            successDiagnostics?.call(result),
          ),
        ),
      );
      return result;
    } catch (error) {
      stopwatch.stop();
      _stages.add(
        SourceCheckStageReport(
          stage: stage,
          ok: false,
          elapsedMs: stopwatch.elapsedMilliseconds,
          message: SourceCheckReport.errorSummary(error),
          failureClass: SourceCheckReport.classifyFailure(error, stage: stage),
          diagnostics: SourceCheckReport.sanitizeDiagnostics(
            failureDiagnostics(error),
          ),
        ),
      );
      rethrow;
    }
  }

  void addSkipped(SourceCheckStage stage, String message) {
    _stages.add(
      SourceCheckStageReport(
        stage: stage,
        ok: true,
        elapsedMs: 0,
        message: message,
        diagnostics: SourceCheckReport.sanitizeDiagnostics(
          const {'skipped': true},
        ),
      ),
    );
  }

  SourceCheckStageReport addSuccess({
    required SourceCheckStage stage,
    required int elapsedMs,
    String? message,
    Map<String, Object?> diagnostics = const {},
  }) {
    final report = SourceCheckStageReport(
      stage: stage,
      ok: true,
      elapsedMs: elapsedMs,
      message: message,
      diagnostics: SourceCheckReport.sanitizeDiagnostics(diagnostics),
    );
    _stages.add(report);
    return report;
  }

  SourceCheckStageReport addFailure({
    required SourceCheckStage stage,
    required Object error,
    int elapsedMs = 0,
    String? message,
    Map<String, Object?> diagnostics = const {},
  }) {
    final report = SourceCheckStageReport(
      stage: stage,
      ok: false,
      elapsedMs: elapsedMs,
      message: message ?? SourceCheckReport.errorSummary(error),
      failureClass: SourceCheckReport.classifyFailure(error, stage: stage),
      diagnostics: SourceCheckReport.sanitizeDiagnostics({
        ...failureDiagnostics(error),
        ...diagnostics,
      }),
    );
    _stages.add(report);
    return report;
  }

  static Map<String, Object?> failureDiagnostics(Object error) {
    final failureClass = SourceCheckReport.classifyFailure(error);
    return <String, Object?>{
      'failure_class_${failureClass.name}': true,
      if (error is CheckException) ...error.diagnostics,
    };
  }
}

class SourceCheckReport {
  const SourceCheckReport._();

  static String stageLabel(SourceCheckStage stage) {
    switch (stage) {
      case SourceCheckStage.search:
        return '搜索';
      case SourceCheckStage.discovery:
        return '发现';
      case SourceCheckStage.detail:
        return '详情';
      case SourceCheckStage.toc:
        return '目录';
      case SourceCheckStage.content:
        return '正文';
    }
  }

  static String failureLabel(SourceCheckFailureClass failureClass) {
    switch (failureClass) {
      case SourceCheckFailureClass.timeout:
        return '超时';
      case SourceCheckFailureClass.network:
        return '网络';
      case SourceCheckFailureClass.emptyResult:
        return '空结果';
      case SourceCheckFailureClass.ruleParse:
        return '规则';
      case SourceCheckFailureClass.javascript:
        return 'JS';
      case SourceCheckFailureClass.webviewRequired:
        return 'WebView';
      case SourceCheckFailureClass.tinyContent:
        return '内容过短';
      case SourceCheckFailureClass.cancelled:
        return '取消';
      case SourceCheckFailureClass.other:
        return '其他';
    }
  }

  static String errorSummary(Object error) {
    final raw = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (raw.length <= 180) return raw;
    return '${raw.substring(0, 180)}...';
  }

  static Map<String, Object?> sanitizeDiagnostics(
    Map<String, Object?>? diagnostics,
  ) {
    if (diagnostics == null || diagnostics.isEmpty) {
      return const <String, Object?>{};
    }

    final sanitized = <String, Object?>{};
    for (final entry in diagnostics.entries) {
      final key = entry.key.trim();
      if (key.isEmpty || _isSensitiveDiagnosticKey(key)) continue;
      final value = entry.value;
      if (value == null || value is num || value is bool) {
        sanitized[key] = value;
      } else if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          sanitized[key] =
              trimmed.length <= 200 ? trimmed : trimmed.substring(0, 200);
        }
      }
    }
    return Map.unmodifiable(sanitized);
  }

  static bool _isSensitiveDiagnosticKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('url') ||
        lower.contains('html') ||
        lower.contains('preview') ||
        lower.contains('keyword') ||
        lower.contains('cookie') ||
        lower.contains('token') ||
        lower.contains('header') ||
        lower.contains('name') ||
        lower.contains('author') ||
        lower.contains('summary');
  }

  static SourceCheckFailureClass classifyFailure(
    Object error, {
    SourceCheckStage? stage,
  }) {
    if (error is TimeoutException) {
      return SourceCheckFailureClass.timeout;
    }
    if (error is DioException) {
      if (error.type == DioExceptionType.cancel) {
        return SourceCheckFailureClass.cancelled;
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return SourceCheckFailureClass.timeout;
        case DioExceptionType.connectionError:
        case DioExceptionType.badCertificate:
        case DioExceptionType.badResponse:
        case DioExceptionType.unknown:
          return SourceCheckFailureClass.network;
        case DioExceptionType.cancel:
          return SourceCheckFailureClass.cancelled;
      }
    }

    final lower = error.toString().toLowerCase();
    if (lower.contains('cancel') || lower.contains('取消')) {
      return SourceCheckFailureClass.cancelled;
    }
    if (lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('超时')) {
      return SourceCheckFailureClass.timeout;
    }
    if (lower.contains('webview')) {
      return SourceCheckFailureClass.webviewRequired;
    }
    if (lower.contains('javascript') ||
        lower.contains('scriptexception') ||
        lower.contains('wrappedexception') ||
        lower.contains('js失效')) {
      return SourceCheckFailureClass.javascript;
    }
    if (lower.contains('rule') ||
        lower.contains('selector') ||
        lower.contains('regex') ||
        lower.contains('jsonpath') ||
        lower.contains('xpath') ||
        lower.contains('解析') ||
        lower.contains('规则') ||
        lower.contains('选择器')) {
      return SourceCheckFailureClass.ruleParse;
    }
    if (lower.contains('empty') ||
        lower.contains('no result') ||
        lower.contains('为空') ||
        lower.contains('目录为空') ||
        lower.contains('搜索失效') ||
        lower.contains('发现失效')) {
      return SourceCheckFailureClass.emptyResult;
    }
    if (stage == SourceCheckStage.content &&
        (lower.contains('太短') ||
            lower.contains('过短') ||
            lower.contains('tiny'))) {
      return SourceCheckFailureClass.tinyContent;
    }
    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('host lookup') ||
        lower.contains('http ') ||
        lower.contains('网络') ||
        lower.contains('连接')) {
      return SourceCheckFailureClass.network;
    }
    return SourceCheckFailureClass.other;
  }

  static String summarizeStages(List<SourceCheckStageReport> stages) {
    if (stages.isEmpty) return '';
    return stages.map((stage) {
      final status = stage.ok ? 'OK' : 'FAIL';
      final elapsed = stage.elapsedMs <= 0 ? '' : ' ${stage.elapsedMs}ms';
      final failure = stage.failureClass == null
          ? ''
          : ' ${failureLabel(stage.failureClass!)}';
      return '${stage.stageName}:$status$failure$elapsed';
    }).join(' | ');
  }
}
