import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reader_nover/rust/frb_generated.dart';
import 'app/l10n/generated/l10n.dart';
import 'app/l10n/app_locale_store.dart';
import 'app/theme/app_theme_controller.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/net/http_client.dart';
import 'app/net/webview_service.dart';
import 'app/database/drift/app_database.dart' as db;

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized()是一个静态方法，
  // 它会初始化Flutter的Widgets库。这个方法通常在你的应用程序的main()函数中调用，
  // 特别是在你的应用程序需要在runApp()之前执行异步操作时。
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  // 初始化rust库
  await RustLib.init();
  // 初始化 HTTP CookieJar / 网络设置
  await Http.init();
  // 初始化drift数据库
  await db.AppDatabase.init();
  // 初始化 WebView 服务（用于需要 JS 渲染的书源）
  await WebViewService.init();

  final localeStore = AppLocaleStore();
  final localeCode = await localeStore.loadCode();
  runApp(MyApp(initialLocale: localeStore.localeForCode(localeCode)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialLocale});

  final Locale? initialLocale;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppThemeController>(
      init: AppThemeController(),
      builder: (themeController) {
        return GetMaterialApp(
          title: '源小说',
          // 未知路由
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const Scaffold(
              body: Center(
                child: Text('404'),
              ),
            ),
          ),
          builder: FlutterSmartDialog.init(),
          navigatorObservers: <NavigatorObserver>[FlutterSmartDialog.observer],
          navigatorKey: Get.key,
          initialRoute: AppRoutes.home,
          getPages: AppPages.pages(themeController: themeController),
          theme: themeController.lightTheme,
          darkTheme: themeController.darkTheme,
          themeMode: themeController.themeMode,
          locale: initialLocale,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            S.delegate,
            // 指定本地化的字符串和一些其他的值
            GlobalMaterialLocalizations.delegate,
            // 对应的Cupertino风格
            GlobalCupertinoLocalizations.delegate,
            // 指定默认的文本排列方向, 由左到右或由右到左
            GlobalWidgetsLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
