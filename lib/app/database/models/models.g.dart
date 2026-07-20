// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookChapterInfoImpl _$$BookChapterInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$BookChapterInfoImpl(
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      chapterIndex: (json['chapterIndex'] as num?)?.toInt(),
      chapterName: json['chapterName'] as String?,
      chapterUrl: json['chapterUrl'] as String?,
      isVolume: json['isVolume'] as bool? ?? false,
      isVip: json['isVip'] as bool? ?? false,
      isPay: json['isPay'] as bool? ?? false,
      updateTime: json['updateTime'] as String?,
      baseUrl: json['baseUrl'] as String?,
      variables: (json['variables'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
    );

Map<String, dynamic> _$$BookChapterInfoImplToJson(
        _$BookChapterInfoImpl instance) =>
    <String, dynamic>{
      'bookSourceId': instance.bookSourceId,
      'chapterIndex': instance.chapterIndex,
      'chapterName': instance.chapterName,
      'chapterUrl': instance.chapterUrl,
      'isVolume': instance.isVolume,
      'isVip': instance.isVip,
      'isPay': instance.isPay,
      'updateTime': instance.updateTime,
      'baseUrl': instance.baseUrl,
      'variables': instance.variables,
    };

_$BookContentInfoImpl _$$BookContentInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$BookContentInfoImpl(
      id: (json['id'] as num).toInt(),
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      name: json['name'] as String?,
      chapterIndex: (json['chapterIndex'] as num?)?.toInt(),
      bookContentList: (json['bookContentList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$BookContentInfoImplToJson(
        _$BookContentInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookSourceId': instance.bookSourceId,
      'name': instance.name,
      'chapterIndex': instance.chapterIndex,
      'bookContentList': instance.bookContentList,
      'pageSize': instance.pageSize,
    };

_$BookDetailImpl _$$BookDetailImplFromJson(Map<String, dynamic> json) =>
    _$BookDetailImpl(
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      name: json['name'] as String?,
      author: json['author'] as String?,
      cover: json['cover'] as String?,
      intro: json['intro'] as String?,
      kind: (json['kind'] as List<dynamic>?)?.map((e) => e as String).toList(),
      lastChapter: json['lastChapter'] as String?,
      wordCount: json['wordCount'] as String?,
      downloadUrls: json['downloadUrls'] as String?,
      bookUrl: json['bookUrl'] as String?,
      tocUrl: json['tocUrl'] as String?,
      updateTime: json['updateTime'] as String?,
      isAscending: json['isAscending'] as bool? ?? true,
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((e) => BookChapterInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$BookDetailImplToJson(_$BookDetailImpl instance) =>
    <String, dynamic>{
      'bookSourceId': instance.bookSourceId,
      'name': instance.name,
      'author': instance.author,
      'cover': instance.cover,
      'intro': instance.intro,
      'kind': instance.kind,
      'lastChapter': instance.lastChapter,
      'wordCount': instance.wordCount,
      'downloadUrls': instance.downloadUrls,
      'bookUrl': instance.bookUrl,
      'tocUrl': instance.tocUrl,
      'updateTime': instance.updateTime,
      'isAscending': instance.isAscending,
      'chapters': instance.chapters,
    };

_$BookInfoImpl _$$BookInfoImplFromJson(Map<String, dynamic> json) =>
    _$BookInfoImpl(
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      name: json['name'] as String,
      author: json['author'] as String?,
      cover: json['cover'] as String?,
      intro: json['intro'] as String?,
      kind: json['kind'] as String?,
      lastChapter: json['lastChapter'] as String?,
      wordCount: json['wordCount'] as String?,
      bookUrl: json['bookUrl'] as String?,
      tocUrl: json['tocUrl'] as String?,
    );

Map<String, dynamic> _$$BookInfoImplToJson(_$BookInfoImpl instance) =>
    <String, dynamic>{
      'bookSourceId': instance.bookSourceId,
      'name': instance.name,
      'author': instance.author,
      'cover': instance.cover,
      'intro': instance.intro,
      'kind': instance.kind,
      'lastChapter': instance.lastChapter,
      'wordCount': instance.wordCount,
      'bookUrl': instance.bookUrl,
      'tocUrl': instance.tocUrl,
    };

_$BookReadProgressImpl _$$BookReadProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$BookReadProgressImpl(
      id: (json['id'] as num).toInt(),
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      bookName: json['bookName'] as String,
      chapterIndex: (json['chapterIndex'] as num).toInt(),
      locatorJson: json['locatorJson'] as String,
      updateTime: DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$$BookReadProgressImplToJson(
        _$BookReadProgressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookSourceId': instance.bookSourceId,
      'bookName': instance.bookName,
      'chapterIndex': instance.chapterIndex,
      'locatorJson': instance.locatorJson,
      'updateTime': instance.updateTime.toIso8601String(),
    };

_$BookSearchInfoImpl _$$BookSearchInfoImplFromJson(Map<String, dynamic> json) =>
    _$BookSearchInfoImpl(
      id: (json['id'] as num).toInt(),
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      searchUrl: json['searchUrl'] as String,
      method: json['method'] as String,
      charset: json['charset'] as String,
      headers: json['headers'] as String?,
      body: json['body'] as String?,
    );

Map<String, dynamic> _$$BookSearchInfoImplToJson(
        _$BookSearchInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookSourceId': instance.bookSourceId,
      'searchUrl': instance.searchUrl,
      'method': instance.method,
      'charset': instance.charset,
      'headers': instance.headers,
      'body': instance.body,
    };

_$BookSourceImpl _$$BookSourceImplFromJson(Map<String, dynamic> json) =>
    _$BookSourceImpl(
      id: (json['id'] as num).toInt(),
      bookSourceName: json['bookSourceName'] as String,
      bookSourceGroup: json['bookSourceGroup'] as String?,
      bookSourceComment: json['bookSourceComment'] as String?,
      bookSourceUrl: json['bookSourceUrl'] as String,
      customOrder: (json['customOrder'] as num?)?.toInt(),
      bookUrlPattern: json['bookUrlPattern'] as String?,
      bookSourceType: (json['bookSourceType'] as num?)?.toInt(),
      enabled: json['enabled'] as bool? ?? false,
      enabledCookieJar: json['enabledCookieJar'] as bool?,
      enabledExplore: json['enabledExplore'] as bool?,
      header: json['header'] as String?,
      loginUrl: json['loginUrl'] as String?,
      lastUpdateTime: json['lastUpdateTime'] as String?,
      exploreUrl: json['exploreUrl'] as String?,
      searchUrl: json['searchUrl'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
      isEnabled: json['isEnabled'] as bool?,
      concurrentRate: json['concurrentRate'] as String?,
      respondTime: (json['respondTime'] as num?)?.toInt(),
      loginUi: json['loginUi'] as String?,
      loginCheckJs: json['loginCheckJs'] as String?,
      coverDecodeJs: json['coverDecodeJs'] as String?,
      variableComment: json['variableComment'] as String?,
      exploreScreen: json['exploreScreen'] as String?,
    );

Map<String, dynamic> _$$BookSourceImplToJson(_$BookSourceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookSourceName': instance.bookSourceName,
      'bookSourceGroup': instance.bookSourceGroup,
      'bookSourceComment': instance.bookSourceComment,
      'bookSourceUrl': instance.bookSourceUrl,
      'customOrder': instance.customOrder,
      'bookUrlPattern': instance.bookUrlPattern,
      'bookSourceType': instance.bookSourceType,
      'enabled': instance.enabled,
      'enabledCookieJar': instance.enabledCookieJar,
      'enabledExplore': instance.enabledExplore,
      'header': instance.header,
      'loginUrl': instance.loginUrl,
      'lastUpdateTime': instance.lastUpdateTime,
      'exploreUrl': instance.exploreUrl,
      'searchUrl': instance.searchUrl,
      'weight': instance.weight,
      'isEnabled': instance.isEnabled,
      'concurrentRate': instance.concurrentRate,
      'respondTime': instance.respondTime,
      'loginUi': instance.loginUi,
      'loginCheckJs': instance.loginCheckJs,
      'coverDecodeJs': instance.coverDecodeJs,
      'variableComment': instance.variableComment,
      'exploreScreen': instance.exploreScreen,
    };

_$ExploreKindImpl _$$ExploreKindImplFromJson(Map<String, dynamic> json) =>
    _$ExploreKindImpl(
      title: json['title'] as String,
      url: json['url'] as String,
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      bookSourceName: json['bookSourceName'] as String,
    );

Map<String, dynamic> _$$ExploreKindImplToJson(_$ExploreKindImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'url': instance.url,
      'bookSourceId': instance.bookSourceId,
      'bookSourceName': instance.bookSourceName,
    };

_$RuleBookInfoImpl _$$RuleBookInfoImplFromJson(Map<String, dynamic> json) =>
    _$RuleBookInfoImpl(
      id: (json['id'] as num).toInt(),
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      author: json['author'] as String?,
      coverUrl: json['coverUrl'] as String?,
      init: json['init'] as String?,
      intro: json['intro'] as String?,
      kind: json['kind'] as String?,
      lastChapter: json['lastChapter'] as String?,
      name: json['name'] as String?,
      tocUrl: json['tocUrl'] as String?,
      wordCount: json['wordCount'] as String?,
      lastReadChapter: json['lastReadChapter'] as String?,
      canReName: json['canReName'] as String?,
      downloadUrls: json['downloadUrls'] as String?,
      updateTime: json['updateTime'] as String?,
    );

Map<String, dynamic> _$$RuleBookInfoImplToJson(_$RuleBookInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookSourceId': instance.bookSourceId,
      'author': instance.author,
      'coverUrl': instance.coverUrl,
      'init': instance.init,
      'intro': instance.intro,
      'kind': instance.kind,
      'lastChapter': instance.lastChapter,
      'name': instance.name,
      'tocUrl': instance.tocUrl,
      'wordCount': instance.wordCount,
      'lastReadChapter': instance.lastReadChapter,
      'canReName': instance.canReName,
      'downloadUrls': instance.downloadUrls,
      'updateTime': instance.updateTime,
    };

_$RuleContentImpl _$$RuleContentImplFromJson(Map<String, dynamic> json) =>
    _$RuleContentImpl(
      id: (json['id'] as num).toInt(),
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      content: json['content'] as String?,
      nextContentUrl: json['nextContentUrl'] as String?,
      replaceRegex: json['replaceRegex'] as String?,
      title: json['title'] as String?,
      webJs: json['webJs'] as String?,
      sourceRegex: json['sourceRegex'] as String?,
      imageStyle: json['imageStyle'] as String?,
      imageDecode: json['imageDecode'] as String?,
      payAction: json['payAction'] as String?,
    );

Map<String, dynamic> _$$RuleContentImplToJson(_$RuleContentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookSourceId': instance.bookSourceId,
      'content': instance.content,
      'nextContentUrl': instance.nextContentUrl,
      'replaceRegex': instance.replaceRegex,
      'title': instance.title,
      'webJs': instance.webJs,
      'sourceRegex': instance.sourceRegex,
      'imageStyle': instance.imageStyle,
      'imageDecode': instance.imageDecode,
      'payAction': instance.payAction,
    };

_$RuleSearchImpl _$$RuleSearchImplFromJson(Map<String, dynamic> json) =>
    _$RuleSearchImpl(
      id: (json['id'] as num).toInt(),
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      name: json['name'] as String?,
      author: json['author'] as String?,
      bookList: json['bookList'] as String?,
      bookUrl: json['bookUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      intro: json['intro'] as String?,
      kind: json['kind'] as String?,
      lastChapter: json['lastChapter'] as String?,
      wordCount: json['wordCount'] as String?,
      tocUrl: json['tocUrl'] as String?,
      checkKeyWord: json['checkKeyWord'] as String?,
      updateTime: json['updateTime'] as String?,
    );

Map<String, dynamic> _$$RuleSearchImplToJson(_$RuleSearchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookSourceId': instance.bookSourceId,
      'name': instance.name,
      'author': instance.author,
      'bookList': instance.bookList,
      'bookUrl': instance.bookUrl,
      'coverUrl': instance.coverUrl,
      'intro': instance.intro,
      'kind': instance.kind,
      'lastChapter': instance.lastChapter,
      'wordCount': instance.wordCount,
      'tocUrl': instance.tocUrl,
      'checkKeyWord': instance.checkKeyWord,
      'updateTime': instance.updateTime,
    };

_$RuleTocImpl _$$RuleTocImplFromJson(Map<String, dynamic> json) =>
    _$RuleTocImpl(
      id: (json['id'] as num).toInt(),
      bookSourceId: (json['bookSourceId'] as num).toInt(),
      chapterList: json['chapterList'] as String?,
      chapterName: json['chapterName'] as String?,
      chapterUrl: json['chapterUrl'] as String?,
      nextTocUrl: json['nextTocUrl'] as String?,
      preUpdateJs: json['preUpdateJs'] as String?,
      formatJs: json['formatJs'] as String?,
      isVolume: json['isVolume'] as String?,
      isVip: json['isVip'] as String?,
      isPay: json['isPay'] as String?,
      updateTime: json['updateTime'] as String?,
    );

Map<String, dynamic> _$$RuleTocImplToJson(_$RuleTocImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookSourceId': instance.bookSourceId,
      'chapterList': instance.chapterList,
      'chapterName': instance.chapterName,
      'chapterUrl': instance.chapterUrl,
      'nextTocUrl': instance.nextTocUrl,
      'preUpdateJs': instance.preUpdateJs,
      'formatJs': instance.formatJs,
      'isVolume': instance.isVolume,
      'isVip': instance.isVip,
      'isPay': instance.isPay,
      'updateTime': instance.updateTime,
    };
