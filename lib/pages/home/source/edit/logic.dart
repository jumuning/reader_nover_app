import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../app/database/dao/book_source_dao.dart';
import '../../../../app/database/drift/app_database.dart' as db;
import '../../../../util/log_utils.dart';
import '../../../../app/service/source/source_test_service.dart';
import 'form_schema.dart';
import 'state.dart';

class BookSourceEditLogic extends GetxController {
  BookSourceEditLogic({
    Future<void> Function(db.BookSource source)? onOpenSourceLogin,
  }) : _onOpenSourceLogin = onOpenSourceLogin;

  final BookSourceEditState state = BookSourceEditState();
  final db.AppDatabase _database = db.AppDatabase.instance;
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _database);
  final Future<void> Function(db.BookSource source)? _onOpenSourceLogin;

  /// 统一管理所有 TextEditingController，确保 dispose 时全部释放
  final List<TextEditingController> _controllers = [];
  final Map<BookSourceEditFieldKey, TextEditingController> _controllerMap = {};

  TextEditingController _c([String text = '']) {
    final c = TextEditingController(text: text);
    _controllers.add(c);
    return c;
  }

  TextEditingController controllerFor(BookSourceEditFieldKey key) {
    final controller = _controllerMap[key];
    if (controller == null) {
      throw StateError('未找到字段控制器: $key');
    }
    return controller;
  }

  String textOf(BookSourceEditFieldKey key) => controllerFor(key).text;

  /// 初始化书源数据
  void initSource(db.BookSource source) {
    state.source = source;
    state.enabled = source.enabled;
    state.enabledExplore = source.enabledExplore ?? true;
    _initControllers();
    loadRules();
  }

  void _initControllers() {
    _disposeControllers();

    for (final field in bookSourceEditFields) {
      final initialText = bookSourceFieldReaders[field.key]?.call(state.source);
      _controllerMap[field.key] = _c(initialText ?? '');
    }
  }

  /// 加载规则数据
  Future<void> loadRules() async {
    try {
      final sourceId = state.source.id;

      // 并行加载所有规则
      final results = await Future.wait([
        (_database.select(_database.ruleSearchs)
              ..where((t) => t.bookSourceId.equals(sourceId)))
            .getSingleOrNull(),
        (_database.select(_database.ruleTocs)
              ..where((t) => t.bookSourceId.equals(sourceId)))
            .getSingleOrNull(),
        (_database.select(_database.ruleContents)
              ..where((t) => t.bookSourceId.equals(sourceId)))
            .getSingleOrNull(),
        (_database.select(_database.ruleBookInfos)
              ..where((t) => t.bookSourceId.equals(sourceId)))
            .getSingleOrNull(),
        (_database.select(_database.ruleExplores)
              ..where((t) => t.bookSourceId.equals(sourceId)))
            .getSingleOrNull(),
      ]);

      state.ruleSearch = results[0] as db.RuleSearch?;
      state.ruleToc = results[1] as db.RuleToc?;
      state.ruleContent = results[2] as db.RuleContent?;
      state.ruleBookInfo = results[3] as db.RuleBookInfo?;
      state.ruleExplore = results[4] as db.RuleExplore?;

      _fillControllers();
      state.isLoading = false;
      update();
    } catch (e) {
      LogUtils.e('加载规则失败: $e');
      state.isLoading = false;
      update();
    }
  }

  void _fillControllers() {
    _applyRuleValues(state.ruleSearch, bookSourceSearchRuleReaders);
    _applyRuleValues(state.ruleToc, bookSourceTocRuleReaders);
    _applyRuleValues(state.ruleContent, bookSourceContentRuleReaders);
    _applyRuleValues(state.ruleBookInfo, bookSourceBookInfoRuleReaders);
    _applyRuleValues(state.ruleExplore, bookSourceExploreRuleReaders);
  }

  void _applyRuleValues<T>(
    T? rule,
    Map<BookSourceEditFieldKey, BookSourceEditValueReader<T>> readers,
  ) {
    if (rule == null) return;

    for (final entry in readers.entries) {
      controllerFor(entry.key).text = entry.value(rule) ?? '';
    }
  }

  /// 切换启用状态
  void toggleEnabled(bool value) {
    state.enabled = value;
    update();
  }

  void toggleEnabledExplore(bool value) {
    state.enabledExplore = value;
    update();
  }

  /// 保存书源
  Future<void> saveSource() async {
    if (state.isSaving) return;

    state.isSaving = true;
    update();

    try {
      final sourceId = state.source.id;

      // 更新书源基本信息
      await _bookSourceDao.updateById(
        sourceId: sourceId,
        source: db.BookSourcesCompanion(
          bookSourceName:
              drift.Value(textOf(BookSourceEditFieldKey.sourceName)),
          bookSourceUrl: drift.Value(textOf(BookSourceEditFieldKey.sourceUrl)),
          bookSourceGroup: _textValueOf(BookSourceEditFieldKey.sourceGroup),
          bookSourceComment: _textValueOf(BookSourceEditFieldKey.sourceComment),
          searchUrl: _textValueOf(BookSourceEditFieldKey.searchUrl),
          exploreUrl: _textValueOf(BookSourceEditFieldKey.exploreUrl),
          header: _textValueOf(BookSourceEditFieldKey.header),
          loginUrl: _textValueOf(BookSourceEditFieldKey.loginUrl),
          concurrentRate: _textValueOf(BookSourceEditFieldKey.concurrentRate),
          respondTime: _intValueOf(BookSourceEditFieldKey.respondTime),
          loginUi: _textValueOf(BookSourceEditFieldKey.loginUi),
          loginCheckJs: _textValueOf(BookSourceEditFieldKey.loginCheckJs),
          coverDecodeJs: _textValueOf(BookSourceEditFieldKey.coverDecodeJs),
          variableComment: _textValueOf(BookSourceEditFieldKey.variableComment),
          exploreScreen: _textValueOf(BookSourceEditFieldKey.exploreScreen),
          enabled: drift.Value(state.enabled),
          enabledExplore: drift.Value(state.enabledExplore),
        ),
      );

      // 保存搜索规则
      await _saveSearchRule(sourceId);
      // 保存目录规则
      await _saveTocRule(sourceId);
      // 保存正文规则
      await _saveContentRule(sourceId);
      // 保存书籍信息规则
      await _saveBookInfoRule(sourceId);
      // 保存发现规则
      await _saveExploreRule(sourceId);

      Get.snackbar('成功', '书源保存成功', snackPosition: SnackPosition.BOTTOM);
      LogUtils.d('书源保存成功: ${textOf(BookSourceEditFieldKey.sourceName)}');
    } catch (e) {
      LogUtils.e('保存书源失败: $e');
      Get.snackbar('错误', '保存失败: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      state.isSaving = false;
      update();
    }
  }

  Future<void> _saveSearchRule(int sourceId) async {
    await _database.into(_database.ruleSearchs).insertOnConflictUpdate(
          _buildRuleSearchCompanion(sourceId),
        );
  }

  Future<void> _saveTocRule(int sourceId) async {
    await _database.into(_database.ruleTocs).insertOnConflictUpdate(
          _buildRuleTocCompanion(sourceId),
        );
  }

  Future<void> _saveContentRule(int sourceId) async {
    await _database.into(_database.ruleContents).insertOnConflictUpdate(
          _buildRuleContentCompanion(sourceId),
        );
  }

  Future<void> _saveBookInfoRule(int sourceId) async {
    await _database.into(_database.ruleBookInfos).insertOnConflictUpdate(
          _buildRuleBookInfoCompanion(sourceId),
        );
  }

  Future<void> _saveExploreRule(int sourceId) async {
    await _database.into(_database.ruleExplores).insertOnConflictUpdate(
          _buildRuleExploreCompanion(sourceId),
        );
  }

  db.RuleSearchsCompanion _buildRuleSearchCompanion(int sourceId) {
    return db.RuleSearchsCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      bookList: _textValueOf(BookSourceEditFieldKey.searchBookList),
      name: _textValueOf(BookSourceEditFieldKey.searchName),
      author: _textValueOf(BookSourceEditFieldKey.searchAuthor),
      bookUrl: _textValueOf(BookSourceEditFieldKey.searchBookUrl),
      coverUrl: _textValueOf(BookSourceEditFieldKey.searchCoverUrl),
      intro: _textValueOf(BookSourceEditFieldKey.searchIntro),
      kind: _textValueOf(BookSourceEditFieldKey.searchKind),
      lastChapter: _textValueOf(BookSourceEditFieldKey.searchLastChapter),
      wordCount: _textValueOf(BookSourceEditFieldKey.searchWordCount),
      tocUrl: _textValueOf(BookSourceEditFieldKey.searchTocUrl),
      checkKeyWord: _textValueOf(BookSourceEditFieldKey.searchCheckKeyword),
      updateTime: _textValueOf(BookSourceEditFieldKey.searchUpdateTime),
    );
  }

  db.RuleTocsCompanion _buildRuleTocCompanion(int sourceId) {
    return db.RuleTocsCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      chapterList: _textValueOf(BookSourceEditFieldKey.tocChapterList),
      chapterName: _textValueOf(BookSourceEditFieldKey.tocChapterName),
      chapterUrl: _textValueOf(BookSourceEditFieldKey.tocChapterUrl),
      nextTocUrl: _textValueOf(BookSourceEditFieldKey.tocNextTocUrl),
      preUpdateJs: _textValueOf(BookSourceEditFieldKey.tocPreUpdateJs),
      formatJs: _textValueOf(BookSourceEditFieldKey.tocFormatJs),
      isVolume: _textValueOf(BookSourceEditFieldKey.tocIsVolume),
      isVip: _textValueOf(BookSourceEditFieldKey.tocIsVip),
      isPay: _textValueOf(BookSourceEditFieldKey.tocIsPay),
      updateTime: _textValueOf(BookSourceEditFieldKey.tocUpdateTime),
    );
  }

  db.RuleContentsCompanion _buildRuleContentCompanion(int sourceId) {
    return db.RuleContentsCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      content: _textValueOf(BookSourceEditFieldKey.contentBody),
      title: _textValueOf(BookSourceEditFieldKey.contentTitle),
      nextContentUrl: _textValueOf(BookSourceEditFieldKey.contentNextUrl),
      webJs: _textValueOf(BookSourceEditFieldKey.contentWebJs),
      sourceRegex: _textValueOf(BookSourceEditFieldKey.contentSourceRegex),
      replaceRegex: _textValueOf(BookSourceEditFieldKey.contentReplaceRegex),
      imageStyle: _textValueOf(BookSourceEditFieldKey.contentImageStyle),
      imageDecode: _textValueOf(BookSourceEditFieldKey.contentImageDecode),
      payAction: _textValueOf(BookSourceEditFieldKey.contentPayAction),
    );
  }

  db.RuleBookInfosCompanion _buildRuleBookInfoCompanion(int sourceId) {
    return db.RuleBookInfosCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      init: _textValueOf(BookSourceEditFieldKey.bookInfoInit),
      name: _textValueOf(BookSourceEditFieldKey.bookInfoName),
      author: _textValueOf(BookSourceEditFieldKey.bookInfoAuthor),
      coverUrl: _textValueOf(BookSourceEditFieldKey.bookInfoCoverUrl),
      intro: _textValueOf(BookSourceEditFieldKey.bookInfoIntro),
      kind: _textValueOf(BookSourceEditFieldKey.bookInfoKind),
      tocUrl: _textValueOf(BookSourceEditFieldKey.bookInfoTocUrl),
      wordCount: _textValueOf(BookSourceEditFieldKey.bookInfoWordCount),
      lastChapter: _textValueOf(BookSourceEditFieldKey.bookInfoLastChapter),
      lastReadChapter:
          _textValueOf(BookSourceEditFieldKey.bookInfoLastReadChapter),
      canReName: _textValueOf(BookSourceEditFieldKey.bookInfoCanRename),
      downloadUrls: _textValueOf(BookSourceEditFieldKey.bookInfoDownloadUrls),
      updateTime: _textValueOf(BookSourceEditFieldKey.bookInfoUpdateTime),
    );
  }

  db.RuleExploresCompanion _buildRuleExploreCompanion(int sourceId) {
    return db.RuleExploresCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      bookList: _textValueOf(BookSourceEditFieldKey.exploreBookList),
      name: _textValueOf(BookSourceEditFieldKey.exploreName),
      author: _textValueOf(BookSourceEditFieldKey.exploreAuthor),
      bookUrl: _textValueOf(BookSourceEditFieldKey.exploreBookUrl),
      coverUrl: _textValueOf(BookSourceEditFieldKey.exploreCoverUrl),
      intro: _textValueOf(BookSourceEditFieldKey.exploreIntro),
      kind: _textValueOf(BookSourceEditFieldKey.exploreKind),
      lastChapter: _textValueOf(BookSourceEditFieldKey.exploreLastChapter),
      wordCount: _textValueOf(BookSourceEditFieldKey.exploreWordCount),
    );
  }

  String? _nullableTextOf(BookSourceEditFieldKey key) {
    final text = textOf(key).trim();
    return text.isEmpty ? null : text;
  }

  int? _nullableIntOf(BookSourceEditFieldKey key) {
    final text = textOf(key).trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  drift.Value<String?> _textValueOf(BookSourceEditFieldKey key) {
    return drift.Value(_nullableTextOf(key));
  }

  drift.Value<int?> _intValueOf(BookSourceEditFieldKey key) {
    return drift.Value(_nullableIntOf(key));
  }

  /// 测试书源 - 真实网络校验
  /// 流程: 搜索 → 详情 → 目录 → 正文
  Future<void> testSource() async {
    if (state.isTesting) return;

    state.isTesting = true;
    state.testResults = [];
    update();

    // 先保存当前编辑内容再测试
    try {
      await saveSource();
    } catch (e) {
      _upsertTestResult('保存书源', TestStatus.error, '保存失败: $e');
      state.isTesting = false;
      update();
      return;
    }

    // 重新从数据库读取最新的书源
    final source = await _bookSourceDao.findById(state.source.id);

    if (source == null) {
      _upsertTestResult('书源读取', TestStatus.error, '书源不存在');
      state.isTesting = false;
      update();
      return;
    }

    try {
      await SourceTestService.run(
        source,
        onReport: (report) {
          if (report.error != null) {
            LogUtils.e('书源测试失败: ${report.error!.formatForLog()}');
          }
          _upsertTestResult(
            report.title,
            _mapTestStatus(report.status),
            report.message,
            detail: report.detail,
            elapsed: report.elapsed,
          );
        },
      );
    } catch (e) {
      LogUtils.e('测试书源失败: $e');
      _upsertTestResult('测试异常', TestStatus.error, e.toString());
    } finally {
      state.isTesting = false;
      update();
    }
  }

  Future<void> loginCurrentSource() async {
    if (state.isSaving || state.isTesting) return;

    final currentLoginUrl = textOf(BookSourceEditFieldKey.loginUrl).trim();
    final currentLoginUi = textOf(BookSourceEditFieldKey.loginUi).trim();
    if (currentLoginUrl.isEmpty && currentLoginUi.isEmpty) {
      Get.snackbar(
        '书源登录',
        '未配置 loginUrl 或 loginUi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 先保存，确保 loginUrl/jsLib 是最新编辑内容。
    await saveSource();
    if (state.isSaving) return;

    final source = await _bookSourceDao.findById(state.source.id);
    if (source == null) {
      Get.snackbar('书源登录', '书源不存在', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_onOpenSourceLogin != null) {
      await _onOpenSourceLogin(source);
    } else {
      Get.snackbar(
        '书源登录',
        '请从书源列表进入后再登录',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _upsertTestResult(String title, TestStatus status, String message,
      {String? detail, int? elapsed}) {
    final index = state.testResults.indexWhere((r) => r.title == title);
    final result = TestResult(
      title: title,
      status: status,
      message: message,
      detail: detail,
      elapsed: elapsed,
    );
    if (index == -1) {
      state.testResults.add(result);
    } else {
      state.testResults[index] = result;
    }
    update();
  }

  TestStatus _mapTestStatus(SourceTestStatus status) {
    switch (status) {
      case SourceTestStatus.testing:
        return TestStatus.testing;
      case SourceTestStatus.success:
        return TestStatus.success;
      case SourceTestStatus.warning:
        return TestStatus.warning;
      case SourceTestStatus.error:
        return TestStatus.error;
    }
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    _controllerMap.clear();
  }
}
