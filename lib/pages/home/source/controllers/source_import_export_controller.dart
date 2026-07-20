import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/database/dao/book_source_dao.dart';
import '../../../../app/database/drift/app_database.dart';
import '../../../../util/log_utils.dart';
import '../dto/book_source_dto.dart';

class SourceImportExportController {
  SourceImportExportController({
    required AppDatabase database,
    required Map<int, String> sourceCheckKeywords,
    required this.onRefreshSources,
  })  : _database = database,
        _sourceCheckKeywords = sourceCheckKeywords;

  final AppDatabase _database;
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _database);
  final Map<int, String> _sourceCheckKeywords;
  final Future<void> Function() onRefreshSources;

  Future<void> initializeBuiltInSourcesIfNeeded() async {
    final hasData = await _bookSourceDao.hasAny();
    if (hasData) return;

    final sourceJson = await _loadSourceJson();
    final validateResult = SourceImportExportValidator.validate(sourceJson);
    if (!validateResult.isValid) {
      LogUtils.w('内置书源解析失败: ${validateResult.error}');
      return;
    }

    var initCount = 0;
    for (final source in validateResult.sources ?? const <dynamic>[]) {
      if (source is! Map) continue;
      final importResult =
          await _importSingleSource(Map<String, dynamic>.from(source));
      if (importResult != _ImportResult.skipped) {
        initCount++;
      }
    }
    LogUtils.d('首次初始化内置书源完成: $initCount 个');
  }

  Future<void> rebuildSourceCheckKeywords() async {
    _sourceCheckKeywords.clear();
    final rules = await _database.select(_database.ruleSearchs).get();
    for (final rule in rules) {
      final checkKeyword = rule.checkKeyWord?.trim();
      if (checkKeyword == null || checkKeyword.isEmpty) continue;
      _sourceCheckKeywords[rule.bookSourceId] = checkKeyword;
    }
  }

  void handleMenuAction(String action) {
    switch (action) {
      case 'import':
        importSources();
        break;
      case 'export':
        exportSources();
        break;
    }
  }

  Future<void> importSources() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      String jsonStr;
      if (file.bytes != null) {
        jsonStr = utf8.decode(file.bytes!, allowMalformed: true);
      } else if (file.path != null) {
        jsonStr = await File(file.path!).readAsString();
      } else {
        throw Exception('未读取到文件内容');
      }

      await handleImportPayload(jsonStr);
    } catch (e) {
      LogUtils.e('本地导入书源失败: $e');
      Get.snackbar(
        '导入失败',
        '$e',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> scanQrCodeImport() async {
    Get.to(() => _QrScannerPage(onScanned: handleImportPayload));
  }

  Future<void> urlImport() async {
    // 弹窗关闭动画期间 TextField 仍可能持有 controller，不能立刻 dispose
    final controller = TextEditingController();
    var disposed = false;
    void disposeControllerLater() {
      if (disposed) return;
      disposed = true;
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        controller.dispose();
      });
    }

    try {
      final result = await Get.dialog<String>(
        Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.link_rounded, size: 22),
                    SizedBox(width: 8),
                    Text(
                      '网址导入',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '请输入书源的完整网址，用于快速导入书源。',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.url,
                  autofocus: true,
                  enableInteractiveSelection: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    final text = value.trim();
                    if (text.isEmpty) return;
                    Get.back(result: text);
                  },
                  decoration: InputDecoration(
                    hintText:
                        'https://www.yckceo.com/yuedu/shuyuan/json/id/6803.json',
                    prefixIcon: const Icon(Icons.public),
                    suffixIcon: IconButton(
                      tooltip: '粘贴',
                      icon: const Icon(Icons.content_paste_rounded),
                      onPressed: () => _pasteClipboardInto(controller),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(result: null),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;
                          Get.back(result: text);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('导入'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );

      // 用户取消 / 点遮罩关闭：安静返回，不提示错误
      if (result == null || result.trim().isEmpty) {
        return;
      }

      final url = result.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        Get.snackbar(
          '格式错误',
          '请输入有效的网址',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      var loadingClosed = false;
      void closeLoading() {
        if (loadingClosed) return;
        loadingClosed = true;
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      }

      try {
        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 15);
        dio.options.receiveTimeout = const Duration(seconds: 30);

        final response = await dio.get(url);
        closeLoading();

        final jsonData = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        await handleImportPayload(jsonData);
      } on DioException catch (e) {
        closeLoading();
        var errorMsg = '网络请求失败';
        if (e.type == DioExceptionType.connectionTimeout) {
          errorMsg = '连接超时';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          errorMsg = '响应超时';
        } else if (e.response != null) {
          errorMsg = '服务器错误: ${e.response?.statusCode}';
        }
        Get.snackbar(
          '导入失败',
          errorMsg,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      } catch (e) {
        closeLoading();
        LogUtils.e('网址导入失败: $e');
        Get.snackbar(
          '导入失败',
          '$e',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    } finally {
      disposeControllerLater();
    }
  }

  Future<void> _pasteClipboardInto(TextEditingController controller) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      Get.snackbar('剪贴板为空', '没有可粘贴的文本');
      return;
    }

    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> handleImportPayload(String data) async {
    try {
      final result = SourceImportExportValidator.validate(data);
      if (!result.isValid) {
        Get.snackbar(
          '格式错误',
          result.error ?? '无效的书源格式',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      final sources = result.sources!;
      var insertCount = 0;
      var updateCount = 0;
      var skipCount = 0;

      for (final source in sources) {
        if (source is! Map) {
          skipCount++;
          continue;
        }
        final imported =
            await _importSingleSource(Map<String, dynamic>.from(source));
        switch (imported) {
          case _ImportResult.inserted:
            insertCount++;
            break;
          case _ImportResult.updated:
            updateCount++;
            break;
          case _ImportResult.skipped:
            skipCount++;
            break;
        }
      }

      await rebuildSourceCheckKeywords();
      await onRefreshSources();
      Get.snackbar(
        '导入完成',
        '新增 $insertCount，更新 $updateCount${skipCount > 0 ? '，跳过 $skipCount 个无效' : ''}',
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      LogUtils.e('扫码导入失败: $e');
      Get.snackbar(
        '导入失败',
        '$e',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> exportSources() async {
    try {
      final exportSources = await _buildExportSourcePayload();
      if (exportSources.isEmpty) {
        Get.snackbar(
          '导出书源',
          '当前没有可导出的书源',
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      final jsonText =
          const JsonEncoder.withIndent('  ').convert(exportSources);
      final documentsDir = await getApplicationDocumentsDirectory();
      final fileName = 'book_sources_${_formatTimestamp(DateTime.now())}.json';
      final file = File('${documentsDir.path}/$fileName');
      await file.writeAsString(jsonText);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '书源导出文件（共 ${exportSources.length} 条）',
        subject: 'reader_nover 书源导出',
      );

      Get.snackbar(
        '导出完成',
        '已导出 ${exportSources.length} 个书源\n${file.path}',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      LogUtils.e('导出书源失败: $e');
      Get.snackbar(
        '导出失败',
        '$e',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<String> _loadSourceJson() async {
    try {
      return await rootBundle.loadString('assets/json/source.json');
    } catch (e) {
      LogUtils.e('"加载 source.json 文件失败: $e');
      return '[]';
    }
  }

  Future<_ImportResult> _importSingleSource(Map<String, dynamic> source) async {
    if (!SourceImportExportValidator.isImportableBookSource(source)) {
      return _ImportResult.skipped;
    }

    final dto = BookSourceDto.fromJson(source);
    final sourceUrl = dto.bookSourceUrl.trim();
    if (sourceUrl.isEmpty) return _ImportResult.skipped;

    final existingByUrl = await _bookSourceDao.findByUrl(sourceUrl);
    final sourceId = await _resolveSourceId(
      sourceUrl,
      existing: existingByUrl,
      preferredId: dto.id,
    );

    await _bookSourceDao.upsert(dto.toBookSourcesCompanion(sourceId));

    await _upsertRuleBookInfo(sourceId, dto.toRuleBookInfoCompanion(sourceId));
    await _upsertRuleContent(sourceId, dto.toRuleContentCompanion(sourceId));
    await _upsertRuleSearch(
      sourceId,
      dto.toRuleSearchCompanion(sourceId),
      dto.searchCheckKeyword,
    );
    await _upsertRuleToc(sourceId, dto.toRuleTocCompanion(sourceId));
    await _upsertRuleExplore(sourceId, dto.toRuleExploreCompanion(sourceId));

    return existingByUrl == null
        ? _ImportResult.inserted
        : _ImportResult.updated;
  }

  Future<List<Map<String, dynamic>>> _buildExportSourcePayload() async {
    final results = await Future.wait([
      _bookSourceDao.listAll(),
      _database.select(_database.ruleBookInfos).get(),
      _database.select(_database.ruleContents).get(),
      _database.select(_database.ruleSearchs).get(),
      _database.select(_database.ruleTocs).get(),
      _database.select(_database.ruleExplores).get(),
    ]);

    final sources = results[0] as List<BookSource>;
    final allBookInfos = results[1] as List<RuleBookInfo>;
    final allContents = results[2] as List<RuleContent>;
    final allSearches = results[3] as List<RuleSearch>;
    final allTocs = results[4] as List<RuleToc>;
    final allExplores = results[5] as List<RuleExplore>;

    final bookInfoMap = <int, RuleBookInfo>{};
    for (final item in allBookInfos) {
      bookInfoMap[item.bookSourceId] = item;
    }
    final contentMap = <int, RuleContent>{};
    for (final item in allContents) {
      contentMap[item.bookSourceId] = item;
    }
    final searchMap = <int, RuleSearch>{};
    for (final item in allSearches) {
      searchMap[item.bookSourceId] = item;
    }
    final tocMap = <int, RuleToc>{};
    for (final item in allTocs) {
      tocMap[item.bookSourceId] = item;
    }
    final exploreMap = <int, RuleExplore>{};
    for (final item in allExplores) {
      exploreMap[item.bookSourceId] = item;
    }

    return sources.map((source) {
      final dto = BookSourceDto.fromDatabase(
        source: source,
        ruleBookInfo: bookInfoMap[source.id],
        ruleContent: contentMap[source.id],
        ruleSearch: searchMap[source.id],
        ruleToc: tocMap[source.id],
        ruleExplore: exploreMap[source.id],
      );
      return dto.toJson();
    }).toList();
  }

  String _formatTimestamp(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}_${two(time.hour)}${two(time.minute)}${two(time.second)}';
  }

  Future<int> _resolveSourceId(
    String sourceUrl, {
    BookSource? existing,
    int? preferredId,
  }) async {
    if (existing != null) return existing.id;

    var candidate = preferredId ?? await _nextAvailableSourceId();
    if (candidate <= 0) {
      candidate = await _nextAvailableSourceId();
    }

    while (true) {
      final collision = await _bookSourceDao.findById(candidate);
      if (collision == null || collision.bookSourceUrl == sourceUrl) {
        return candidate;
      }
      candidate++;
    }
  }

  Future<int> _nextAvailableSourceId() async {
    return _bookSourceDao.nextAvailableId();
  }

  Future<void> _upsertRuleBookInfo(
    int sourceId,
    RuleBookInfosCompanion? companion,
  ) async {
    if (companion == null) {
      await (_database.delete(_database.ruleBookInfos)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
      return;
    }

    await _database.into(_database.ruleBookInfos).insertOnConflictUpdate(
          companion,
        );
  }

  Future<void> _upsertRuleContent(
    int sourceId,
    RuleContentsCompanion? companion,
  ) async {
    if (companion == null) {
      await (_database.delete(_database.ruleContents)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
      return;
    }

    await _database.into(_database.ruleContents).insertOnConflictUpdate(
          companion,
        );
  }

  Future<void> _upsertRuleSearch(
    int sourceId,
    RuleSearchsCompanion? companion,
    String? checkKeyword,
  ) async {
    if (companion == null) {
      await (_database.delete(_database.ruleSearchs)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
      _sourceCheckKeywords.remove(sourceId);
      return;
    }

    final normalizedKeyword = checkKeyword?.trim();
    if (normalizedKeyword != null && normalizedKeyword.isNotEmpty) {
      _sourceCheckKeywords[sourceId] = normalizedKeyword;
    } else {
      _sourceCheckKeywords.remove(sourceId);
    }

    await _database.into(_database.ruleSearchs).insertOnConflictUpdate(
          companion,
        );
  }

  Future<void> _upsertRuleToc(
    int sourceId,
    RuleTocsCompanion? companion,
  ) async {
    if (companion == null) {
      await (_database.delete(_database.ruleTocs)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
      return;
    }

    await _database.into(_database.ruleTocs).insertOnConflictUpdate(
          companion,
        );
  }

  Future<void> _upsertRuleExplore(
    int sourceId,
    RuleExploresCompanion? companion,
  ) async {
    if (companion == null) {
      await (_database.delete(_database.ruleExplores)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
      return;
    }

    await _database.into(_database.ruleExplores).insertOnConflictUpdate(
          companion,
        );
  }
}

class SourceImportExportValidator {
  SourceImportExportValidator._();

  static const int maxImportBytes = 5 * 1024 * 1024;
  static const int maxImportEntries = 5000;
  static const int maxFieldBytes = 256 * 1024;
  static const int maxLongFieldBytesPerSource = maxFieldBytes * 5;

  static SourceValidateResult validate(String jsonStr) {
    try {
      if (_exceedsUtf8Bytes(jsonStr, maxImportBytes)) {
        return const SourceValidateResult(
          isValid: false,
          error: '导入数据超过 5 MiB 上限',
        );
      }

      final decoded = jsonDecode(jsonStr);
      late List<dynamic> sources;

      if (decoded is List) {
        sources = decoded;
      } else if (decoded is Map) {
        sources = [decoded];
      } else {
        return const SourceValidateResult(
          isValid: false,
          error: '不支持的数据格式',
        );
      }

      if (sources.isEmpty) {
        return const SourceValidateResult(isValid: false, error: '书源数据为空');
      }

      if (sources.length > maxImportEntries) {
        return SourceValidateResult(
          isValid: false,
          error: '导入条目数 ${sources.length} 超过 $maxImportEntries 上限',
        );
      }

      var bookSourceCount = 0;
      for (final source in sources) {
        if (source is! Map) {
          return const SourceValidateResult(isValid: false, error: '书源格式错误');
        }
        final sourceMap =
            source.map((key, value) => MapEntry(key.toString(), value));

        if (!_looksLikeBookSource(sourceMap)) {
          if (_looksLikeKnownLegadoNonBookEntity(sourceMap)) {
            continue;
          }
          return const SourceValidateResult(isValid: false, error: '书源格式错误');
        }

        final url = _first(sourceMap, const [
          'bookSourceUrl',
          'book_source_url',
          'url',
        ]);
        if (url == null || url.toString().isEmpty) {
          return const SourceValidateResult(isValid: false, error: '缺少书源地址');
        }
        bookSourceCount++;

        final longFieldsBytes = _sourceLongFieldsByteLength(sourceMap);
        if (longFieldsBytes > maxLongFieldBytesPerSource) {
          final name = _first(sourceMap, const [
                'bookSourceName',
                'book_source_name',
                'name',
              ])?.toString().trim() ??
              url.toString();
          return SourceValidateResult(
            isValid: false,
            error:
                "书源 '$name' 字段超长（$longFieldsBytes > $maxLongFieldBytesPerSource bytes）",
          );
        }
      }

      if (bookSourceCount == 0) {
        return const SourceValidateResult(isValid: false, error: '未找到可导入的书源');
      }

      return SourceValidateResult(isValid: true, sources: sources);
    } on FormatException {
      return const SourceValidateResult(isValid: false, error: '无效的 JSON 格式');
    } catch (e) {
      return SourceValidateResult(isValid: false, error: '解析失败: $e');
    }
  }

  static dynamic _first(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value;
    }
    return null;
  }

  static bool isImportableBookSource(Map<String, dynamic> source) {
    final sourceMap =
        source.map((key, value) => MapEntry(key.toString(), value));
    return _looksLikeBookSource(sourceMap);
  }

  static bool _looksLikeBookSource(Map<String, dynamic> source) {
    final url = _first(source, const [
      'bookSourceUrl',
      'book_source_url',
      'url',
    ]);
    if (url == null || url.toString().trim().isEmpty) return false;

    return _hasAnyKey(source, const [
      'bookSourceUrl',
      'book_source_url',
      'bookSourceName',
      'book_source_name',
      'bookSourceGroup',
      'book_source_group',
      'bookSourceType',
      'book_source_type',
      'bookUrlPattern',
      'book_url_pattern',
      'searchUrl',
      'search_url',
      'exploreUrl',
      'explore_url',
      'ruleSearch',
      'rule_search',
      'ruleExplore',
      'rule_explore',
      'ruleBookInfo',
      'rule_book_info',
      'ruleToc',
      'rule_toc',
      'ruleContent',
      'rule_content',
      'ruleReview',
      'rule_review',
    ]);
  }

  static bool _looksLikeKnownLegadoNonBookEntity(Map<String, dynamic> item) {
    if (_hasAnyKey(item, const ['sourceUrl', 'source_url'])) return true;
    if (_hasAnyKey(item, const [
      'pattern',
      'replacement',
      'scopeTitle',
      'scope_title',
      'scopeContent',
      'scope_content',
      'excludeScope',
      'exclude_scope',
    ])) {
      return true;
    }
    if (_hasAnyKey(
        item, const ['urlRule', 'url_rule', 'showRule', 'show_rule'])) {
      return true;
    }
    if (_hasAnyKey(item, const ['sourceUrls', 'source_urls'])) return true;

    final hasName = _hasAnyKey(item, const ['name']);
    if (hasName &&
        _hasAnyKey(
            item, const ['rule', 'example', 'serialNumber', 'serial_number'])) {
      return true;
    }
    if (hasName &&
        _hasAnyKey(item, const ['url', 'type', 'autoUpdate', 'auto_update'])) {
      return true;
    }
    if (_hasAnyKey(item, const ['record', 'readTime', 'read_time'])) {
      return true;
    }
    if (_hasAnyKey(item, const ['origin', 'link'])) return true;
    if (_hasAnyKey(item, const [
      'bookId',
      'book_id',
      'chapterId',
      'chapter_id',
      'summaryUrl',
      'summary_url'
    ])) {
      return true;
    }
    return false;
  }

  static bool _hasAnyKey(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return true;
    }
    return false;
  }

  static int _sourceLongFieldsByteLength(Map<String, dynamic> source) {
    var total = 0;
    for (final keys in _longFieldAliases) {
      total += _valueUtf8ByteLength(_first(source, keys));
    }
    return total;
  }

  static int _valueUtf8ByteLength(dynamic value) {
    if (value == null) return 0;
    if (value is String) return _utf8ByteLength(value);
    if (value is Map || value is List) {
      return _utf8ByteLength(jsonEncode(value));
    }
    return _utf8ByteLength(value.toString());
  }

  static bool _exceedsUtf8Bytes(String value, int limit) {
    var bytes = 0;
    for (final rune in value.runes) {
      bytes += _runeUtf8Bytes(rune);
      if (bytes > limit) return true;
    }
    return false;
  }

  static int _utf8ByteLength(String value) {
    var bytes = 0;
    for (final rune in value.runes) {
      bytes += _runeUtf8Bytes(rune);
    }
    return bytes;
  }

  static int _runeUtf8Bytes(int rune) {
    if (rune <= 0x7f) return 1;
    if (rune <= 0x7ff) return 2;
    if (rune <= 0xffff) return 3;
    return 4;
  }

  static const List<List<String>> _longFieldAliases = [
    ['ruleSearch', 'rule_search'],
    ['ruleExplore', 'rule_explore'],
    ['ruleBookInfo', 'rule_book_info'],
    ['ruleToc', 'rule_toc'],
    ['ruleContent', 'rule_content'],
    ['ruleReview', 'rule_review'],
    ['jsLib', 'js_lib', 'bookSourceJsLib'],
    ['coverDecodeJs', 'cover_decode_js'],
    ['header'],
    ['loginUrl', 'login_url'],
    ['loginUi', 'login_ui'],
    ['loginCheckJs', 'login_check_js'],
    ['searchUrl', 'search_url'],
    ['exploreUrl', 'explore_url'],
    ['bookUrlPattern', 'book_url_pattern'],
    ['concurrentRate', 'concurrent_rate'],
    ['variableComment', 'variable_comment'],
    ['exploreScreen', 'explore_screen'],
  ];
}

class SourceValidateResult {
  const SourceValidateResult({
    required this.isValid,
    this.error,
    this.sources,
  });

  final bool isValid;
  final String? error;
  final List<dynamic>? sources;
}

enum _ImportResult {
  inserted,
  updated,
  skipped,
}

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage({required this.onScanned});

  final Future<void> Function(String) onScanned;

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码导入书源'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                final torchOn = state.torchState == TorchState.on;
                return Icon(torchOn ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_isProcessing) return;
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                _isProcessing = true;
                Get.back();
                widget.onScanned(barcode!.rawValue!);
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              '将二维码放入框内扫描',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
