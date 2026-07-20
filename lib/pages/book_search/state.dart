import '../../app/database/drift/app_database.dart' as db;
import '../../app/database/models/models.dart';
import '../../app/service/source/source_check_report.dart';

class BookSearchState {
  late Map<String, List<BookInfo>> searchBookInfoMap;
  late List<BookInfo> bookInfoList;
  late Map<int, SourceSearchResult> sourceResults;
  late List<db.BookSource> bookSources;
  late List<db.SearchHistory> searchHistories;
  bool showHistory = true;
  bool isSearching = false;
  String searchKeyword = '';
  int currentPage = 1;
  bool hasMore = true;

  int get completedSourceCount =>
      sourceResults.values.where((r) => !r.isLoading).length;
  int get totalSourceCount => sourceResults.length;

  List<BookInfo> get aggregatedBooks => [
        for (final source in bookSources) ...?sourceResults[source.id]?.books,
      ];

  BookSearchState() {
    bookSources = [];
    bookInfoList = [];
    searchBookInfoMap = {};
    searchHistories = [];
    sourceResults = {};
  }
}

class SourceSearchResult {
  final db.BookSource source;
  final List<BookInfo> books;
  final bool isLoading;
  final String? error;
  final bool loginRequired;
  final SourceCheckFailureClass? failureClass;

  SourceSearchResult({
    required this.source,
    required this.books,
    this.isLoading = false,
    this.error,
    this.loginRequired = false,
    this.failureClass,
  });

  SourceSearchResult copyWith({
    db.BookSource? source,
    List<BookInfo>? books,
    bool? isLoading,
    Object? error = _copyWithSentinel,
    bool? loginRequired,
    Object? failureClass = _copyWithSentinel,
  }) {
    return SourceSearchResult(
      source: source ?? this.source,
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error:
          identical(error, _copyWithSentinel) ? this.error : error as String?,
      loginRequired: loginRequired ?? this.loginRequired,
      failureClass: identical(failureClass, _copyWithSentinel)
          ? this.failureClass
          : failureClass as SourceCheckFailureClass?,
    );
  }
}

const Object _copyWithSentinel = Object();
