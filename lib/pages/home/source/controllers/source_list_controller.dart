import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;

import 'package:reader_nover/app/database/dao/book_source_dao.dart';
import 'package:reader_nover/app/service/local_book/local_book_constants.dart';
import 'package:reader_nover/app/service/source/source_variable_store.dart';

import '../../../../app/database/drift/app_database.dart';
import '../state.dart';

class SourceListController {
  SourceListController({
    required this.state,
    required AppDatabase database,
    required Map<int, String> sourceCheckKeywords,
    required this.onUpdate,
  })  : _database = database,
        _sourceCheckKeywords = sourceCheckKeywords;

  final SourceState state;
  final AppDatabase _database;
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _database);
  final Map<int, String> _sourceCheckKeywords;
  final VoidCallback onUpdate;
  static final RegExp _groupSplitPattern = RegExp(r'[,;，；]');

  void getAllSources() {
    state.showSources = state.allSources;
    state.showType = ShowType.all;
    onUpdate();
  }

  void getDisabledSources() {
    state.showSources = state.disabledSources;
    state.showType = ShowType.disabled;
    onUpdate();
  }

  void getEnabledSources() {
    state.showSources = state.enabledSources;
    state.showType = ShowType.enabled;
    onUpdate();
  }

  void searchSources(String keyword) {
    state.searchKeyword = keyword.trim();
    state.groupFilter = null;
    _updateShowSources();
  }

  void filterByGroup(String? group) {
    final normalized = group?.trim();
    state.groupFilter = normalized == null || normalized.isEmpty
        ? null
        : normalized == '未分组'
            ? '未分组'
            : normalized;
    state.searchKeyword = '';
    // 点分组筛选时自动展开搜索区，便于看到当前分组 Chip
    if (state.groupFilter != null) {
      state.isSearchBarVisible = true;
    }
    _updateShowSources();
  }

  List<BookSource> _baseSourcesForShowType() {
    List<BookSource> baseList;
    switch (state.showType) {
      case ShowType.enabled:
        baseList = state.enabledSources;
        break;
      case ShowType.disabled:
        baseList = state.disabledSources;
        break;
      default:
        baseList = state.allSources;
    }
    return baseList;
  }

  List<BookSource> _filterSources(List<BookSource> sources) {
    final groupFilter = state.groupFilter;
    if (groupFilter != null) {
      if (groupFilter == '未分组') {
        sources = sources
            .where((source) => _parseGroups(source.bookSourceGroup).isEmpty)
            .toList();
      } else {
        sources = sources
            .where((source) =>
                _parseGroups(source.bookSourceGroup).contains(groupFilter))
            .toList();
      }
    }

    final keyword = state.searchKeyword;
    if (keyword.isEmpty) return sources;

    final lowerKeyword = keyword.toLowerCase();
    return sources
        .where((item) =>
            item.bookSourceName.toLowerCase().contains(lowerKeyword) ||
            item.bookSourceUrl.toLowerCase().contains(lowerKeyword) ||
            (item.bookSourceGroup?.toLowerCase().contains(lowerKeyword) ??
                false) ||
            (item.bookSourceComment?.toLowerCase().contains(lowerKeyword) ??
                false))
        .toList();
  }

  void changeShowType(ShowType type) {
    state.showType = type;
    _updateShowSources();
  }

  List<SourceGroupInfo> getGroupInfos() {
    final counts = <String, int>{};
    var ungroupedCount = 0;

    for (final source in state.allSources) {
      final groups = _parseGroups(source.bookSourceGroup);
      if (groups.isEmpty) {
        ungroupedCount++;
        continue;
      }
      for (final group in groups) {
        counts[group] = (counts[group] ?? 0) + 1;
      }
    }

    final groups = counts.entries
        .map((entry) => SourceGroupInfo(name: entry.key, count: entry.value))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (ungroupedCount > 0) {
      groups.insert(
        0,
        SourceGroupInfo(
          name: '未分组',
          count: ungroupedCount,
          isUngrouped: true,
        ),
      );
    }
    return groups;
  }

  Future<void> refreshSources() async {
    final sources = await _bookSourceDao.listAll();
    state.allSources = sources
        .where((item) => !LocalBookConstants.isLocalBookSource(item.id))
        .toList(growable: false);
    state.enabledSources =
        state.allSources.where((item) => item.enabled).toList();
    state.disabledSources =
        state.allSources.where((item) => !item.enabled).toList();
    _updateShowSources();
  }

  Future<void> toggleSource(BookSource source, bool enabled) async {
    if (LocalBookConstants.isLocalBookSource(source.id)) return;
    await _bookSourceDao.updateEnabled(sourceId: source.id, enabled: enabled);
    await refreshSources();
  }

  Future<void> deleteSource(BookSource source) async {
    if (LocalBookConstants.isLocalBookSource(source.id)) return;
    await _deleteSourceById(source.id, sourceUrl: source.bookSourceUrl);
    await refreshSources();
  }

  void toggleSelectionMode() {
    state.isSelectionMode = !state.isSelectionMode;
    if (!state.isSelectionMode) {
      state.selectedIds.clear();
    }
    onUpdate();
  }

  void toggleSelection(int id) {
    if (state.selectedIds.contains(id)) {
      state.selectedIds.remove(id);
    } else {
      state.selectedIds.add(id);
    }
    onUpdate();
  }

  void selectAll() {
    state.selectedIds = state.showSources.map((item) => item.id).toSet();
    onUpdate();
  }

  void clearSelection() {
    state.selectedIds.clear();
    onUpdate();
  }

  Future<void> enableSelected() async {
    final ids = state.selectedIds
        .where((id) => !LocalBookConstants.isLocalBookSource(id))
        .toList();
    if (ids.isEmpty) return;
    await _bookSourceDao.updateEnabledByIds(sourceIds: ids, enabled: true);
    await refreshSources();
    clearSelection();
  }

  Future<void> disableSelected() async {
    final ids = state.selectedIds
        .where((id) => !LocalBookConstants.isLocalBookSource(id))
        .toList();
    if (ids.isEmpty) return;
    await _bookSourceDao.updateEnabledByIds(sourceIds: ids, enabled: false);
    await refreshSources();
    clearSelection();
  }

  Future<void> deleteSelected() async {
    final ids = state.selectedIds
        .where((id) => !LocalBookConstants.isLocalBookSource(id))
        .toList();
    if (ids.isEmpty) return;

    final sources = await _bookSourceDao.findByIds(ids);
    final sourceUrlMap = {
      for (final source in sources) source.id: source.bookSourceUrl
    };
    for (final id in ids) {
      await _deleteSourceById(id, sourceUrl: sourceUrlMap[id]);
    }
    await refreshSources();
    clearSelection();
  }

  Future<void> addSelectedToGroup(String group) async {
    final groupName = group.trim();
    if (groupName.isEmpty || state.selectedIds.isEmpty) return;

    final ids = state.selectedIds
        .where((id) => !LocalBookConstants.isLocalBookSource(id))
        .toList();
    if (ids.isEmpty) return;

    final sources = await _bookSourceDao.findByIds(ids);
    for (final source in sources) {
      final groups = _parseGroups(source.bookSourceGroup);
      if (!groups.contains(groupName)) {
        groups.add(groupName);
      }
      await _updateSourceGroups(source, groups);
    }
    await refreshSources();
  }

  Future<void> removeSelectedFromGroup(String group) async {
    final groupName = group.trim();
    if (groupName.isEmpty || state.selectedIds.isEmpty) return;

    final ids = state.selectedIds
        .where((id) => !LocalBookConstants.isLocalBookSource(id))
        .toList();
    if (ids.isEmpty) return;

    final sources = await _bookSourceDao.findByIds(ids);
    for (final source in sources) {
      final groups = _parseGroups(source.bookSourceGroup)
        ..removeWhere((item) => item == groupName);
      await _updateSourceGroups(source, groups);
    }
    await refreshSources();
  }

  Future<void> renameGroup(String oldGroup, String newGroup) async {
    final from = oldGroup.trim();
    final to = newGroup.trim();
    if (from.isEmpty || from == '未分组' || from == to) return;

    final sources = state.allSources
        .where((source) => _parseGroups(source.bookSourceGroup).contains(from))
        .toList();
    for (final source in sources) {
      final groups = _parseGroups(source.bookSourceGroup);
      final index = groups.indexOf(from);
      if (index == -1) continue;
      if (to.isEmpty) {
        groups.removeAt(index);
      } else {
        groups[index] = to;
        final seen = <String>{};
        groups.removeWhere((group) => !seen.add(group));
      }
      await _updateSourceGroups(source, groups);
    }

    if (state.groupFilter == from) {
      state.groupFilter = to.isEmpty ? null : to;
    }
    await refreshSources();
  }

  Future<void> deleteGroup(String group) async {
    await renameGroup(group, '');
  }

  Future<void> addUngroupedToGroup(String group) async {
    final groupName = group.trim();
    if (groupName.isEmpty) return;

    final sources = state.allSources
        .where((source) => _parseGroups(source.bookSourceGroup).isEmpty)
        .toList();
    for (final source in sources) {
      await _updateSourceGroups(source, <String>[groupName]);
    }
    await refreshSources();
  }

  void changeSortType(SortType type) {
    state.sortType = type;
    _sortSources();
    onUpdate();
  }

  Future<void> deleteSourceByIdForImport(
    int sourceId, {
    String? sourceUrl,
  }) async {
    await _deleteSourceById(sourceId, sourceUrl: sourceUrl);
  }

  void _updateShowSources() {
    state.showSources = _filterSources(_baseSourcesForShowType());
    _sortSources();
    onUpdate();
  }

  Future<void> _deleteSourceById(int sourceId, {String? sourceUrl}) async {
    if (LocalBookConstants.isLocalBookSource(sourceId)) return;
    await _bookSourceDao.deleteWithRules(sourceId);
    _sourceCheckKeywords.remove(sourceId);
    if (sourceUrl != null && sourceUrl.trim().isNotEmpty) {
      await SourceVariableStore.remove(sourceUrl, sourceUrl: sourceUrl);
    }
  }

  void _sortSources() {
    switch (state.sortType) {
      case SortType.name:
        state.showSources
            .sort((a, b) => a.bookSourceName.compareTo(b.bookSourceName));
        break;
      case SortType.url:
        state.showSources
            .sort((a, b) => a.bookSourceUrl.compareTo(b.bookSourceUrl));
        break;
      case SortType.weight:
        state.showSources
            .sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));
        break;
      case SortType.updateTime:
        state.showSources.sort((a, b) {
          final aTime = a.lastUpdateTime ?? '';
          final bTime = b.lastUpdateTime ?? '';
          return bTime.compareTo(aTime);
        });
        break;
      default:
        break;
    }
  }

  List<String> _parseGroups(String? group) {
    if (group == null || group.trim().isEmpty) return <String>[];
    return group
        .split(_groupSplitPattern)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _updateSourceGroups(
    BookSource source,
    List<String> groups,
  ) async {
    final normalized = groups
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    await _bookSourceDao.updateById(
      sourceId: source.id,
      source: BookSourcesCompanion(
        bookSourceGroup:
            drift.Value(normalized.isEmpty ? null : normalized.join(';')),
      ),
    );
  }
}
