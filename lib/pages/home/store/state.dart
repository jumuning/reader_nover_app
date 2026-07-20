import '../../../app/database/drift/app_database.dart';
import '../../../app/service/source/explore_screen.dart';

class StoreState {
  List<BookSource> sources = [];

  /// 书源发现分类缓存：sourceId -> kinds（首次解析后复用）
  Map<int, List<ExploreKind>> sourceKinds = {};
  Map<int, bool> expandedSources = {};

  /// exploreScreen 筛选当前值：sourceId -> {key: value}
  Map<int, Map<String, String>> exploreScreenValues = {};

  /// exploreScreen 字段定义缓存：sourceId -> fields
  Map<int, List<ExploreScreenField>> exploreScreenFields = {};

  String searchQuery = '';
  bool isLoading = false;

  /// 是否已完成过至少一次加载（含空结果）
  bool hasLoaded = false;

  StoreState();
}

class ExploreKind {
  final String title;
  final String url;
  final String? styleJson;

  ExploreKind(this.title, this.url, {this.styleJson});
}
