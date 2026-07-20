import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import '../../../../app/database/drift/app_database.dart' as db;

class BookSourceDto {
  final int? id;
  final String bookSourceName;
  final String bookSourceUrl;
  final String? bookSourceGroup;
  final String? bookSourceComment;
  final String? jsLib;
  final int? customOrder;
  final String? bookUrlPattern;
  final int? bookSourceType;
  final bool enabled;
  final bool? enabledCookieJar;
  final bool? enabledExplore;
  final String? header;
  final String? loginUrl;
  final String? lastUpdateTime;
  final String? exploreUrl;
  final String? searchUrl;
  final int? weight;
  final bool? isEnabled;
  final String? concurrentRate;
  final int? respondTime;
  final String? loginUi;
  final String? loginCheckJs;
  final String? coverDecodeJs;
  final String? variableComment;
  final String? exploreScreen;

  final Map<String, dynamic>? ruleBookInfo;
  final Map<String, dynamic>? ruleContent;
  final Map<String, dynamic>? ruleSearch;
  final Map<String, dynamic>? ruleToc;
  final Map<String, dynamic>? ruleExplore;
  final Map<String, dynamic>? ruleReview;

  BookSourceDto({
    required this.id,
    required this.bookSourceName,
    required this.bookSourceUrl,
    required this.bookSourceGroup,
    required this.bookSourceComment,
    required this.jsLib,
    required this.customOrder,
    required this.bookUrlPattern,
    required this.bookSourceType,
    required this.enabled,
    required this.enabledCookieJar,
    required this.enabledExplore,
    required this.header,
    required this.loginUrl,
    required this.lastUpdateTime,
    required this.exploreUrl,
    required this.searchUrl,
    required this.weight,
    required this.isEnabled,
    required this.concurrentRate,
    required this.respondTime,
    required this.loginUi,
    required this.loginCheckJs,
    required this.coverDecodeJs,
    required this.variableComment,
    required this.exploreScreen,
    required this.ruleBookInfo,
    required this.ruleContent,
    required this.ruleSearch,
    required this.ruleToc,
    required this.ruleExplore,
    required this.ruleReview,
  });

  factory BookSourceDto.fromJson(Map<String, dynamic> json) {
    return BookSourceDto(
      id: _intFrom(json, const ['id']),
      bookSourceName: _stringFrom(
              json, const ['bookSourceName', 'book_source_name', 'name']) ??
          '',
      bookSourceUrl: _stringFrom(
              json, const ['bookSourceUrl', 'book_source_url', 'url']) ??
          '',
      bookSourceGroup: _stringFrom(json, const [
        'bookSourceGroup',
        'book_source_group',
        'groupName',
        'group_name'
      ]),
      bookSourceComment: _stringFrom(
          json, const ['bookSourceComment', 'book_source_comment', 'comment']),
      jsLib: _stringFrom(json, const ['jsLib', 'js_lib', 'bookSourceJsLib']),
      customOrder: _intFrom(json, const ['customOrder', 'custom_order']),
      bookUrlPattern:
          _stringFrom(json, const ['bookUrlPattern', 'book_url_pattern']),
      bookSourceType: _intFrom(json, const [
        'bookSourceType',
        'book_source_type',
        'sourceType',
        'source_type'
      ]),
      enabled: _boolFrom(json, const ['enabled']) ?? true,
      enabledCookieJar:
          _boolFrom(json, const ['enabledCookieJar', 'enabled_cookie_jar']),
      enabledExplore:
          _boolFrom(json, const ['enabledExplore', 'enabled_explore']) ?? true,
      header: _stringFrom(json, const ['header']),
      loginUrl: _stringFrom(json, const ['loginUrl', 'login_url']),
      lastUpdateTime:
          _stringFrom(json, const ['lastUpdateTime', 'last_update_time']),
      exploreUrl: _stringFrom(json, const ['exploreUrl', 'explore_url']),
      searchUrl: _stringFrom(json, const ['searchUrl', 'search_url']),
      weight: _intFrom(json, const ['weight']),
      isEnabled: _boolFrom(json, const ['isEnabled', 'is_enabled']),
      concurrentRate:
          _stringFrom(json, const ['concurrentRate', 'concurrent_rate']),
      respondTime: _intFrom(json, const ['respondTime', 'respond_time']),
      loginUi: _stringFrom(json, const ['loginUi', 'login_ui']),
      loginCheckJs: _stringFrom(json, const ['loginCheckJs', 'login_check_js']),
      coverDecodeJs:
          _stringFrom(json, const ['coverDecodeJs', 'cover_decode_js']),
      variableComment:
          _stringFrom(json, const ['variableComment', 'variable_comment']),
      exploreScreen:
          _stringFrom(json, const ['exploreScreen', 'explore_screen']),
      ruleBookInfo: _mapFrom(json, const ['ruleBookInfo', 'rule_book_info']),
      ruleContent: _mapFrom(json, const ['ruleContent', 'rule_content']),
      ruleSearch: _mapFrom(json, const ['ruleSearch', 'rule_search']),
      ruleToc: _mapFrom(json, const ['ruleToc', 'rule_toc']),
      ruleExplore: _mapFrom(json, const ['ruleExplore', 'rule_explore']),
      ruleReview: _mapFrom(json, const ['ruleReview', 'rule_review']),
    );
  }

  factory BookSourceDto.fromDatabase({
    required db.BookSource source,
    db.RuleBookInfo? ruleBookInfo,
    db.RuleContent? ruleContent,
    db.RuleSearch? ruleSearch,
    db.RuleToc? ruleToc,
    db.RuleExplore? ruleExplore,
  }) {
    return BookSourceDto(
      id: source.id,
      bookSourceName: source.bookSourceName,
      bookSourceUrl: source.bookSourceUrl,
      bookSourceGroup: source.bookSourceGroup,
      bookSourceComment: source.bookSourceComment,
      jsLib: source.jsLib,
      customOrder: source.customOrder,
      bookUrlPattern: source.bookUrlPattern,
      bookSourceType: source.bookSourceType,
      enabled: source.enabled,
      enabledCookieJar: source.enabledCookieJar,
      enabledExplore: source.enabledExplore,
      header: source.header,
      loginUrl: source.loginUrl,
      lastUpdateTime: source.lastUpdateTime,
      exploreUrl: source.exploreUrl,
      searchUrl: source.searchUrl,
      weight: source.weight,
      isEnabled: source.isEnabled,
      concurrentRate: source.concurrentRate,
      respondTime: source.respondTime,
      loginUi: source.loginUi,
      loginCheckJs: source.loginCheckJs,
      coverDecodeJs: source.coverDecodeJs,
      variableComment: source.variableComment,
      exploreScreen: source.exploreScreen,
      ruleBookInfo: ruleBookInfo == null
          ? null
          : {
              'id': ruleBookInfo.id,
              'author': ruleBookInfo.author,
              'coverUrl': ruleBookInfo.coverUrl,
              'init': ruleBookInfo.init,
              'intro': ruleBookInfo.intro,
              'kind': ruleBookInfo.kind,
              'lastChapter': ruleBookInfo.lastChapter,
              'name': ruleBookInfo.name,
              'tocUrl': ruleBookInfo.tocUrl,
              'wordCount': ruleBookInfo.wordCount,
              'lastReadChapter': ruleBookInfo.lastReadChapter,
              'canReName': ruleBookInfo.canReName,
              'downloadUrls': ruleBookInfo.downloadUrls,
              'updateTime': ruleBookInfo.updateTime,
            },
      ruleContent: ruleContent == null
          ? null
          : {
              'id': ruleContent.id,
              'content': ruleContent.content,
              'title': ruleContent.title,
              'nextContentUrl': ruleContent.nextContentUrl,
              'webJs': ruleContent.webJs,
              'sourceRegex': ruleContent.sourceRegex,
              'replaceRegex': ruleContent.replaceRegex,
              'imageStyle': ruleContent.imageStyle,
              'imageDecode': ruleContent.imageDecode,
              'payAction': ruleContent.payAction,
            },
      ruleSearch: ruleSearch == null
          ? null
          : {
              'id': ruleSearch.id,
              'name': ruleSearch.name,
              'author': ruleSearch.author,
              'bookList': ruleSearch.bookList,
              'bookUrl': ruleSearch.bookUrl,
              'coverUrl': ruleSearch.coverUrl,
              'intro': ruleSearch.intro,
              'kind': ruleSearch.kind,
              'lastChapter': ruleSearch.lastChapter,
              'wordCount': ruleSearch.wordCount,
              'tocUrl': ruleSearch.tocUrl,
              'checkKeyWord': ruleSearch.checkKeyWord,
              'updateTime': ruleSearch.updateTime,
            },
      ruleToc: ruleToc == null
          ? null
          : {
              'id': ruleToc.id,
              'chapterList': ruleToc.chapterList,
              'chapterName': ruleToc.chapterName,
              'chapterUrl': ruleToc.chapterUrl,
              'nextTocUrl': ruleToc.nextTocUrl,
              'preUpdateJs': ruleToc.preUpdateJs,
              'formatJs': ruleToc.formatJs,
              'isVolume': ruleToc.isVolume,
              'isVip': ruleToc.isVip,
              'isPay': ruleToc.isPay,
              'updateTime': ruleToc.updateTime,
            },
      ruleExplore: ruleExplore == null
          ? null
          : {
              'id': ruleExplore.id,
              'bookList': ruleExplore.bookList,
              'name': ruleExplore.name,
              'author': ruleExplore.author,
              'bookUrl': ruleExplore.bookUrl,
              'coverUrl': ruleExplore.coverUrl,
              'intro': ruleExplore.intro,
              'kind': ruleExplore.kind,
              'lastChapter': ruleExplore.lastChapter,
              'wordCount': ruleExplore.wordCount,
            },
      ruleReview: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookSourceName': bookSourceName,
      'bookSourceGroup': bookSourceGroup,
      'bookSourceComment': bookSourceComment,
      'jsLib': jsLib,
      'bookSourceUrl': bookSourceUrl,
      'customOrder': customOrder,
      'bookUrlPattern': bookUrlPattern,
      'bookSourceType': bookSourceType,
      'enabled': enabled,
      'enabledCookieJar': enabledCookieJar,
      'enabledExplore': enabledExplore,
      'header': header,
      'loginUrl': loginUrl,
      'lastUpdateTime': lastUpdateTime,
      'exploreUrl': exploreUrl,
      'searchUrl': searchUrl,
      'weight': weight,
      'isEnabled': isEnabled,
      'concurrentRate': concurrentRate,
      'respondTime': respondTime,
      'loginUi': loginUi,
      'loginCheckJs': loginCheckJs,
      'coverDecodeJs': coverDecodeJs,
      'variableComment': variableComment,
      'exploreScreen': exploreScreen,
      'ruleBookInfo': ruleBookInfo,
      'ruleContent': ruleContent,
      'ruleSearch': ruleSearch,
      'ruleToc': ruleToc,
      'ruleExplore': ruleExplore,
      'ruleReview': ruleReview,
    };
  }

  db.BookSourcesCompanion toBookSourcesCompanion(int sourceId) {
    return db.BookSourcesCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceName: bookSourceName,
      bookSourceUrl: bookSourceUrl,
      bookSourceGroup: drift.Value(bookSourceGroup),
      bookSourceComment: drift.Value(bookSourceComment),
      jsLib: drift.Value(jsLib),
      customOrder: drift.Value(customOrder),
      bookUrlPattern: drift.Value(bookUrlPattern),
      bookSourceType: drift.Value(bookSourceType),
      enabled: drift.Value(enabled),
      enabledCookieJar: drift.Value(enabledCookieJar),
      enabledExplore: drift.Value(enabledExplore),
      header: drift.Value(header),
      loginUrl: drift.Value(loginUrl),
      lastUpdateTime: drift.Value(lastUpdateTime),
      exploreUrl: drift.Value(exploreUrl),
      searchUrl: drift.Value(searchUrl),
      weight: drift.Value(weight),
      isEnabled: drift.Value(isEnabled),
      concurrentRate: drift.Value(concurrentRate),
      respondTime: drift.Value(respondTime),
      loginUi: drift.Value(loginUi),
      loginCheckJs: drift.Value(loginCheckJs),
      coverDecodeJs: drift.Value(coverDecodeJs),
      variableComment: drift.Value(variableComment),
      exploreScreen: drift.Value(exploreScreen),
    );
  }

  db.RuleBookInfosCompanion? toRuleBookInfoCompanion(int sourceId) {
    final rule = ruleBookInfo;
    if (rule == null) return null;
    return db.RuleBookInfosCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      author: drift.Value(_ruleString(rule, const ['author'])),
      coverUrl: drift.Value(_ruleString(rule, const ['coverUrl', 'cover_url'])),
      init: drift.Value(
        _ruleString(rule, const ['init', 'bookInfoInit', 'book_info_init']),
      ),
      intro: drift.Value(_ruleString(rule, const ['intro'])),
      kind: drift.Value(_ruleString(rule, const ['kind'])),
      lastChapter:
          drift.Value(_ruleString(rule, const ['lastChapter', 'last_chapter'])),
      name: drift.Value(_ruleString(rule, const ['name'])),
      tocUrl: drift.Value(_ruleString(rule, const ['tocUrl', 'toc_url'])),
      wordCount:
          drift.Value(_ruleString(rule, const ['wordCount', 'word_count'])),
      lastReadChapter: drift.Value(
          _ruleString(rule, const ['lastReadChapter', 'last_read_chapter'])),
      canReName:
          drift.Value(_ruleString(rule, const ['canReName', 'can_rename'])),
      downloadUrls: drift.Value(
          _ruleString(rule, const ['downloadUrls', 'download_urls'])),
      updateTime:
          drift.Value(_ruleString(rule, const ['updateTime', 'update_time'])),
    );
  }

  db.RuleContentsCompanion? toRuleContentCompanion(int sourceId) {
    final rule = ruleContent;
    if (rule == null) return null;
    return db.RuleContentsCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      content: drift.Value(_ruleString(rule, const ['content'])),
      title: drift.Value(_ruleString(rule, const ['title'])),
      nextContentUrl: drift.Value(
          _ruleString(rule, const ['nextContentUrl', 'next_content_url'])),
      webJs: drift.Value(_ruleString(rule, const ['webJs', 'web_js'])),
      sourceRegex:
          drift.Value(_ruleString(rule, const ['sourceRegex', 'source_regex'])),
      replaceRegex: drift.Value(
          _ruleString(rule, const ['replaceRegex', 'replace_regex'])),
      imageStyle:
          drift.Value(_ruleString(rule, const ['imageStyle', 'image_style'])),
      imageDecode:
          drift.Value(_ruleString(rule, const ['imageDecode', 'image_decode'])),
      payAction:
          drift.Value(_ruleString(rule, const ['payAction', 'pay_action'])),
    );
  }

  db.RuleSearchsCompanion? toRuleSearchCompanion(int sourceId) {
    final rule = ruleSearch;
    if (rule == null) return null;
    return db.RuleSearchsCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      name: drift.Value(_ruleString(rule, const ['name'])),
      author: drift.Value(_ruleString(rule, const ['author'])),
      bookList: drift.Value(_ruleString(rule, const ['bookList', 'book_list'])),
      bookUrl: drift.Value(_ruleString(rule, const ['bookUrl', 'book_url'])),
      coverUrl: drift.Value(_ruleString(rule, const ['coverUrl', 'cover_url'])),
      intro: drift.Value(_ruleString(rule, const ['intro'])),
      kind: drift.Value(_ruleString(rule, const ['kind'])),
      lastChapter:
          drift.Value(_ruleString(rule, const ['lastChapter', 'last_chapter'])),
      wordCount:
          drift.Value(_ruleString(rule, const ['wordCount', 'word_count'])),
      tocUrl: drift.Value(_ruleString(rule, const ['tocUrl', 'toc_url'])),
      checkKeyWord: drift.Value(searchCheckKeyword),
      updateTime:
          drift.Value(_ruleString(rule, const ['updateTime', 'update_time'])),
    );
  }

  db.RuleTocsCompanion? toRuleTocCompanion(int sourceId) {
    final rule = ruleToc;
    if (rule == null) return null;
    return db.RuleTocsCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      chapterList:
          drift.Value(_ruleString(rule, const ['chapterList', 'chapter_list'])),
      chapterName:
          drift.Value(_ruleString(rule, const ['chapterName', 'chapter_name'])),
      chapterUrl:
          drift.Value(_ruleString(rule, const ['chapterUrl', 'chapter_url'])),
      nextTocUrl:
          drift.Value(_ruleString(rule, const ['nextTocUrl', 'next_toc_url'])),
      preUpdateJs: drift.Value(
          _ruleString(rule, const ['preUpdateJs', 'pre_update_js'])),
      formatJs: drift.Value(_ruleString(rule, const ['formatJs', 'format_js'])),
      isVolume: drift.Value(_ruleString(rule, const ['isVolume', 'is_volume'])),
      isVip: drift.Value(_ruleString(rule, const ['isVip', 'is_vip'])),
      isPay: drift.Value(_ruleString(rule, const ['isPay', 'is_pay'])),
      updateTime:
          drift.Value(_ruleString(rule, const ['updateTime', 'update_time'])),
    );
  }

  db.RuleExploresCompanion? toRuleExploreCompanion(int sourceId) {
    final rule = ruleExplore ?? ruleSearch;
    if (rule == null) return null;
    return db.RuleExploresCompanion.insert(
      id: drift.Value(sourceId),
      bookSourceId: sourceId,
      bookList: drift.Value(_ruleString(rule, const ['bookList', 'book_list'])),
      name: drift.Value(_ruleString(rule, const ['name'])),
      author: drift.Value(_ruleString(rule, const ['author'])),
      bookUrl: drift.Value(_ruleString(rule, const ['bookUrl', 'book_url'])),
      coverUrl: drift.Value(_ruleString(rule, const ['coverUrl', 'cover_url'])),
      intro: drift.Value(_ruleString(rule, const ['intro'])),
      kind: drift.Value(_ruleString(rule, const ['kind'])),
      lastChapter:
          drift.Value(_ruleString(rule, const ['lastChapter', 'last_chapter'])),
      wordCount:
          drift.Value(_ruleString(rule, const ['wordCount', 'word_count'])),
    );
  }

  String? get searchCheckKeyword {
    final rule = ruleSearch;
    if (rule == null) return null;
    final value = _ruleString(
            rule, const ['checkKeyWord', 'check_key_word', 'check_keyword'])
        ?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static dynamic _first(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value;
    }
    return null;
  }

  static String? _stringFrom(Map<String, dynamic> json, List<String> keys) =>
      _string(_first(json, keys));

  static int? _intFrom(Map<String, dynamic> json, List<String> keys) =>
      _int(_first(json, keys));

  static bool? _boolFrom(Map<String, dynamic> json, List<String> keys) =>
      _bool(_first(json, keys));

  static Map<String, dynamic>? _mapFrom(
    Map<String, dynamic> json,
    List<String> keys,
  ) =>
      _map(_first(json, keys));

  static String? _ruleString(Map<String, dynamic> rule, List<String> keys) =>
      _string(_first(rule, keys));

  static Map<String, dynamic>? _map(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    if (raw is String) {
      final value = raw.trim();
      if (value.isEmpty) return null;
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  static String? _string(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map || raw is List) {
      final value = jsonEncode(raw);
      return value.isEmpty ? null : value;
    }
    final value = raw.toString();
    return value.isEmpty ? null : value;
  }

  static int? _int(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static bool? _bool(dynamic raw) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    final normalized = raw.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }
}
