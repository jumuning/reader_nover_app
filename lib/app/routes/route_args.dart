import 'package:flutter/widgets.dart';

import '../database/models/models.dart';

class BookReadArgs {
  const BookReadArgs({
    required this.bookInfo,
    required this.chapterName,
    required this.chapterUrl,
    required this.chapterIndex,
    required this.pageIndex,
    required this.bookDetail,
    this.onRefreshBookshelf,
  });

  final BookInfo bookInfo;
  final String chapterName;
  final String chapterUrl;
  final int chapterIndex;
  final int pageIndex;
  final BookDetail bookDetail;
  final VoidCallback? onRefreshBookshelf;
}

class BookReadExitResult {
  const BookReadExitResult({
    required this.chapterIndex,
    required this.pageIndex,
  });

  final int chapterIndex;
  final int pageIndex;
}

class BookChangeArgs {
  const BookChangeArgs({
    required this.bookName,
    required this.bookSourceId,
    required this.sourceName,
    required this.sourceUrl,
    required this.bookUrl,
  });

  final String bookName;
  final int bookSourceId;
  final String sourceName;
  final String sourceUrl;
  final String bookUrl;
}

class BookDetailArgs {
  const BookDetailArgs({
    required this.bookInfo,
    this.onRefreshBookshelf,
  });

  final BookInfo bookInfo;
  final VoidCallback? onRefreshBookshelf;
}

class BookSearchArgs {
  const BookSearchArgs({
    this.onRefreshBookshelf,
  });

  final VoidCallback? onRefreshBookshelf;
}
