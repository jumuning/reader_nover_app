import 'package:get/get.dart';

import '../../app/theme/app_theme_controller.dart';
import '../../pages/book_change/logic.dart';
import '../../pages/book_change/view.dart';
import '../../pages/book_detail/logic.dart';
import '../../pages/book_detail/view.dart';
import '../../pages/book_read/logic.dart';
import '../../pages/book_read/view.dart';
import '../../pages/book_search/logic.dart';
import '../../pages/book_search/view.dart';
import '../../pages/home/binding.dart';
import '../../pages/home/view.dart';
import 'route_args.dart';
import 'app_routes.dart';

abstract class AppPages {
  static List<GetPage<dynamic>> pages({
    required AppThemeController themeController,
  }) {
    return [
      GetPage(
        name: AppRoutes.home,
        page: () => const HomePage(),
        binding: HomeBinding(
          onThemeModeChanged: themeController.setThemeMode,
          onThemePaletteChanged: themeController.setPalette,
          onReloadThemeAsset: themeController.reloadFromAsset,
        ),
      ),
      GetPage(
        name: AppRoutes.bookSearch,
        page: () {
          final args = Get.arguments;
          final pageArgs =
              args is BookSearchArgs ? args : const BookSearchArgs();
          return BookSearchPage(
            logic: BookSearchLogic(
              onRefreshBookshelf: pageArgs.onRefreshBookshelf,
            ),
          );
        },
      ),
      GetPage(
        name: AppRoutes.bookDetail,
        page: () => BookDetailPage(
          logic: BookDetailLogic(
            args: Get.arguments as BookDetailArgs,
          ),
        ),
      ),
      GetPage(
        name: AppRoutes.bookRead,
        page: () => BookReadPage(
          logic: BookReadLogic(
            args: Get.arguments as BookReadArgs,
          ),
        ),
      ),
      GetPage(
        name: AppRoutes.bookChange,
        page: () => BookChangePage(
          logic: BookChangeLogic(
            args: Get.arguments as BookChangeArgs,
          ),
        ),
      ),
    ];
  }
}
