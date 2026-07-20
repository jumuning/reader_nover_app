// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `启用`
  String get enabled {
    return Intl.message('启用', name: 'enabled', desc: '', args: []);
  }

  /// `禁用`
  String get disabled {
    return Intl.message('禁用', name: 'disabled', desc: '', args: []);
  }

  /// `取消`
  String get cancel {
    return Intl.message('取消', name: 'cancel', desc: '', args: []);
  }

  /// `提示`
  String get tips {
    return Intl.message('提示', name: 'tips', desc: '', args: []);
  }

  /// `警告`
  String get warning {
    return Intl.message('警告', name: 'warning', desc: '', args: []);
  }

  /// `删除`
  String get delete {
    return Intl.message('删除', name: 'delete', desc: '', args: []);
  }

  /// `确定`
  String get ok {
    return Intl.message('确定', name: 'ok', desc: '', args: []);
  }

  /// `目录`
  String get directory {
    return Intl.message('目录', name: 'directory', desc: '', args: []);
  }

  /// `设置`
  String get setting {
    return Intl.message('设置', name: 'setting', desc: '', args: []);
  }

  /// `缓存`
  String get cache {
    return Intl.message('缓存', name: 'cache', desc: '', args: []);
  }

  /// `清除`
  String get clear {
    return Intl.message('清除', name: 'clear', desc: '', args: []);
  }

  /// `翻页`
  String get flip {
    return Intl.message('翻页', name: 'flip', desc: '', args: []);
  }

  /// `第{page}页`
  String pageN(int page) {
    return Intl.message('第$page页', name: 'pageN', desc: '', args: [page]);
  }

  /// `上一章`
  String get previousChapter {
    return Intl.message('上一章', name: 'previousChapter', desc: '', args: []);
  }

  /// `下一章`
  String get nextChapter {
    return Intl.message('下一章', name: 'nextChapter', desc: '', args: []);
  }

  /// `字体选择`
  String get fontSelectionTitle {
    return Intl.message('字体选择', name: 'fontSelectionTitle', desc: '', args: []);
  }

  /// `系统字体`
  String get systemFont {
    return Intl.message('系统字体', name: 'systemFont', desc: '', args: []);
  }

  /// `自定义字体`
  String get customFont {
    return Intl.message('自定义字体', name: 'customFont', desc: '', args: []);
  }

  /// `行间距`
  String get lineSpacing {
    return Intl.message('行间距', name: 'lineSpacing', desc: '', args: []);
  }

  /// `字间距`
  String get letterSpacing {
    return Intl.message('字间距', name: 'letterSpacing', desc: '', args: []);
  }

  /// `页面边距`
  String get pageMargin {
    return Intl.message('页面边距', name: 'pageMargin', desc: '', args: []);
  }

  /// `阅读模式`
  String get readingMode {
    return Intl.message('阅读模式', name: 'readingMode', desc: '', args: []);
  }

  /// `护眼模式`
  String get eyeProtection {
    return Intl.message('护眼模式', name: 'eyeProtection', desc: '', args: []);
  }

  /// `亮度`
  String get brightness {
    return Intl.message('亮度', name: 'brightness', desc: '', args: []);
  }

  /// `背景`
  String get background {
    return Intl.message('背景', name: 'background', desc: '', args: []);
  }

  /// `翻页`
  String get pageTurn {
    return Intl.message('翻页', name: 'pageTurn', desc: '', args: []);
  }

  /// `仿真`
  String get simulation {
    return Intl.message('仿真', name: 'simulation', desc: '', args: []);
  }

  /// `覆盖`
  String get cover {
    return Intl.message('覆盖', name: 'cover', desc: '', args: []);
  }

  /// `平移`
  String get slide {
    return Intl.message('平移', name: 'slide', desc: '', args: []);
  }

  /// `上下`
  String get vertical {
    return Intl.message('上下', name: 'vertical', desc: '', args: []);
  }

  /// `无动画`
  String get noAnimation {
    return Intl.message('无动画', name: 'noAnimation', desc: '', args: []);
  }

  /// `其他`
  String get other {
    return Intl.message('其他', name: 'other', desc: '', args: []);
  }

  /// `间距设置`
  String get spacingSettings {
    return Intl.message('间距设置', name: 'spacingSettings', desc: '', args: []);
  }

  /// `更多`
  String get more {
    return Intl.message('更多', name: 'more', desc: '', args: []);
  }

  /// `书架`
  String get bookshelf {
    return Intl.message('书架', name: 'bookshelf', desc: '', args: []);
  }

  /// `书城`
  String get bookStore {
    return Intl.message('书城', name: 'bookStore', desc: '', args: []);
  }

  /// `书源`
  String get bookSources {
    return Intl.message('书源', name: 'bookSources', desc: '', args: []);
  }

  /// `阅读统计`
  String get readingStats {
    return Intl.message('阅读统计', name: 'readingStats', desc: '', args: []);
  }

  /// `时长、连续阅读与书籍排行`
  String get readingStatsSubtitle {
    return Intl.message(
      '时长、连续阅读与书籍排行',
      name: 'readingStatsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `本地书籍存储检查`
  String get localStorageCheck {
    return Intl.message(
      '本地书籍存储检查',
      name: 'localStorageCheck',
      desc: '',
      args: [],
    );
  }

  /// `检查缺失文件并安全清理临时缓存`
  String get localStorageCheckSubtitle {
    return Intl.message(
      '检查缺失文件并安全清理临时缓存',
      name: 'localStorageCheckSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `重新加载主题配置`
  String get reloadTheme {
    return Intl.message('重新加载主题配置', name: 'reloadTheme', desc: '', args: []);
  }

  /// `刷新`
  String get refresh {
    return Intl.message('刷新', name: 'refresh', desc: '', args: []);
  }

  /// `正在加载`
  String get loading {
    return Intl.message('正在加载', name: 'loading', desc: '', args: []);
  }

  /// `重试`
  String get retry {
    return Intl.message('重试', name: 'retry', desc: '', args: []);
  }

  /// `批注`
  String get annotations {
    return Intl.message('批注', name: 'annotations', desc: '', args: []);
  }

  /// `书签`
  String get bookmarks {
    return Intl.message('书签', name: 'bookmarks', desc: '', args: []);
  }

  /// `高亮`
  String get highlights {
    return Intl.message('高亮', name: 'highlights', desc: '', args: []);
  }

  /// `下划线`
  String get underline {
    return Intl.message('下划线', name: 'underline', desc: '', args: []);
  }

  /// `笔记`
  String get note {
    return Intl.message('笔记', name: 'note', desc: '', args: []);
  }

  /// `语言`
  String get language {
    return Intl.message('语言', name: 'language', desc: '', args: []);
  }

  /// `跟随系统`
  String get languageSystem {
    return Intl.message('跟随系统', name: 'languageSystem', desc: '', args: []);
  }

  /// `简体中文`
  String get languageChinese {
    return Intl.message('简体中文', name: 'languageChinese', desc: '', args: []);
  }

  /// `English`
  String get languageEnglish {
    return Intl.message('English', name: 'languageEnglish', desc: '', args: []);
  }

  /// `保存`
  String get save {
    return Intl.message('保存', name: 'save', desc: '', args: []);
  }

  /// `关闭`
  String get close {
    return Intl.message('关闭', name: 'close', desc: '', args: []);
  }

  /// `编辑笔记`
  String get editNote {
    return Intl.message('编辑笔记', name: 'editNote', desc: '', args: []);
  }

  /// `添加笔记`
  String get addNote {
    return Intl.message('添加笔记', name: 'addNote', desc: '', args: []);
  }

  /// `写下你的想法`
  String get writeYourThoughts {
    return Intl.message(
      '写下你的想法',
      name: 'writeYourThoughts',
      desc: '',
      args: [],
    );
  }

  /// `暂无批注`
  String get noAnnotations {
    return Intl.message('暂无批注', name: 'noAnnotations', desc: '', args: []);
  }

  /// `暂无书签`
  String get noBookmarks {
    return Intl.message('暂无书签', name: 'noBookmarks', desc: '', args: []);
  }

  /// `阅读时点击书签按钮可添加`
  String get bookmarkEmptyHint {
    return Intl.message(
      '阅读时点击书签按钮可添加',
      name: 'bookmarkEmptyHint',
      desc: '',
      args: [],
    );
  }

  /// `备注`
  String get remark {
    return Intl.message('备注', name: 'remark', desc: '', args: []);
  }

  /// `正序`
  String get ascending {
    return Intl.message('正序', name: 'ascending', desc: '', args: []);
  }

  /// `倒序`
  String get descending {
    return Intl.message('倒序', name: 'descending', desc: '', args: []);
  }

  /// `章节错误`
  String get chapterError {
    return Intl.message('章节错误', name: 'chapterError', desc: '', args: []);
  }

  /// `上次`
  String get lastRead {
    return Intl.message('上次', name: 'lastRead', desc: '', args: []);
  }

  /// `从这里朗读`
  String get readFromHere {
    return Intl.message('从这里朗读', name: 'readFromHere', desc: '', args: []);
  }

  /// `从本段第一句开始继续朗读`
  String get readFromHereSubtitle {
    return Intl.message(
      '从本段第一句开始继续朗读',
      name: 'readFromHereSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `{minutes}分钟`
  String minutesCount(Object minutes) {
    return Intl.message(
      '$minutes分钟',
      name: 'minutesCount',
      desc: '',
      args: [minutes],
    );
  }

  /// `开始朗读`
  String get startReadingAloud {
    return Intl.message('开始朗读', name: 'startReadingAloud', desc: '', args: []);
  }

  /// `总阅读时长`
  String get totalReadingTime {
    return Intl.message('总阅读时长', name: 'totalReadingTime', desc: '', args: []);
  }

  /// `阅读会话`
  String get readingSessions {
    return Intl.message('阅读会话', name: 'readingSessions', desc: '', args: []);
  }

  /// `平均时长`
  String get averageDuration {
    return Intl.message('平均时长', name: 'averageDuration', desc: '', args: []);
  }

  /// `连续阅读`
  String get readingStreak {
    return Intl.message('连续阅读', name: 'readingStreak', desc: '', args: []);
  }

  /// `{count} 次`
  String timesCount(Object count) {
    return Intl.message(
      '$count 次',
      name: 'timesCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} 天`
  String daysCount(Object count) {
    return Intl.message('$count 天', name: 'daysCount', desc: '', args: [count]);
  }

  /// `最长 {count} 天`
  String longestDays(Object count) {
    return Intl.message(
      '最长 $count 天',
      name: 'longestDays',
      desc: '',
      args: [count],
    );
  }

  /// `近 7 日`
  String get lastSevenDays {
    return Intl.message('近 7 日', name: 'lastSevenDays', desc: '', args: []);
  }

  /// `按书统计`
  String get statsByBook {
    return Intl.message('按书统计', name: 'statsByBook', desc: '', args: []);
  }

  /// `每日阅读目标`
  String get dailyReadingGoal {
    return Intl.message('每日阅读目标', name: 'dailyReadingGoal', desc: '', args: []);
  }

  /// `今日计划`
  String get todayPlan {
    return Intl.message('今日计划', name: 'todayPlan', desc: '', args: []);
  }

  /// `调整目标`
  String get adjustGoal {
    return Intl.message('调整目标', name: 'adjustGoal', desc: '', args: []);
  }

  /// `连续达标 {count} 天`
  String goalStreakDays(Object count) {
    return Intl.message(
      '连续达标 $count 天',
      name: 'goalStreakDays',
      desc: '',
      args: [count],
    );
  }

  /// `本周达标 {count} 天`
  String weekGoalDays(Object count) {
    return Intl.message(
      '本周达标 $count 天',
      name: 'weekGoalDays',
      desc: '',
      args: [count],
    );
  }

  /// `今日已达标，建议再读 {duration}`
  String todayGoalReached(Object duration) {
    return Intl.message(
      '今日已达标，建议再读 $duration',
      name: 'todayGoalReached',
      desc: '',
      args: [duration],
    );
  }

  /// `还差 {remaining}，建议本次阅读 {suggested}`
  String todayGoalRemaining(Object remaining, Object suggested) {
    return Intl.message(
      '还差 $remaining，建议本次阅读 $suggested',
      name: 'todayGoalRemaining',
      desc: '',
      args: [remaining, suggested],
    );
  }

  /// `继续阅读：{book}`
  String continueReadingBook(Object book) {
    return Intl.message(
      '继续阅读：$book',
      name: 'continueReadingBook',
      desc: '',
      args: [book],
    );
  }

  /// `{count} 次会话`
  String sessionsCount(Object count) {
    return Intl.message(
      '$count 次会话',
      name: 'sessionsCount',
      desc: '',
      args: [count],
    );
  }

  /// `还没有阅读记录`
  String get noReadingRecords {
    return Intl.message(
      '还没有阅读记录',
      name: 'noReadingRecords',
      desc: '',
      args: [],
    );
  }

  /// `阅读统计加载失败`
  String get readingStatsLoadFailed {
    return Intl.message(
      '阅读统计加载失败',
      name: 'readingStatsLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `{count} 小时`
  String hoursCount(Object count) {
    return Intl.message(
      '$count 小时',
      name: 'hoursCount',
      desc: '',
      args: [count],
    );
  }

  /// `{hours} 小时 {minutes} 分`
  String hoursMinutesCount(Object hours, Object minutes) {
    return Intl.message(
      '$hours 小时 $minutes 分',
      name: 'hoursMinutesCount',
      desc: '',
      args: [hours, minutes],
    );
  }

  /// `清理完成`
  String get storageCleanupComplete {
    return Intl.message(
      '清理完成',
      name: 'storageCleanupComplete',
      desc: '',
      args: [],
    );
  }

  /// `已处理 {count} 个临时、缓存或封面问题，释放 {size}。\n\n用户原文件和普通本地书籍文件未被删除。`
  String storageRepairCompleteMessage(Object count, Object size) {
    return Intl.message(
      '已处理 $count 个临时、缓存或封面问题，释放 $size。\n\n用户原文件和普通本地书籍文件未被删除。',
      name: 'storageRepairCompleteMessage',
      desc: '',
      args: [count, size],
    );
  }

  /// `完成`
  String get done {
    return Intl.message('完成', name: 'done', desc: '', args: []);
  }

  /// `存储检查失败`
  String get storageCheckFailed {
    return Intl.message(
      '存储检查失败',
      name: 'storageCheckFailed',
      desc: '',
      args: [],
    );
  }

  /// `暂时无法检查本地书籍存储，请稍后重试`
  String get storageCheckFailedMessage {
    return Intl.message(
      '暂时无法检查本地书籍存储，请稍后重试',
      name: 'storageCheckFailedMessage',
      desc: '',
      args: [],
    );
  }

  /// `本地书籍存储检查`
  String get storageCheckTitle {
    return Intl.message(
      '本地书籍存储检查',
      name: 'storageCheckTitle',
      desc: '',
      args: [],
    );
  }

  /// `未发现存储问题。`
  String get storageHealthy {
    return Intl.message('未发现存储问题。', name: 'storageHealthy', desc: '', args: []);
  }

  /// `共发现 {total} 个问题。\n\n可安全修复：{cleanable}\n文件缺失：{missing}\n文件信息异常：{metadata}\n封面缺失：{covers}\n非应用管理路径：{external}\n\n自动修复仅处理应用目录内的临时文件、生成封面和可重建缓存，不会删除用户原文件或普通本地书籍文件。`
  String storageIssuesSummary(
    Object total,
    Object cleanable,
    Object missing,
    Object metadata,
    Object covers,
    Object external,
  ) {
    return Intl.message(
      '共发现 $total 个问题。\n\n可安全修复：$cleanable\n文件缺失：$missing\n文件信息异常：$metadata\n封面缺失：$covers\n非应用管理路径：$external\n\n自动修复仅处理应用目录内的临时文件、生成封面和可重建缓存，不会删除用户原文件或普通本地书籍文件。',
      name: 'storageIssuesSummary',
      desc: '',
      args: [total, cleanable, missing, metadata, covers, external],
    );
  }

  /// `暂不处理`
  String get notNow {
    return Intl.message('暂不处理', name: 'notNow', desc: '', args: []);
  }

  /// `安全修复`
  String get safeRepair {
    return Intl.message('安全修复', name: 'safeRepair', desc: '', args: []);
  }

  /// `导入失败`
  String get importFailed {
    return Intl.message('导入失败', name: 'importFailed', desc: '', args: []);
  }

  /// `无法读取所选文件路径`
  String get importPathUnavailable {
    return Intl.message(
      '无法读取所选文件路径',
      name: 'importPathUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `导入失败，请稍后重试`
  String get importRetryLater {
    return Intl.message(
      '导入失败，请稍后重试',
      name: 'importRetryLater',
      desc: '',
      args: [],
    );
  }

  /// `导入成功`
  String get importSucceeded {
    return Intl.message('导入成功', name: 'importSucceeded', desc: '', args: []);
  }

  /// `《{book}》已加入书架`
  String bookAddedToShelf(Object book) {
    return Intl.message(
      '《$book》已加入书架',
      name: 'bookAddedToShelf',
      desc: '',
      args: [book],
    );
  }

  /// `文件不存在，请重新选择`
  String get fileNotFoundReselect {
    return Intl.message(
      '文件不存在，请重新选择',
      name: 'fileNotFoundReselect',
      desc: '',
      args: [],
    );
  }

  /// `仅支持 TXT 和 EPUB 文件`
  String get supportedLocalFormats {
    return Intl.message(
      '仅支持 TXT 和 EPUB 文件',
      name: 'supportedLocalFormats',
      desc: '',
      args: [],
    );
  }

  /// `文件内容为空，无法导入`
  String get emptyFileCannotImport {
    return Intl.message(
      '文件内容为空，无法导入',
      name: 'emptyFileCannotImport',
      desc: '',
      args: [],
    );
  }

  /// `TXT 文件过大，暂不支持导入`
  String get txtFileTooLarge {
    return Intl.message(
      'TXT 文件过大，暂不支持导入',
      name: 'txtFileTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `未命名本地书籍`
  String get unnamedLocalBook {
    return Intl.message(
      '未命名本地书籍',
      name: 'unnamedLocalBook',
      desc: '',
      args: [],
    );
  }

  /// `EPUB 文件不存在，请重新选择`
  String get epubFileNotFound {
    return Intl.message(
      'EPUB 文件不存在，请重新选择',
      name: 'epubFileNotFound',
      desc: '',
      args: [],
    );
  }

  /// `EPUB 缺少内容清单`
  String get epubManifestMissing {
    return Intl.message(
      'EPUB 缺少内容清单',
      name: 'epubManifestMissing',
      desc: '',
      args: [],
    );
  }

  /// `EPUB 未解析到可阅读章节`
  String get epubNoReadableChapters {
    return Intl.message(
      'EPUB 未解析到可阅读章节',
      name: 'epubNoReadableChapters',
      desc: '',
      args: [],
    );
  }

  /// `EPUB 缺少资源：{path}`
  String epubResourceMissing(Object path) {
    return Intl.message(
      'EPUB 缺少资源：$path',
      name: 'epubResourceMissing',
      desc: '',
      args: [path],
    );
  }

  /// `EPUB 包含不安全的资源路径`
  String get epubUnsafeResourcePath {
    return Intl.message(
      'EPUB 包含不安全的资源路径',
      name: 'epubUnsafeResourcePath',
      desc: '',
      args: [],
    );
  }

  /// `EPUB 文件过大，暂不支持导入`
  String get epubFileTooLarge {
    return Intl.message(
      'EPUB 文件过大，暂不支持导入',
      name: 'epubFileTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `EPUB 解压后的内容过大，已停止导入`
  String get epubExpandedTooLarge {
    return Intl.message(
      'EPUB 解压后的内容过大，已停止导入',
      name: 'epubExpandedTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `第 {number} 章`
  String chapterNumber(Object number) {
    return Intl.message(
      '第 $number 章',
      name: 'chapterNumber',
      desc: '',
      args: [number],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
