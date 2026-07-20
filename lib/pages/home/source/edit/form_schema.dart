import 'package:flutter/material.dart';

import '../../../../app/database/drift/app_database.dart' as db;

typedef BookSourceEditValueReader<T> = String? Function(T value);

enum BookSourceEditFieldKey {
  sourceName,
  sourceUrl,
  sourceGroup,
  sourceComment,
  searchUrl,
  exploreUrl,
  header,
  loginUrl,
  concurrentRate,
  respondTime,
  loginUi,
  loginCheckJs,
  coverDecodeJs,
  variableComment,
  exploreScreen,
  searchBookList,
  searchName,
  searchAuthor,
  searchBookUrl,
  searchCoverUrl,
  searchIntro,
  searchKind,
  searchLastChapter,
  searchWordCount,
  searchTocUrl,
  searchCheckKeyword,
  searchUpdateTime,
  bookInfoInit,
  bookInfoName,
  bookInfoAuthor,
  bookInfoCoverUrl,
  bookInfoIntro,
  bookInfoKind,
  bookInfoTocUrl,
  bookInfoWordCount,
  bookInfoLastChapter,
  bookInfoLastReadChapter,
  bookInfoCanRename,
  bookInfoDownloadUrls,
  bookInfoUpdateTime,
  tocChapterList,
  tocChapterName,
  tocChapterUrl,
  tocNextTocUrl,
  tocPreUpdateJs,
  tocFormatJs,
  tocIsVolume,
  tocIsVip,
  tocIsPay,
  tocUpdateTime,
  contentBody,
  contentTitle,
  contentNextUrl,
  contentWebJs,
  contentSourceRegex,
  contentReplaceRegex,
  contentImageStyle,
  contentImageDecode,
  contentPayAction,
  exploreBookList,
  exploreName,
  exploreAuthor,
  exploreBookUrl,
  exploreCoverUrl,
  exploreIntro,
  exploreKind,
  exploreLastChapter,
  exploreWordCount,
}

class BookSourceEditFieldSchema {
  const BookSourceEditFieldSchema({
    required this.key,
    required this.label,
    this.required = false,
  });

  final BookSourceEditFieldKey key;
  final String label;
  final bool required;
}

class BookSourceEditSectionSchema {
  const BookSourceEditSectionSchema({
    required this.title,
    required this.icon,
    required this.fields,
    this.initiallyExpanded = false,
    this.showEnabledSwitch = false,
  });

  final String title;
  final IconData icon;
  final List<BookSourceEditFieldSchema> fields;
  final bool initiallyExpanded;
  final bool showEnabledSwitch;
}

const List<BookSourceEditSectionSchema> bookSourceEditSections = [
  BookSourceEditSectionSchema(
    title: '基本信息',
    icon: Icons.info_outline,
    initiallyExpanded: true,
    showEnabledSwitch: true,
    fields: [
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.sourceName,
        label: '书源名称',
        required: true,
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.sourceUrl,
        label: '书源地址',
        required: true,
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.sourceGroup,
        label: '分组',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.sourceComment,
        label: '注释',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchUrl,
        label: '搜索地址',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreUrl,
        label: '发现地址',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.header,
        label: 'Header',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.loginUrl,
        label: '登录地址',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.concurrentRate,
        label: '并发限制(concurrentRate)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.respondTime,
        label: '响应超时(ms)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.loginUi,
        label: '登录UI(loginUi)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.loginCheckJs,
        label: '登录校验JS(loginCheckJs)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.coverDecodeJs,
        label: '封面解密JS(coverDecodeJs)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.variableComment,
        label: '变量注释(variableComment)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreScreen,
        label: '发现筛选(exploreScreen)',
      ),
    ],
  ),
  BookSourceEditSectionSchema(
    title: '搜索规则',
    icon: Icons.search,
    fields: [
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchBookList,
        label: '书籍列表规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchName,
        label: '书名规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchAuthor,
        label: '作者规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchBookUrl,
        label: '书籍地址规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchCoverUrl,
        label: '封面规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchIntro,
        label: '简介规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchKind,
        label: '分类规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchLastChapter,
        label: '最新章节规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchWordCount,
        label: '字数规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchTocUrl,
        label: '目录地址规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchCheckKeyword,
        label: '校验关键词',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.searchUpdateTime,
        label: '更新时间规则(updateTime)',
      ),
    ],
  ),
  BookSourceEditSectionSchema(
    title: '书籍详情规则',
    icon: Icons.book,
    fields: [
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoInit,
        label: '初始化规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoName,
        label: '书名规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoAuthor,
        label: '作者规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoCoverUrl,
        label: '封面规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoIntro,
        label: '简介规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoKind,
        label: '分类规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoTocUrl,
        label: '目录地址规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoWordCount,
        label: '字数规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoLastChapter,
        label: '最新章节规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoLastReadChapter,
        label: '上次阅读章节规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoCanRename,
        label: '可重命名规则(canReName)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoDownloadUrls,
        label: '下载链接规则(downloadUrls)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.bookInfoUpdateTime,
        label: '更新时间规则(updateTime)',
      ),
    ],
  ),
  BookSourceEditSectionSchema(
    title: '目录规则',
    icon: Icons.list,
    fields: [
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocChapterList,
        label: '章节列表规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocChapterName,
        label: '章节名称规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocChapterUrl,
        label: '章节地址规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocNextTocUrl,
        label: '下一页目录规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocPreUpdateJs,
        label: '预处理JS(preUpdateJs)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocFormatJs,
        label: '格式化JS(formatJs)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocIsVolume,
        label: '分卷规则(isVolume)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocIsVip,
        label: 'VIP规则(isVip)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocIsPay,
        label: '付费规则(isPay)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.tocUpdateTime,
        label: '更新时间规则(updateTime)',
      ),
    ],
  ),
  BookSourceEditSectionSchema(
    title: '正文规则',
    icon: Icons.article,
    fields: [
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.contentBody,
        label: '正文内容规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.contentTitle,
        label: '标题规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.contentNextUrl,
        label: '下一页正文规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.contentWebJs,
        label: 'WebJS',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.contentSourceRegex,
        label: '源正则(sourceRegex)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.contentReplaceRegex,
        label: '替换正则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.contentImageStyle,
        label: '图片样式(imageStyle)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.contentImageDecode,
        label: '图片解密(imageDecode)',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.contentPayAction,
        label: '付费动作(payAction)',
      ),
    ],
  ),
  BookSourceEditSectionSchema(
    title: '发现规则',
    icon: Icons.explore,
    fields: [
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreBookList,
        label: '书籍列表规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreName,
        label: '书名规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreAuthor,
        label: '作者规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreBookUrl,
        label: '书籍地址规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreCoverUrl,
        label: '封面规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreIntro,
        label: '简介规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreKind,
        label: '分类规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreLastChapter,
        label: '最新章节规则',
      ),
      BookSourceEditFieldSchema(
        key: BookSourceEditFieldKey.exploreWordCount,
        label: '字数规则',
      ),
    ],
  ),
];

final List<BookSourceEditFieldSchema> bookSourceEditFields = List.unmodifiable(
  bookSourceEditSections.expand((section) => section.fields),
);

final Map<BookSourceEditFieldKey, BookSourceEditValueReader<db.BookSource>>
    bookSourceFieldReaders = {
  BookSourceEditFieldKey.sourceName: (source) => source.bookSourceName,
  BookSourceEditFieldKey.sourceUrl: (source) => source.bookSourceUrl,
  BookSourceEditFieldKey.sourceGroup: (source) => source.bookSourceGroup,
  BookSourceEditFieldKey.sourceComment: (source) => source.bookSourceComment,
  BookSourceEditFieldKey.searchUrl: (source) => source.searchUrl,
  BookSourceEditFieldKey.exploreUrl: (source) => source.exploreUrl,
  BookSourceEditFieldKey.header: (source) => source.header,
  BookSourceEditFieldKey.loginUrl: (source) => source.loginUrl,
  BookSourceEditFieldKey.concurrentRate: (source) => source.concurrentRate,
  BookSourceEditFieldKey.respondTime: (source) =>
      source.respondTime?.toString(),
  BookSourceEditFieldKey.loginUi: (source) => source.loginUi,
  BookSourceEditFieldKey.loginCheckJs: (source) => source.loginCheckJs,
  BookSourceEditFieldKey.coverDecodeJs: (source) => source.coverDecodeJs,
  BookSourceEditFieldKey.variableComment: (source) => source.variableComment,
  BookSourceEditFieldKey.exploreScreen: (source) => source.exploreScreen,
};

final Map<BookSourceEditFieldKey, BookSourceEditValueReader<db.RuleSearch>>
    bookSourceSearchRuleReaders = {
  BookSourceEditFieldKey.searchBookList: (rule) => rule.bookList,
  BookSourceEditFieldKey.searchName: (rule) => rule.name,
  BookSourceEditFieldKey.searchAuthor: (rule) => rule.author,
  BookSourceEditFieldKey.searchBookUrl: (rule) => rule.bookUrl,
  BookSourceEditFieldKey.searchCoverUrl: (rule) => rule.coverUrl,
  BookSourceEditFieldKey.searchIntro: (rule) => rule.intro,
  BookSourceEditFieldKey.searchKind: (rule) => rule.kind,
  BookSourceEditFieldKey.searchLastChapter: (rule) => rule.lastChapter,
  BookSourceEditFieldKey.searchWordCount: (rule) => rule.wordCount,
  BookSourceEditFieldKey.searchTocUrl: (rule) => rule.tocUrl,
  BookSourceEditFieldKey.searchCheckKeyword: (rule) => rule.checkKeyWord,
  BookSourceEditFieldKey.searchUpdateTime: (rule) => rule.updateTime,
};

final Map<BookSourceEditFieldKey, BookSourceEditValueReader<db.RuleBookInfo>>
    bookSourceBookInfoRuleReaders = {
  BookSourceEditFieldKey.bookInfoInit: (rule) => rule.init,
  BookSourceEditFieldKey.bookInfoName: (rule) => rule.name,
  BookSourceEditFieldKey.bookInfoAuthor: (rule) => rule.author,
  BookSourceEditFieldKey.bookInfoCoverUrl: (rule) => rule.coverUrl,
  BookSourceEditFieldKey.bookInfoIntro: (rule) => rule.intro,
  BookSourceEditFieldKey.bookInfoKind: (rule) => rule.kind,
  BookSourceEditFieldKey.bookInfoTocUrl: (rule) => rule.tocUrl,
  BookSourceEditFieldKey.bookInfoWordCount: (rule) => rule.wordCount,
  BookSourceEditFieldKey.bookInfoLastChapter: (rule) => rule.lastChapter,
  BookSourceEditFieldKey.bookInfoLastReadChapter: (rule) =>
      rule.lastReadChapter,
  BookSourceEditFieldKey.bookInfoCanRename: (rule) => rule.canReName,
  BookSourceEditFieldKey.bookInfoDownloadUrls: (rule) => rule.downloadUrls,
  BookSourceEditFieldKey.bookInfoUpdateTime: (rule) => rule.updateTime,
};

final Map<BookSourceEditFieldKey, BookSourceEditValueReader<db.RuleToc>>
    bookSourceTocRuleReaders = {
  BookSourceEditFieldKey.tocChapterList: (rule) => rule.chapterList,
  BookSourceEditFieldKey.tocChapterName: (rule) => rule.chapterName,
  BookSourceEditFieldKey.tocChapterUrl: (rule) => rule.chapterUrl,
  BookSourceEditFieldKey.tocNextTocUrl: (rule) => rule.nextTocUrl,
  BookSourceEditFieldKey.tocPreUpdateJs: (rule) => rule.preUpdateJs,
  BookSourceEditFieldKey.tocFormatJs: (rule) => rule.formatJs,
  BookSourceEditFieldKey.tocIsVolume: (rule) => rule.isVolume,
  BookSourceEditFieldKey.tocIsVip: (rule) => rule.isVip,
  BookSourceEditFieldKey.tocIsPay: (rule) => rule.isPay,
  BookSourceEditFieldKey.tocUpdateTime: (rule) => rule.updateTime,
};

final Map<BookSourceEditFieldKey, BookSourceEditValueReader<db.RuleContent>>
    bookSourceContentRuleReaders = {
  BookSourceEditFieldKey.contentBody: (rule) => rule.content,
  BookSourceEditFieldKey.contentTitle: (rule) => rule.title,
  BookSourceEditFieldKey.contentNextUrl: (rule) => rule.nextContentUrl,
  BookSourceEditFieldKey.contentWebJs: (rule) => rule.webJs,
  BookSourceEditFieldKey.contentSourceRegex: (rule) => rule.sourceRegex,
  BookSourceEditFieldKey.contentReplaceRegex: (rule) => rule.replaceRegex,
  BookSourceEditFieldKey.contentImageStyle: (rule) => rule.imageStyle,
  BookSourceEditFieldKey.contentImageDecode: (rule) => rule.imageDecode,
  BookSourceEditFieldKey.contentPayAction: (rule) => rule.payAction,
};

final Map<BookSourceEditFieldKey, BookSourceEditValueReader<db.RuleExplore>>
    bookSourceExploreRuleReaders = {
  BookSourceEditFieldKey.exploreBookList: (rule) => rule.bookList,
  BookSourceEditFieldKey.exploreName: (rule) => rule.name,
  BookSourceEditFieldKey.exploreAuthor: (rule) => rule.author,
  BookSourceEditFieldKey.exploreBookUrl: (rule) => rule.bookUrl,
  BookSourceEditFieldKey.exploreCoverUrl: (rule) => rule.coverUrl,
  BookSourceEditFieldKey.exploreIntro: (rule) => rule.intro,
  BookSourceEditFieldKey.exploreKind: (rule) => rule.kind,
  BookSourceEditFieldKey.exploreLastChapter: (rule) => rule.lastChapter,
  BookSourceEditFieldKey.exploreWordCount: (rule) => rule.wordCount,
};
