import '../../../app/database/drift/app_database.dart' as db;
import '../../../app/service/source/source_check_report.dart';

class SourceState {
  late List<db.BookSource> allSources;
  late List<db.BookSource> enabledSources;
  late List<db.BookSource> disabledSources;
  late List<db.BookSource> showSources;
  late ShowType showType;
  late Set<int> selectedIds;
  late bool isSelectionMode;
  late SortType sortType;
  late String searchKeyword;
  String? groupFilter;

  /// 是否展开书源搜索栏
  bool isSearchBarVisible = false;

  // ===== 批量校验状态 =====
  bool isChecking = false;
  int checkTotal = 0;
  int checkFinished = 0;
  String? checkCurrentName;
  String? checkLatestMessage;

  /// 校验结果: sourceId → CheckResult
  Map<int, CheckResult> checkResults = {};

  SourceState() {
    allSources = [];
    enabledSources = [];
    disabledSources = [];
    showSources = [];
    showType = ShowType.all;
    selectedIds = {};
    isSelectionMode = false;
    sortType = SortType.defaultSort;
    searchKeyword = '';
  }
}

class SourceLiveTestState {
  const SourceLiveTestState({
    required this.sourceName,
    this.isRunning = true,
    this.isCancelled = false,
    this.stages = const <SourceLiveTestStageResult>[],
    this.summary,
    this.failureClass,
  });

  final String sourceName;
  final bool isRunning;
  final bool isCancelled;
  final List<SourceLiveTestStageResult> stages;
  final String? summary;
  final SourceCheckFailureClass? failureClass;

  bool get hasIssue => stages.any(
        (stage) =>
            stage.status == SourceLiveTestStageStatus.warning ||
            stage.status == SourceLiveTestStageStatus.error,
      );

  SourceLiveTestState copyWith({
    bool? isRunning,
    bool? isCancelled,
    List<SourceLiveTestStageResult>? stages,
    String? summary,
    SourceCheckFailureClass? failureClass,
  }) {
    return SourceLiveTestState(
      sourceName: sourceName,
      isRunning: isRunning ?? this.isRunning,
      isCancelled: isCancelled ?? this.isCancelled,
      stages: stages ?? this.stages,
      summary: summary ?? this.summary,
      failureClass: failureClass ?? this.failureClass,
    );
  }
}

class SourceLiveTestStageResult {
  const SourceLiveTestStageResult({
    required this.title,
    required this.status,
    required this.message,
    this.detail,
    this.elapsed,
    this.failureClass,
  });

  final String title;
  final SourceLiveTestStageStatus status;
  final String message;
  final String? detail;
  final int? elapsed;
  final SourceCheckFailureClass? failureClass;

  SourceLiveTestStageResult copyWith({
    SourceLiveTestStageStatus? status,
    String? message,
    String? detail,
    int? elapsed,
    SourceCheckFailureClass? failureClass,
  }) {
    return SourceLiveTestStageResult(
      title: title,
      status: status ?? this.status,
      message: message ?? this.message,
      detail: detail ?? this.detail,
      elapsed: elapsed ?? this.elapsed,
      failureClass: failureClass ?? this.failureClass,
    );
  }
}

enum SourceLiveTestStageStatus { waiting, testing, success, warning, error }

class SourceGroupInfo {
  const SourceGroupInfo({
    required this.name,
    required this.count,
    this.isUngrouped = false,
  });

  final String name;
  final int count;
  final bool isUngrouped;
}

enum ShowType {
  all,
  enabled,
  disabled,
}

enum SortType {
  defaultSort,
  name,
  url,
  weight,
  updateTime,
}

/// 单个书源的校验结果
class CheckResult {
  final int sourceId;
  final CheckState state;
  final String? errorTag; // 主失败标签（用于 UI 简要展示）
  final List<String>? errorTags; // 校验标签全集（用于落库，可能包含非致命标签）
  final List<String>? resolvedGroups; // 本次校验后的完整分组（用于写回 DB）
  final String? errorMsg; // 详细错误信息
  final int? elapsed; // 耗时 ms
  final List<SourceCheckStageReport> stages; // 阶段报告（搜索/发现/详情/目录/正文）
  final SourceCheckFailureClass? failureClass; // 归一化失败类型

  const CheckResult({
    required this.sourceId,
    required this.state,
    this.errorTag,
    this.errorTags,
    this.resolvedGroups,
    this.errorMsg,
    this.elapsed,
    this.stages = const <SourceCheckStageReport>[],
    this.failureClass,
  });
}

enum CheckState { waiting, checking, success, warning, failed }

class CheckSourceConfig {
  final int timeoutSeconds;
  final int concurrency;
  final String keyword;
  final bool fastMode;
  final bool checkSearch;
  final bool checkDiscovery;
  final bool checkInfo;
  final bool checkCategory;
  final bool checkContent;

  const CheckSourceConfig({
    required this.timeoutSeconds,
    required this.concurrency,
    required this.keyword,
    required this.fastMode,
    required this.checkSearch,
    required this.checkDiscovery,
    required this.checkInfo,
    required this.checkCategory,
    required this.checkContent,
  });
}
