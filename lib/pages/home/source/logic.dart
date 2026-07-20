import 'dart:async';

import 'package:get/get.dart';
import 'package:reader_nover/util/log_utils.dart';
import '../../../app/database/drift/app_database.dart';
import 'controllers/source_check_controller.dart';
import 'controllers/source_diagnostics_export_controller.dart';
import 'controllers/source_import_export_controller.dart';
import 'controllers/source_list_controller.dart';
import 'controllers/source_login_controller.dart';
import 'state.dart';

class SourceLogic extends GetxController {
  final SourceState state = SourceState();
  final AppDatabase _db = AppDatabase.instance;
  late final SourceListController _listController;
  late final SourceImportExportController _importExportController;
  late final SourceLoginController _loginController;
  late final SourceCheckController _checkController;
  late final SourceDiagnosticsExportController _diagnosticsExportController;
  final Map<int, String> _sourceCheckKeywords = <int, String>{};

  @override
  void onReady() {
    super.onReady();
    _listController = SourceListController(
      state: state,
      database: _db,
      sourceCheckKeywords: _sourceCheckKeywords,
      onUpdate: update,
    );
    _importExportController = SourceImportExportController(
      database: _db,
      sourceCheckKeywords: _sourceCheckKeywords,
      onRefreshSources: refreshSources,
    );
    _loginController = const SourceLoginController();
    _diagnosticsExportController = SourceDiagnosticsExportController();
    _checkController = SourceCheckController(
      state: state,
      database: _db,
      sourceCheckKeywords: _sourceCheckKeywords,
      onUpdate: update,
      onRefreshSources: refreshSources,
    );
    init();
  }

  @override
  void onClose() {
    _checkController.dispose();
    super.onClose();
  }

  Future<void> init() async {
    try {
      await _importExportController.initializeBuiltInSourcesIfNeeded();
      await _importExportController.rebuildSourceCheckKeywords();
      await refreshSources();
      getAllSources();
    } catch (e) {
      LogUtils.e('导入书源失败: $e');
    }
  }

  /// 获取书源列表
  void getAllSources() {
    _listController.getAllSources();
  }

  /// 获取禁用的书源
  void getDisabledSources() {
    _listController.getDisabledSources();
  }

  /// 获取启用的书源
  void getEnabledSources() {
    _listController.getEnabledSources();
  }

  void searchSources(String keyword) {
    _listController.searchSources(keyword);
  }

  void filterByGroup(String? group) {
    _listController.filterByGroup(group);
  }

  /// 展开/收起书源搜索栏；收起时清空关键词。
  void toggleSearchBar() {
    final next = !state.isSearchBarVisible;
    state.isSearchBarVisible = next;
    if (!next && state.searchKeyword.isNotEmpty) {
      searchSources('');
    }
    update();
  }

  void openSearchBar() {
    if (state.isSearchBarVisible) return;
    state.isSearchBarVisible = true;
    update();
  }

  List<SourceGroupInfo> getGroupInfos() {
    return _listController.getGroupInfos();
  }

  void changeShowType(ShowType type) {
    _listController.changeShowType(type);
  }

  Future<void> refreshSources() async {
    await _listController.refreshSources();
  }

  Future<void> toggleSource(BookSource source, bool enabled) async {
    await _listController.toggleSource(source, enabled);
  }

  Future<void> deleteSource(BookSource source) async {
    await _listController.deleteSource(source);
  }

  void handleMenuAction(String action) {
    switch (action) {
      case 'export_check_diagnostics':
        _diagnosticsExportController.exportCheckDiagnostics();
        break;
      default:
        _importExportController.handleMenuAction(action);
    }
  }

  /// 扫描二维码导入书源
  Future<void> scanQrCodeImport() async {
    await _importExportController.scanQrCodeImport();
  }

  /// 网址导入书源
  Future<void> urlImport() async {
    await _importExportController.urlImport();
  }

  Future<void> openSourceLogin(BookSource source) async {
    await _loginController.openSourceLogin(source);
  }

  // 批量选择相关
  void toggleSelectionMode() {
    _listController.toggleSelectionMode();
  }

  void toggleSelection(int id) {
    _listController.toggleSelection(id);
  }

  void selectAll() {
    _listController.selectAll();
  }

  void clearSelection() {
    _listController.clearSelection();
  }

  Future<void> enableSelected() async {
    await _listController.enableSelected();
  }

  Future<void> disableSelected() async {
    await _listController.disableSelected();
  }

  Future<void> deleteSelected() async {
    await _listController.deleteSelected();
  }

  Future<void> addSelectedToGroup(String group) async {
    await _listController.addSelectedToGroup(group);
  }

  Future<void> removeSelectedFromGroup(String group) async {
    await _listController.removeSelectedFromGroup(group);
  }

  Future<void> renameGroup(String oldGroup, String newGroup) async {
    await _listController.renameGroup(oldGroup, newGroup);
  }

  Future<void> deleteGroup(String group) async {
    await _listController.deleteGroup(group);
  }

  Future<void> addUngroupedToGroup(String group) async {
    await _listController.addUngroupedToGroup(group);
  }

  // 排序功能
  void changeSortType(SortType type) {
    _listController.changeSortType(type);
  }

  // 测试书源
  Future<void> testSource(BookSource source) async {
    await _checkController.testSource(source);
  }

  /// 批量校验选中的书源
  Future<void> testSelectedSources() async {
    await _checkController.testSelectedSources();
  }

  Future<CheckSourceConfig> getCheckConfig() async {
    return _checkController.getCheckConfig();
  }

  Future<void> saveCheckConfig(CheckSourceConfig config) async {
    await _checkController.saveCheckConfig(config);
  }

  /// 停止批量校验
  void stopChecking() {
    _checkController.stopChecking();
  }
}
