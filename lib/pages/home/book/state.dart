import '../../../app/database/drift/app_database.dart';
import '../../../app/database/models/models.dart' hide BookSource;
import '../../../app/service/local_book/local_book_constants.dart';

/// 书架布局类型
enum BookshelfLayout {
  list, // 列表视图
  grid, // 网格视图
}

/// 书架排序方式
enum BookshelfSortMode {
  recentRead, // 最近阅读
  latestAdded, // 最近加入
  title, // 书名
  author, // 作者
}

/// 书架类型筛选
enum BookshelfTypeFilter {
  all,
  network,
  local,
}

extension BookshelfSortModeX on BookshelfSortMode {
  String get label {
    switch (this) {
      case BookshelfSortMode.recentRead:
        return '最近阅读';
      case BookshelfSortMode.latestAdded:
        return '最近加入';
      case BookshelfSortMode.title:
        return '书名';
      case BookshelfSortMode.author:
        return '作者';
    }
  }

  static BookshelfSortMode fromName(String? name) {
    for (final mode in BookshelfSortMode.values) {
      if (mode.name == name) return mode;
    }
    return BookshelfSortMode.recentRead;
  }
}

extension BookshelfTypeFilterX on BookshelfTypeFilter {
  String get label {
    switch (this) {
      case BookshelfTypeFilter.all:
        return '全部';
      case BookshelfTypeFilter.network:
        return '网络';
      case BookshelfTypeFilter.local:
        return '本地';
    }
  }
}

/// 单本书更新状态
enum BookUpdateStatus {
  idle, // 空闲
  waiting, // 等待中
  updating, // 更新中
  success, // 成功
  failed, // 失败
}

/// 单本书更新结果
class BookUpdateResult {
  final int bookId;
  final BookUpdateStatus status;
  final int newChapterCount; // 新增章节数
  final String? errorMessage;

  BookUpdateResult({
    required this.bookId,
    this.status = BookUpdateStatus.idle,
    this.newChapterCount = 0,
    this.errorMessage,
  });
}

class BookState {
  late List<Book> myBooks;

  /// 当前布局类型
  BookshelfLayout layout = BookshelfLayout.list;

  /// 当前排序方式
  BookshelfSortMode sortMode = BookshelfSortMode.recentRead;

  /// 书架内搜索关键词（书名/作者）
  String shelfQuery = '';

  /// 本地 / 网络筛选
  BookshelfTypeFilter typeFilter = BookshelfTypeFilter.all;

  /// 批量选择
  bool isSelectionMode = false;
  final Set<int> selectedIds = <int>{};

  // 缓存解析后的数据，避免在 build 中重复解析 JSON
  final Map<int, BookDetail> bookDetailCache = {};
  final Map<int, BookInfo> bookInfoCache = {};
  final Map<String, int> bookIdByKeyCache = {};
  final Map<int, int> totalChapterCountCache = {};
  final Map<String, int> readProgressCache = {}; // 章节索引缓存
  final Map<String, int> readPageIndexCache = {}; // 页码缓存
  final Map<String, String> readChapterNameCache = {}; // 当前阅读章节名缓存
  final Map<int, BookSource> bookSourceCache = {};

  // ========== 书架更新相关状态 ==========
  /// 是否正在更新
  bool isUpdating = false;

  /// 更新进度 (0.0 - 1.0)
  double updateProgress = 0.0;

  /// 已更新数量
  int updatedCount = 0;

  /// 总更新数量
  int totalUpdateCount = 0;

  /// 单本书更新状态
  final Map<int, BookUpdateResult> updateResults = {};

  /// 是否只显示「有新章」的书
  bool filterNewChaptersOnly = false;

  BookState() {
    myBooks = [];
  }

  /// 有新章节的书籍数量（基于最近一次更新结果）
  int get newChapterBookCount {
    return updateResults.values
        .where(
          (r) => r.status == BookUpdateStatus.success && r.newChapterCount > 0,
        )
        .length;
  }

  int get pinnedCount => myBooks.where((book) => book.customOrder > 0).length;

  bool isPinned(Book book) => book.customOrder > 0;

  /// 列表展示用书籍（搜索 / 类型 / 有新章）
  List<Book> get displayBooks {
    Iterable<Book> books = myBooks;

    switch (typeFilter) {
      case BookshelfTypeFilter.all:
        break;
      case BookshelfTypeFilter.network:
        books = books.where(
          (b) => !LocalBookConstants.isLocalBookSource(b.bookSourceId),
        );
        break;
      case BookshelfTypeFilter.local:
        books = books.where(
          (b) => LocalBookConstants.isLocalBookSource(b.bookSourceId),
        );
        break;
    }

    final query = shelfQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      books = books.where((book) {
        final name = book.name.toLowerCase();
        final author = (book.author ?? '').toLowerCase();
        return name.contains(query) || author.contains(query);
      });
    }

    if (filterNewChaptersOnly) {
      books = books.where((book) {
        final result = updateResults[book.id];
        return result != null &&
            result.status == BookUpdateStatus.success &&
            result.newChapterCount > 0;
      });
    }

    return books.toList(growable: false);
  }

  void clearCache() {
    bookDetailCache.clear();
    bookInfoCache.clear();
    bookIdByKeyCache.clear();
    totalChapterCountCache.clear();
    readProgressCache.clear();
    readPageIndexCache.clear();
    readChapterNameCache.clear();
    bookSourceCache.clear();
  }

  void clearUpdateState() {
    isUpdating = false;
    updateProgress = 0.0;
    updatedCount = 0;
    totalUpdateCount = 0;
    updateResults.clear();
    filterNewChaptersOnly = false;
  }

  void clearSelection() {
    selectedIds.clear();
    isSelectionMode = false;
  }
}
