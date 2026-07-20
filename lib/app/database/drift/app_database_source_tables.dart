part of 'app_database.dart';

/// 书源表
class BookSources extends Table {
  IntColumn get id => integer()();
  TextColumn get bookSourceName => text()();
  TextColumn get bookSourceGroup => text().nullable()();
  TextColumn get bookSourceComment => text().nullable()();
  TextColumn get jsLib => text().nullable()();
  TextColumn get bookSourceUrl => text()();
  IntColumn get customOrder => integer().nullable()();
  TextColumn get bookUrlPattern => text().nullable()();
  IntColumn get bookSourceType => integer().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  BoolColumn get enabledCookieJar => boolean().nullable()();
  BoolColumn get enabledExplore => boolean().nullable()();
  TextColumn get header => text().nullable()();
  TextColumn get loginUrl => text().nullable()();
  TextColumn get lastUpdateTime => text().nullable()();
  TextColumn get exploreUrl => text().nullable()();
  TextColumn get searchUrl => text().nullable()();
  IntColumn get weight => integer().nullable()();
  BoolColumn get isEnabled => boolean().nullable()();

  /// 并发速率限制，格式 "N,ms"
  TextColumn get concurrentRate => text().nullable()();

  /// 请求超时毫秒数，默认 180000
  IntColumn get respondTime => integer().nullable()();

  /// 登录表单 UI 配置 JSON
  TextColumn get loginUi => text().nullable()();

  /// 每次请求后验证登录态的 JS
  TextColumn get loginCheckJs => text().nullable()();

  /// 封面图片解密 JS
  TextColumn get coverDecodeJs => text().nullable()();

  /// 书源变量说明
  TextColumn get variableComment => text().nullable()();

  /// 发现页筛选/分面配置 JSON
  TextColumn get exploreScreen => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 书籍信息规则表
class RuleBookInfos extends Table {
  IntColumn get id => integer()();
  IntColumn get bookSourceId => integer()();
  TextColumn get author => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get init => text().nullable()();
  TextColumn get intro => text().nullable()();
  TextColumn get kind => text().nullable()();
  TextColumn get lastChapter => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get tocUrl => text().nullable()();
  TextColumn get wordCount => text().nullable()();
  TextColumn get lastReadChapter => text().nullable()();

  /// 是否允许用户重命名书名
  TextColumn get canReName => text().nullable()();

  /// 文件型书源下载链接规则
  TextColumn get downloadUrls => text().nullable()();

  /// 更新时间规则
  TextColumn get updateTime => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 内容规则表
class RuleContents extends Table {
  IntColumn get id => integer()();
  IntColumn get bookSourceId => integer()();
  TextColumn get content => text().nullable()();
  TextColumn get nextContentUrl => text().nullable()();
  TextColumn get replaceRegex => text().nullable()();

  /// 正文页标题规则
  TextColumn get title => text().nullable()();

  /// 正文 WebView 预注入 JS
  TextColumn get webJs => text().nullable()();

  /// 响应体过滤正则，提取真实内容区域
  TextColumn get sourceRegex => text().nullable()();

  /// 图片样式
  TextColumn get imageStyle => text().nullable()();

  /// 图片解密 JS
  TextColumn get imageDecode => text().nullable()();

  /// 付费章节解锁动作
  TextColumn get payAction => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 搜索规则表
class RuleSearchs extends Table {
  IntColumn get id => integer()();
  IntColumn get bookSourceId => integer()();
  TextColumn get name => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get bookList => text().nullable()();
  TextColumn get bookUrl => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get intro => text().nullable()();
  TextColumn get kind => text().nullable()();
  TextColumn get lastChapter => text().nullable()();
  TextColumn get wordCount => text().nullable()();
  TextColumn get tocUrl => text().nullable()();

  /// 验证搜索关键词命中规则
  TextColumn get checkKeyWord => text().nullable()();

  /// 更新时间规则
  TextColumn get updateTime => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 目录规则表
class RuleTocs extends Table {
  IntColumn get id => integer()();
  IntColumn get bookSourceId => integer()();
  TextColumn get chapterList => text().nullable()();
  TextColumn get chapterName => text().nullable()();
  TextColumn get chapterUrl => text().nullable()();
  TextColumn get nextTocUrl => text().nullable()();

  /// 目录请求前执行的 JS，用于初始化 cookie/变量
  TextColumn get preUpdateJs => text().nullable()();

  /// 章节名后处理 JS
  TextColumn get formatJs => text().nullable()();

  /// 是否为分卷标记规则
  TextColumn get isVolume => text().nullable()();

  /// VIP 章节识别规则
  TextColumn get isVip => text().nullable()();

  /// 付费章节识别规则
  TextColumn get isPay => text().nullable()();

  /// 更新时间规则
  TextColumn get updateTime => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 发现规则表
class RuleExplores extends Table {
  IntColumn get id => integer()();
  IntColumn get bookSourceId => integer()();
  TextColumn get bookList => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get bookUrl => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get intro => text().nullable()();
  TextColumn get kind => text().nullable()();
  TextColumn get lastChapter => text().nullable()();

  /// 字数规则
  TextColumn get wordCount => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 搜索信息表
class BookSearchInfos extends Table {
  IntColumn get id => integer()();
  IntColumn get bookSourceId => integer()();
  TextColumn get searchUrl => text()();
  TextColumn get method => text()();
  TextColumn get charset => text()();
  TextColumn get headers => text().nullable()();
  TextColumn get body => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
