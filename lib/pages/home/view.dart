import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/pages/home/book/view.dart';
import 'package:reader_nover/pages/home/store/view.dart';
import 'package:reader_nover/pages/home/logic.dart';
import 'package:reader_nover/pages/home/setting/view.dart';
import 'package:reader_nover/pages/home/source/view.dart';
import 'package:reader_nover/pages/home/state.dart';
import 'package:reader_nover/util/platform_utils.dart';
import 'package:reader_nover/app/l10n/generated/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  HomeLogic get logic => Get.find<HomeLogic>();
  HomeState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeLogic>(builder: (logic) {
      return Scaffold(
          body: SafeArea(
            child: PlatformUtils.isDesktop()
                ? Row(
                    children: [
                      HomeNavigationRail(state: state, logic: logic),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: _buildPageContent(),
                      ),
                    ],
                  )
                : _buildPageContent(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
          ),
          bottomNavigationBar: PlatformUtils.isDesktop()
              ? null
              : Builder(
                  builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return BottomNavigationBar(
                      currentIndex: state.pageIndex,
                      onTap: logic.changePageIndex,
                      selectedItemColor: colorScheme.primary,
                      unselectedItemColor:
                          colorScheme.onSurface.withValues(alpha: 0.45),
                      type: BottomNavigationBarType.fixed,
                      items: [
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.menu_book_outlined),
                          activeIcon: const Icon(Icons.menu_book),
                          label: S.of(context).bookshelf,
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.library_books_outlined),
                          activeIcon: const Icon(Icons.library_books),
                          label: S.of(context).bookStore,
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.source_outlined),
                          activeIcon: const Icon(Icons.source),
                          label: S.of(context).bookSources,
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.settings_outlined),
                          activeIcon: const Icon(Icons.settings),
                          label: S.of(context).setting,
                        ),
                      ],
                    );
                  },
                ));
    });
  }

  Widget _buildPageContent({EdgeInsetsGeometry padding = EdgeInsets.zero}) {
    return Padding(
      padding: padding,
      child: IndexedStack(
        index: state.pageIndex,
        children: [
          BookPage(logic: logic.bookLogic),
          const StorePage(),
          const SourcePage(),
          SettingPage(logic: logic.settingLogic),
        ],
      ),
    );
  }
}

// 桌面端
class HomeNavigationRail extends StatelessWidget {
  const HomeNavigationRail(
      {super.key, required this.state, required this.logic});

  final HomeState state;
  final HomeLogic logic;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      labelType: NavigationRailLabelType.all,
      selectedIndex: state.pageIndex,
      onDestinationSelected: logic.changePageIndex,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.book),
          label: Text(S.of(context).bookshelf),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.library_books),
          label: Text(S.of(context).bookStore),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.source),
          label: Text(S.of(context).bookSources),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings),
          label: Text(S.of(context).setting),
        ),
      ],
    );
  }
}
