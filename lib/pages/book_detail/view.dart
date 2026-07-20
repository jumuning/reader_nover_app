import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reader_nover/util/gap.dart';

import 'logic.dart';
import 'state.dart';
import 'widget/book_detail_bottom_bar.dart';
import 'widget/book_detail_chapter_header.dart';
import 'widget/book_detail_chapter_list.dart';
import 'widget/book_detail_header.dart';
import 'widget/book_detail_intro_section.dart';

class BookDetailPage extends StatelessWidget {
  const BookDetailPage({
    super.key,
    required this.logic,
  });

  final BookDetailLogic logic;

  BookDetailState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return GetBuilder<BookDetailLogic>(
      init: logic,
      global: false,
      builder: (_) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: state.coverTextColor == Colors.white
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: state.coverTextColor == Colors.white
                ? Brightness.dark
                : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: context.theme.colorScheme.surface,
            extendBodyBehindAppBar: true,
            body: Column(
              children: [
                BookDetailHeader(
                  state: state,
                  statusBarHeight: statusBarHeight,
                ),
                BookDetailIntroSection(
                  state: state,
                  onToggleExpanded: () {
                    state.isIntroExpanded = !state.isIntroExpanded;
                    logic.update();
                  },
                  onChangeSource: logic.goToChangeSource,
                ),
                const Gap.vb(),
                BookDetailChapterHeader(
                  state: state,
                  onSortChapters: logic.sortChapters,
                ),
                Expanded(
                  child: BookDetailChapterList(
                    state: state,
                    onRetry: logic.loadChapterList,
                    onChapterTap: logic.onChapterTap,
                  ),
                ),
                if (state.isChapterLoaded)
                  BookDetailBottomBar(
                    state: state,
                    onStartOrContinueRead: logic.startOrContinueRead,
                    onAddToBookshelf: logic.addToBookShelf,
                    onRemoveFromBookshelf: logic.removeFromBookShelf,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
