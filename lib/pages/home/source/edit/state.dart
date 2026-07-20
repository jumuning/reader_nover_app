import '../../../../app/database/drift/app_database.dart' as db;

/// 书源编辑状态
class BookSourceEditState {
  /// 编辑的书源
  late db.BookSource source;

  /// 加载状态
  bool isLoading = true;

  /// 保存状态
  bool isSaving = false;

  /// 测试状态
  bool isTesting = false;

  /// 启用状态
  bool enabled = false;

  /// 是否在发现页启用
  bool enabledExplore = true;

  /// 规则数据
  db.RuleSearch? ruleSearch;
  db.RuleToc? ruleToc;
  db.RuleContent? ruleContent;
  db.RuleBookInfo? ruleBookInfo;
  db.RuleExplore? ruleExplore;

  /// 测试结果
  List<TestResult> testResults = [];
}

/// 测试状态枚举
enum TestStatus { testing, success, warning, error }

/// 测试结果
class TestResult {
  final String title;
  final TestStatus status;
  final String message;

  /// 解析到的数据摘要（如搜索到的书名、章节数等）
  final String? detail;

  /// 耗时（毫秒）
  final int? elapsed;

  TestResult({
    required this.title,
    required this.status,
    required this.message,
    this.detail,
    this.elapsed,
  });

  TestResult copyWith({
    String? title,
    TestStatus? status,
    String? message,
    String? detail,
    int? elapsed,
  }) {
    return TestResult(
      title: title ?? this.title,
      status: status ?? this.status,
      message: message ?? this.message,
      detail: detail ?? this.detail,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}
