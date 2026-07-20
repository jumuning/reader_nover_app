import 'package:get/get.dart';

import 'book/logic.dart';
import 'setting/logic.dart';
import 'state.dart';

class HomeLogic extends GetxController {
  HomeLogic({
    required this.bookLogic,
    required this.settingLogic,
    Future<void> Function()? onEnterStorePage,
    Future<void> Function()? onEnterBookshelfPage,
  })  : _onEnterStorePage = onEnterStorePage,
        _onEnterBookshelfPage = onEnterBookshelfPage;

  final HomeState state = HomeState();
  final BookLogic bookLogic;
  final SettingLogic settingLogic;
  final Future<void> Function()? _onEnterStorePage;
  final Future<void> Function()? _onEnterBookshelfPage;

  /// 页面切换
  void changePageIndex(int index) {
    if (index == 0 && state.pageIndex != 0) {
      _onEnterBookshelfPage?.call();
    }
    if (index == 1 && state.pageIndex == 2) {
      _onEnterStorePage?.call();
    }
    state.pageIndex = index;
    update();
  }
}
