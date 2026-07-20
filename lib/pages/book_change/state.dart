import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/routes/route_args.dart';
import 'package:reader_nover/app/service/book/models/source_book_info.dart';

/// 换源页面状态
class BookChangeState {
  /// 书籍名称
  String bookName = '';

  /// 当前书源ID
  int currentBookSourceId = 0;

  /// 当前书源名称
  String currentSourceName = '';

  /// 当前书源URL
  String currentSourceUrl = '';

  /// 当前书籍URL
  String currentBookUrl = '';

  /// 是否正在搜索
  bool isSearching = false;

  /// 可用书源列表
  List<SourceBookInfo> availableSources = [];

  /// 搜索时需要登录后才能使用的书源
  List<db.BookSource> loginRequiredSources = [];

  /// 需要登录的书源数量
  int get loginRequiredSourceCount => loginRequiredSources.length;

  /// 已完成搜索的书源数量
  int searchedCount = 0;

  /// 总书源数量
  int totalSourceCount = 0;

  BookChangeState({required BookChangeArgs args}) {
    bookName = args.bookName;
    currentBookSourceId = args.bookSourceId;
    currentSourceName = args.sourceName;
    currentSourceUrl = args.sourceUrl;
    currentBookUrl = args.bookUrl;
  }
}
