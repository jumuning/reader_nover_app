import 'dart:convert';

import 'package:get/get.dart';
import 'package:reader_nover/app/service/source/explore_screen.dart';
import 'package:reader_nover/app/service/source/source_http.dart';
import 'package:reader_nover/app/service/source/source_variable_store.dart';
import '../../../app/database/dao/book_source_dao.dart';
import '../../../app/database/drift/app_database.dart';
import '../../../util/log_utils.dart';
import 'state.dart';

class StoreLogic extends GetxController {
  final StoreState state = StoreState();
  final AppDatabase _db = AppDatabase.instance;
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _db);

  @override
  void onReady() {
    super.onReady();
    // 仅应用启动后首次加载一次
    loadSources();
  }

  /// 加载书源并解析发现分类。
  ///
  /// - 默认：若已成功加载过，**直接跳过，不再解析**
  /// - [force]：用户手动刷新时才全量重解析
  Future<void> loadSources({bool force = false}) async {
    if (state.isLoading) return;

    // 已解析过且非强制刷新：完全不再解析
    if (state.hasLoaded && !force) {
      LogUtils.d('书城跳过解析：已有缓存');
      return;
    }

    state.isLoading = true;
    update();
    try {
      final sources = await _bookSourceDao.listEnabledExplore();
      state.sources = sources;

      final aliveIds = sources.map((s) => s.id).toSet();
      state.expandedSources.removeWhere((id, _) => !aliveIds.contains(id));

      if (force) {
        state.sourceKinds.clear();
      } else {
        state.sourceKinds.removeWhere((id, _) => !aliveIds.contains(id));
      }

      // 强制刷新：全量；首次：解析全部；已有缓存则上面已 return
      final toParse = force
          ? sources
          : sources
              .where((s) => !state.sourceKinds.containsKey(s.id))
              .toList(growable: false);

      if (toParse.isNotEmpty) {
        LogUtils.d(
          '书城解析分类: force=$force, count=${toParse.length}/${sources.length}',
        );
        const concurrencyLimit = 5;
        for (int i = 0; i < toParse.length; i += concurrencyLimit) {
          final batch = toParse.skip(i).take(concurrencyLimit).toList();
          await Future.wait(batch.map(_parseSourceKinds));
          if (!isClosed) update();
        }
      }

      state.hasLoaded = true;
    } catch (e) {
      LogUtils.e('加载书源失败: $e');
    } finally {
      state.isLoading = false;
      update();
    }
  }

  Future<void> _parseSourceKinds(BookSource source, {int depth = 0}) async {
    try {
      _ensureExploreScreenDefaults(source);
      await _syncExploreScreenVariable(source);
      final selected = state.exploreScreenValues[source.id] ?? const {};
      final sourceHeaders = await SourceHttp.buildSourceHeaders(source);
      final engine = await SourceHttp.newRuleEngine(
        source,
        sourceHeaders: sourceHeaders,
      );
      // Flat keys + whole JSON variable for community explore scripts.
      for (final entry in selected.entries) {
        await engine.setSourceVar(key: entry.key, value: entry.value);
      }
      final kinds = await SourceHttp.runWithWebViewBridge(
        source: source,
        engine: engine,
        sourceHeaders: sourceHeaders,
        parse: () => engine.parseExploreKinds(
          exploreUrl: source.exploreUrl ?? '',
        ),
      );
      final vars = await SourceHttp.snapshotRuleVariables(engine);
      await SourceHttp.persistRuleEngineVariables(source, engine);
      if (_isTruthyFlag(vars['__reader_refresh_explore']) && depth < 2) {
        await engine.setSourceVar(key: '__reader_refresh_explore', value: '');
        await _parseSourceKinds(source, depth: depth + 1);
        return;
      }
      state.sourceKinds[source.id] = kinds
          .map((k) => ExploreKind(
                k.title.trim(),
                (k.url ?? '').trim(),
                styleJson: k.styleJson,
              ))
          .where((k) => k.title.isNotEmpty && k.url.isNotEmpty)
          .toList();
    } catch (e) {
      LogUtils.e('解析书源 ${source.bookSourceName} 发现分类失败: $e');
      state.sourceKinds[source.id] = const <ExploreKind>[];
    }
  }

  /// Merge exploreScreen selections into source variable JSON
  /// (community sources often `JSON.parse(source.getVariable())`).
  Future<void> _syncExploreScreenVariable(BookSource source) async {
    final selected = state.exploreScreenValues[source.id];
    if (selected == null || selected.isEmpty) return;

    final merged = <String, dynamic>{};
    final raw = await SourceVariableStore.get(source.bookSourceUrl);
    if (raw.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          decoded.forEach((key, value) {
            if (key == null) return;
            merged['$key'] = value;
          });
        }
      } catch (_) {}
    }
    selected.forEach((key, value) {
      merged[key] = value;
    });
    await SourceVariableStore.set(
      source.bookSourceUrl,
      const JsonEncoder.withIndent('  ').convert(merged),
    );
  }

  void _ensureExploreScreenDefaults(BookSource source) {
    final fields = ExploreScreenParser.parse(source.exploreScreen);
    state.exploreScreenFields[source.id] = fields;
    final current = Map<String, String>.from(
      state.exploreScreenValues[source.id] ?? const {},
    );
    for (final field in fields) {
      current.putIfAbsent(field.key, () => field.initialValue);
    }
    state.exploreScreenValues[source.id] = current;
  }

  List<ExploreScreenField> exploreScreenFieldsOf(BookSource source) {
    return state.exploreScreenFields[source.id] ??
        ExploreScreenParser.parse(source.exploreScreen);
  }

  String exploreScreenValueOf(BookSource source, String key) {
    return state.exploreScreenValues[source.id]?[key] ?? '';
  }

  /// 更新筛选值并重解析该书源分类。
  Future<void> setExploreScreenValue({
    required BookSource source,
    required String key,
    required String value,
  }) async {
    final map = Map<String, String>.from(
      state.exploreScreenValues[source.id] ?? const {},
    );
    map[key] = value;
    state.exploreScreenValues[source.id] = map;
    state.sourceKinds.remove(source.id);
    update();
    await _parseSourceKinds(source);
  }

  bool _isTruthyFlag(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    return value == '1' || value == 'true' || value == 'yes';
  }

  void toggleSource(int sourceId) {
    state.expandedSources[sourceId] =
        !(state.expandedSources[sourceId] ?? false);
    update();
  }

  void setSearchQuery(String query) {
    state.searchQuery = query;
    update();
  }

  List<BookSource> get filteredSources {
    if (state.searchQuery.isEmpty) return state.sources;
    final query = state.searchQuery.toLowerCase();
    return state.sources
        .where((s) =>
            s.bookSourceName.toLowerCase().contains(query) ||
            (s.bookSourceGroup?.toLowerCase().contains(query) ?? false))
        .toList();
  }
}
