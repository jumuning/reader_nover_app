class StoreDetailState {
  List<BookItem> books = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  String? errorMessage;
  bool loginRequired = false;

  StoreDetailState();
}

class BookItem {
  final String name;
  final String? author;
  final String? cover;
  final String? intro;
  final String? kind;
  final String? lastChapter;
  final String bookUrl;
  final int bookSourceId;
  final bool inShelf;

  BookItem({
    required this.name,
    this.author,
    this.cover,
    this.intro,
    this.kind,
    this.lastChapter,
    required this.bookUrl,
    required this.bookSourceId,
    this.inShelf = false,
  });
}
