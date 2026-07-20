import 'dart:async';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reader_nover/app/database/dao/book_source_dao.dart';
import 'package:reader_nover/app/service/source/source_check_diagnostics_store.dart';
import 'package:reader_nover/app/service/source/source_check_policy.dart';
import 'package:reader_nover/app/service/source/source_check_report.dart';
import 'package:reader_nover/app/service/source/source_check_service.dart';
import 'package:reader_nover/util/log_utils.dart';

import '../../../../app/database/drift/app_database.dart';
import '../../../../app/service/source/source_test_service.dart';
import '../state.dart';
import '../widget/source_live_test_dialog.dart';

class SourceCheckController {
  SourceCheckController({
    required this.state,
    required AppDatabase database,
    required Map<int, String> sourceCheckKeywords,
    required this.onUpdate,
    required this.onRefreshSources,
    SourceCheckDiagnosticsStore? diagnosticsStore,
  })  : _database = database,
        _sourceCheckKeywords = sourceCheckKeywords,
        _diagnosticsStore =
            diagnosticsStore ?? SourceCheckDiagnosticsStore.instance;

  final SourceState state;
  final AppDatabase _database;
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _database);
  final Map<int, String> _sourceCheckKeywords;
  final VoidCallback onUpdate;
  final Future<void> Function() onRefreshSources;
  final SourceCheckDiagnosticsStore _diagnosticsStore;

  CancelToken? _checkCancelToken;

  static const String _prefCheckTimeout = 'checkSourceTimeout';
  static const String _prefCheckConcurrency = 'checkSourceConcurrency';
  static const String _prefCheckFastMode = 'checkSourceFastMode';
  static const String _prefCheckSearch = 'checkSearch';
  static const String _prefCheckDiscovery = 'checkDiscovery';
  static const String _prefCheckInfo = 'checkInfo';
  static const String _prefCheckCategory = 'checkCategory';
  static const String _prefCheckContent = 'checkContent';
  static const String _prefCheckKeyword = 'checkSourceKeyword';
  static const Duration _progressUpdateInterval = Duration(milliseconds: 200);

  Duration _checkTimeout =
      const Duration(milliseconds: SourceCheckPolicy.defaultTimeoutMs);
  int _checkConcurrency = SourceCheckPolicy.defaultConcurrency;
  bool _fastCheckMode = true;
  bool _checkSearch = true;
  bool _checkDiscovery = true;
  bool _checkInfo = true;
  bool _checkCategory = true;
  bool _checkContent = true;
  String _checkKeyword = SourceCheckPolicy.defaultKeyword;
  Timer? _progressUpdateTimer;
  bool _pendingProgressUpdate = false;

  Future<void> testSource(BookSource source) async {
    LogUtils.d('测试书源: ${source.bookSourceName}');
    var cancelled = false;
    var dialogClosed = false;
    final cancelToken = CancelToken();
    final results = _initialLiveTestStages();
    final stageReports = <SourceCheckStageReport>[];
    final liveState = ValueNotifier<SourceLiveTestState>(
      SourceLiveTestState(
        sourceName: source.bookSourceName,
        stages: results.values.toList(growable: false),
      ),
    );

    void emitState({
      bool? isRunning,
      bool? isCancelled,
      String? summary,
      SourceCheckFailureClass? failureClass,
    }) {
      if (dialogClosed) return;
      liveState.value = liveState.value.copyWith(
        isRunning: isRunning,
        isCancelled: isCancelled,
        stages: results.values.toList(growable: false),
        summary: summary,
        failureClass: failureClass,
      );
    }

    void cancelLiveTest() {
      if (cancelled) return;
      cancelled = true;
      cancelToken.cancel('用户取消');
      _markPendingStagesCancelled(results);
      emitState(
        isRunning: false,
        isCancelled: true,
        summary:
            '[${SourceCheckReport.failureLabel(SourceCheckFailureClass.cancelled)}] 用户取消测试',
        failureClass: SourceCheckFailureClass.cancelled,
      );
    }

    Get.dialog(
      SourceLiveTestDialog(
        stateListenable: liveState,
        onCancel: cancelLiveTest,
      ),
      barrierDismissible: false,
    ).whenComplete(() {
      dialogClosed = true;
      liveState.dispose();
      if (!cancelled) {
        cancelToken.cancel('测试弹窗关闭');
      }
    });

    try {
      await SourceTestService.run(
        source,
        cancelToken: cancelToken,
        onStageReport: (stageReport) {
          if (cancelled) return;
          stageReports.add(stageReport);
          final title = SourceCheckReport.stageLabel(stageReport.stage);
          results[title] = SourceLiveTestStageResult(
            title: title,
            status: stageReport.ok
                ? SourceLiveTestStageStatus.success
                : SourceLiveTestStageStatus.error,
            message: stageReport.message ?? '',
            elapsed: stageReport.elapsedMs,
            failureClass: stageReport.failureClass,
          );
          emitState(failureClass: stageReport.failureClass);
        },
        onReport: (report) {
          if (cancelled) return;
          final failureClass = _failureClassFromTestReport(report);
          results[report.title] = SourceLiveTestStageResult(
            title: report.title,
            status: _mapLiveTestStatus(report.status),
            message: report.message,
            detail: report.detail,
            elapsed: report.elapsed,
            failureClass: failureClass,
          );
          if (report.error != null) {
            LogUtils.w(
              '书源测试异常: ${source.bookSourceName}\n${report.error!.formatForLog()}',
            );
          }
          emitState(failureClass: failureClass);
        },
      );

      if (cancelled) return;
      final issue = _firstLiveTestIssue(results.values);
      final summary = issue == null
          ? '${source.bookSourceName} 通过基础测试'
          : _liveTestIssueSummary(issue);
      final failureClass = issue?.failureClass;
      emitState(
        isRunning: false,
        summary: summary,
        failureClass: failureClass,
      );
      await _appendSourceCheckDiagnostics(
        mode: SourceCheckDiagnosticMode.live,
        source: source,
        stages: stageReports,
        status: issue == null ? 'success' : 'failed',
        summary: summary,
        failureClass: failureClass,
      );
      cancelToken.cancel('测试结束');
    } catch (error, stackTrace) {
      if (cancelled) return;
      LogUtils.e('测试书源失败: $error\n$stackTrace');
      final failureClass = SourceCheckReport.classifyFailure(error);
      final summary =
          '[${SourceCheckReport.failureLabel(failureClass)}] ${SourceCheckReport.errorSummary(error)}';
      results['测试异常'] = SourceLiveTestStageResult(
        title: '测试异常',
        status: SourceLiveTestStageStatus.error,
        message: SourceCheckReport.errorSummary(error),
        failureClass: failureClass,
      );
      emitState(
        isRunning: false,
        summary: summary,
        failureClass: failureClass,
      );
      await _appendSourceCheckDiagnostics(
        mode: SourceCheckDiagnosticMode.live,
        source: source,
        stages: stageReports,
        status: 'failed',
        summary: summary,
        failureClass: failureClass,
      );
    }
  }

  Future<void> testSelectedSources() async {
    if (state.isChecking) return;

    final ids = state.selectedIds.toList();
    if (ids.isEmpty) return;
    await _loadCheckConfig();

    state.isSelectionMode = false;
    state.selectedIds.clear();

    state.isChecking = true;
    state.checkTotal = ids.length;
    state.checkFinished = 0;
    state.checkCurrentName = null;
    state.checkLatestMessage = '准备校验 ${ids.length} 个书源';
    state.checkResults = {};
    _checkCancelToken = CancelToken();

    for (final id in ids) {
      state.checkResults[id] =
          CheckResult(sourceId: id, state: CheckState.waiting);
    }
    onUpdate();

    final searchWord = SourceCheckPolicy.normalizeKeyword(_checkKeyword);
    final concurrencyLimit = SourceCheckPolicy.normalizeConcurrency(
      _checkConcurrency,
    );

    await _runChecksRolling(ids, searchWord, concurrencyLimit);

    if (state.isChecking) {
      _showCheckResultSnackbar();
      if (state.searchKeyword.isEmpty && _hasInvalidFailureGroup()) {
        state.searchKeyword = '失效';
        state.checkLatestMessage = '发现有失效书源，已自动筛选';
      }
    }

    state.isChecking = false;
    _checkCancelToken = null;
    state.checkCurrentName = null;
    await onRefreshSources();
    _emitProgressUpdate(immediate: true);
  }

  Map<String, SourceLiveTestStageResult> _initialLiveTestStages() {
    return <String, SourceLiveTestStageResult>{
      '搜索功能': const SourceLiveTestStageResult(
        title: '搜索功能',
        status: SourceLiveTestStageStatus.waiting,
        message: '等待搜索',
      ),
      '书籍详情': const SourceLiveTestStageResult(
        title: '书籍详情',
        status: SourceLiveTestStageStatus.waiting,
        message: '等待详情',
      ),
      '目录规则': const SourceLiveTestStageResult(
        title: '目录规则',
        status: SourceLiveTestStageStatus.waiting,
        message: '等待目录',
      ),
      '正文规则': const SourceLiveTestStageResult(
        title: '正文规则',
        status: SourceLiveTestStageStatus.waiting,
        message: '等待正文',
      ),
    };
  }

  void _markPendingStagesCancelled(
    Map<String, SourceLiveTestStageResult> results,
  ) {
    for (final entry in results.entries.toList(growable: false)) {
      final stage = entry.value;
      if (stage.status != SourceLiveTestStageStatus.waiting &&
          stage.status != SourceLiveTestStageStatus.testing) {
        continue;
      }
      results[entry.key] = stage.copyWith(
        status: SourceLiveTestStageStatus.error,
        message: '已取消',
        failureClass: SourceCheckFailureClass.cancelled,
      );
    }
  }

  SourceLiveTestStageResult? _firstLiveTestIssue(
    Iterable<SourceLiveTestStageResult> results,
  ) {
    for (final result in results) {
      if (result.status == SourceLiveTestStageStatus.error ||
          result.status == SourceLiveTestStageStatus.warning) {
        return result;
      }
    }
    return null;
  }

  String _liveTestIssueSummary(SourceLiveTestStageResult issue) {
    final prefix = issue.failureClass == null
        ? ''
        : '[${SourceCheckReport.failureLabel(issue.failureClass!)}] ';
    final message = issue.message.trim().isNotEmpty ? issue.message : '待复查';
    return '$prefix${issue.title}: $message';
  }

  SourceLiveTestStageStatus _mapLiveTestStatus(SourceTestStatus status) {
    switch (status) {
      case SourceTestStatus.testing:
        return SourceLiveTestStageStatus.testing;
      case SourceTestStatus.success:
        return SourceLiveTestStageStatus.success;
      case SourceTestStatus.warning:
        return SourceLiveTestStageStatus.warning;
      case SourceTestStatus.error:
        return SourceLiveTestStageStatus.error;
    }
  }

  SourceCheckFailureClass? _failureClassFromTestReport(
    SourceTestReport report,
  ) {
    final error = report.error;
    if (error == null) return null;
    return SourceCheckReport.classifyFailure(
      error.cause ?? '${error.code} ${error.userMessage}',
      stage: _stageFromTestTitle(report.title),
    );
  }

  SourceCheckStage? _stageFromTestTitle(String title) {
    if (title.contains('搜索')) return SourceCheckStage.search;
    if (title.contains('发现')) return SourceCheckStage.discovery;
    if (title.contains('详情')) return SourceCheckStage.detail;
    if (title.contains('目录')) return SourceCheckStage.toc;
    if (title.contains('正文')) return SourceCheckStage.content;
    return null;
  }

  Future<CheckSourceConfig> getCheckConfig() async {
    await _loadCheckConfig();
    return CheckSourceConfig(
      timeoutSeconds: _checkTimeout.inSeconds,
      concurrency: _checkConcurrency,
      keyword: _checkKeyword,
      fastMode: _fastCheckMode,
      checkSearch: _checkSearch,
      checkDiscovery: _checkDiscovery,
      checkInfo: _checkInfo,
      checkCategory: _checkCategory,
      checkContent: _checkContent,
    );
  }

  Future<void> saveCheckConfig(CheckSourceConfig config) async {
    final timeoutMs =
        SourceCheckPolicy.normalizeTimeoutMs(config.timeoutSeconds * 1000);
    _checkTimeout = Duration(milliseconds: timeoutMs);
    _checkConcurrency = SourceCheckPolicy.normalizeConcurrency(
      config.concurrency,
    );
    _fastCheckMode = config.fastMode;
    _checkKeyword = SourceCheckPolicy.normalizeKeyword(config.keyword);
    final toggles = SourceCheckPolicy.normalizeToggles(
      checkSearch: config.checkSearch,
      checkDiscovery: config.checkDiscovery,
      checkInfo: config.checkInfo,
      checkCategory: config.checkCategory,
      checkContent: config.checkContent,
    );
    _checkSearch = toggles.checkSearch;
    _checkDiscovery = toggles.checkDiscovery;
    _checkInfo = toggles.checkInfo;
    _checkCategory = toggles.checkCategory;
    _checkContent = toggles.checkContent;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefCheckTimeout, timeoutMs);
    await prefs.setInt(_prefCheckConcurrency, _checkConcurrency);
    await prefs.setBool(_prefCheckFastMode, _fastCheckMode);
    await prefs.setString(_prefCheckKeyword, _checkKeyword);
    await prefs.setBool(_prefCheckSearch, _checkSearch);
    await prefs.setBool(_prefCheckDiscovery, _checkDiscovery);
    await prefs.setBool(_prefCheckInfo, _checkInfo);
    await prefs.setBool(_prefCheckCategory, _checkCategory);
    await prefs.setBool(_prefCheckContent, _checkContent);
  }

  void stopChecking() {
    state.isChecking = false;
    _checkCancelToken?.cancel('用户取消');
    _checkCancelToken = null;
    state.checkCurrentName = null;
    state.checkLatestMessage = '已取消校验';
    state.checkResults = state.checkResults.map((sourceId, result) {
      if (result.state != CheckState.waiting &&
          result.state != CheckState.checking) {
        return MapEntry(sourceId, result);
      }
      return MapEntry(
        sourceId,
        CheckResult(
          sourceId: sourceId,
          state: CheckState.failed,
          errorTag: '已取消',
          errorTags: const ['已取消'],
          errorMsg: '用户取消',
          elapsed: result.elapsed,
        ),
      );
    });
    _emitProgressUpdate(immediate: true);
  }

  void dispose() {
    _checkCancelToken?.cancel('销毁控制器');
    _checkCancelToken = null;
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = null;
  }

  void _showCheckResultSnackbar() {
    final successCount = state.checkResults.values
        .where((result) => result.state == CheckState.success)
        .length;
    final failCount = state.checkResults.values
        .where((result) => result.state == CheckState.failed)
        .length;
    final warningCount = state.checkResults.values
        .where((result) => result.state == CheckState.warning)
        .length;

    late String message;
    late Color bgColor;

    if (failCount == 0 && warningCount == 0) {
      message = '校验完成：全部 $successCount 个书源正常';
      bgColor = Colors.green;
    } else if (successCount == 0) {
      if (failCount == 0) {
        message = '校验完成：$warningCount 个书源待复查';
        bgColor = Colors.orange;
      } else if (warningCount == 0) {
        message = '校验完成：全部 $failCount 个书源失效';
        bgColor = Colors.red;
      } else {
        message = '校验完成：$failCount 个失效，$warningCount 个待复查';
        bgColor = Colors.red;
      }
    } else {
      message = '校验完成：$successCount 个正常，$failCount 个失效'
          '${warningCount > 0 ? '，$warningCount 个待复查' : ''}';
      bgColor = Colors.orange;
    }

    Get.snackbar(
      '书源校验',
      message,
      backgroundColor: bgColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      icon: Icon(
        failCount == 0 && warningCount == 0 ? Icons.check_circle : Icons.info,
        color: Colors.white,
      ),
    );
  }

  bool _hasInvalidFailureGroup() {
    for (final result in state.checkResults.values) {
      final groups = result.resolvedGroups ?? result.errorTags;
      if (groups == null) continue;
      if (groups.any((group) => group.contains('失效'))) {
        return true;
      }
    }
    return false;
  }

  Future<void> _runChecksRolling(
    List<int> ids,
    String searchWord,
    int concurrencyLimit,
  ) async {
    final cancelToken = _checkCancelToken;
    if (cancelToken == null) return;

    await const SourceCheckService().runBatch(
      ids: ids,
      searchWord: searchWord,
      concurrencyLimit: concurrencyLimit,
      config: SourceCheckRunConfig(
        timeout: _checkTimeout,
        fastMode: _fastCheckMode,
        checkSearch: _checkSearch,
        checkDiscovery: _checkDiscovery,
        checkInfo: _checkInfo,
        checkCategory: _checkCategory,
        checkContent: _checkContent,
      ),
      cancelToken: cancelToken,
      resolveSource: _bookSourceDao.findById,
      sourceCheckKeywords: _sourceCheckKeywords,
      isActive: () => state.isChecking,
      onSourceStarted: ({required sourceId, required sourceName}) {
        state.checkCurrentName = sourceName;
        state.checkLatestMessage = '$sourceName: 开始校验';
        state.checkResults[sourceId] =
            CheckResult(sourceId: sourceId, state: CheckState.checking);
        _emitProgressUpdate();
      },
      onSourceFinished: ({
        required sourceId,
        required result,
        required message,
      }) async {
        final checkResult = _mapExecutionResult(result);
        state.checkResults[sourceId] = checkResult;
        state.checkLatestMessage = message;
        final source = await _bookSourceDao.findById(sourceId);
        if (source != null) {
          await _appendBatchCheckDiagnostics(source, checkResult);
          await _applyCheckResultToDb(source, checkResult);
        }
        if (state.isChecking) {
          state.checkFinished++;
          _emitProgressUpdate();
        }
      },
    );
  }

  CheckResult _mapExecutionResult(SourceCheckExecutionResult result) {
    return CheckResult(
      sourceId: result.sourceId,
      state: _mapExecutionState(result.state),
      errorTag: result.errorTag,
      errorTags: result.errorTags,
      resolvedGroups: result.resolvedGroups,
      errorMsg: result.errorMsg,
      elapsed: result.elapsed,
      stages: result.stages,
      failureClass: result.failureClass,
    );
  }

  CheckState _mapExecutionState(SourceCheckExecutionState state) {
    switch (state) {
      case SourceCheckExecutionState.success:
        return CheckState.success;
      case SourceCheckExecutionState.warning:
        return CheckState.warning;
      case SourceCheckExecutionState.failed:
        return CheckState.failed;
    }
  }

  void _emitProgressUpdate({bool immediate = false}) {
    if (immediate) {
      _progressUpdateTimer?.cancel();
      _progressUpdateTimer = null;
      _pendingProgressUpdate = false;
      onUpdate();
      return;
    }

    if (_progressUpdateTimer != null) {
      _pendingProgressUpdate = true;
      return;
    }

    onUpdate();
    _progressUpdateTimer = Timer(_progressUpdateInterval, () {
      _progressUpdateTimer = null;
      if (!_pendingProgressUpdate) return;
      _pendingProgressUpdate = false;
      _emitProgressUpdate();
    });
  }

  Future<void> _loadCheckConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final timeoutMs =
        prefs.getInt(_prefCheckTimeout) ?? SourceCheckPolicy.defaultTimeoutMs;
    _checkTimeout = Duration(
      milliseconds: SourceCheckPolicy.normalizeTimeoutMs(timeoutMs),
    );
    _checkConcurrency = SourceCheckPolicy.normalizeConcurrency(
      prefs.getInt(_prefCheckConcurrency),
    );
    _fastCheckMode = prefs.getBool(_prefCheckFastMode) ?? true;

    final toggles = SourceCheckPolicy.normalizeToggles(
      checkSearch: prefs.getBool(_prefCheckSearch) ?? true,
      checkDiscovery: prefs.getBool(_prefCheckDiscovery) ?? true,
      checkInfo: prefs.getBool(_prefCheckInfo) ?? true,
      checkCategory: prefs.getBool(_prefCheckCategory) ?? true,
      checkContent: prefs.getBool(_prefCheckContent) ?? true,
    );
    _checkSearch = toggles.checkSearch;
    _checkDiscovery = toggles.checkDiscovery;
    _checkInfo = toggles.checkInfo;
    _checkCategory = toggles.checkCategory;
    _checkContent = toggles.checkContent;

    final keyword = prefs.getString(_prefCheckKeyword);
    _checkKeyword = SourceCheckPolicy.normalizeKeyword(keyword);
  }

  Future<void> _appendBatchCheckDiagnostics(
    BookSource source,
    CheckResult result,
  ) async {
    if (result.stages.isEmpty) return;
    final summary = result.errorMsg ??
        result.errorTag ??
        SourceCheckReport.summarizeStages(result.stages);
    await _appendSourceCheckDiagnostics(
      mode: SourceCheckDiagnosticMode.batch,
      source: source,
      stages: result.stages,
      status: result.state.name,
      summary: summary,
      elapsedMs: result.elapsed,
      failureClass:
          result.failureClass ?? _failureClassFromStages(result.stages),
    );
  }

  Future<void> _appendSourceCheckDiagnostics({
    required SourceCheckDiagnosticMode mode,
    required BookSource source,
    required List<SourceCheckStageReport> stages,
    String? status,
    String? summary,
    int? elapsedMs,
    SourceCheckFailureClass? failureClass,
  }) async {
    if (stages.isEmpty) return;
    try {
      await _diagnosticsStore.append(
        mode: mode,
        sourceId: source.id,
        sourceName: source.bookSourceName,
        stages: stages,
        status: status,
        summary: summary,
        elapsedMs: elapsedMs,
        failureClass: failureClass ?? _failureClassFromStages(stages),
      );
    } catch (error, stackTrace) {
      LogUtils.w('写入书源校验诊断日志失败: $error\n$stackTrace');
    }
  }

  SourceCheckFailureClass? _failureClassFromStages(
    List<SourceCheckStageReport> stages,
  ) {
    for (final stage in stages.reversed) {
      if (!stage.ok && stage.failureClass != null) {
        return stage.failureClass;
      }
    }
    return null;
  }

  Future<void> _applyCheckResultToDb(
    BookSource source,
    CheckResult result,
  ) async {
    if (result.state == CheckState.warning) {
      return;
    }

    final groups = (result.resolvedGroups ??
            _parseGroups(source.bookSourceGroup).toList(growable: false))
        .where((group) => group.trim().isNotEmpty)
        .map((group) => group.trim())
        .toList(growable: false);

    final group = groups.isEmpty ? null : groups.join(';');
    final comment = _buildSourceCommentAfterCheck(source, result);
    try {
      await _bookSourceDao.updateById(
        sourceId: result.sourceId,
        source: BookSourcesCompanion(
          bookSourceGroup: drift.Value(group),
          respondTime: drift.Value(result.elapsed ?? source.respondTime),
          bookSourceComment: drift.Value(comment),
        ),
      );
    } catch (error, stackTrace) {
      LogUtils.w(
        '写入书源校验结果失败: ${source.bookSourceName}(${source.id}) '
        '$error\n$stackTrace',
      );
    }
  }

  String? _buildSourceCommentAfterCheck(BookSource source, CheckResult result) {
    final current = _removeErrorComment(source.bookSourceComment);
    if (result.state == CheckState.success ||
        result.state == CheckState.warning) {
      return current;
    }

    final message = (result.errorMsg?.trim().isNotEmpty ?? false)
        ? result.errorMsg!.trim()
        : (result.errorTag?.trim().isNotEmpty ?? false)
            ? result.errorTag!.trim()
            : '校验失败';
    final stageSummary = SourceCheckReport.summarizeStages(result.stages);
    final errorLine = stageSummary.isEmpty
        ? '// Error: $message'
        : '// Error: $message\n// CheckStages: $stageSummary';
    if (current == null || current.isEmpty) {
      return errorLine;
    }
    return '$errorLine\n\n$current';
  }

  String? _removeErrorComment(String? comment) {
    if (comment == null || comment.trim().isEmpty) return null;

    final filtered = comment
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('// Error:'))
        .join('\n')
        .trim();

    if (filtered.isEmpty) return null;
    return filtered;
  }

  Set<String> _parseGroups(String? group) {
    if (group == null || group.trim().isEmpty) {
      return <String>{};
    }
    return group
        .split(RegExp(r'[;,，]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
  }
}
