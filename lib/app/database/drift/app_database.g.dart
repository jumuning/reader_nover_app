// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BookSourcesTable extends BookSources
    with TableInfo<$BookSourcesTable, BookSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceNameMeta =
      const VerificationMeta('bookSourceName');
  @override
  late final GeneratedColumn<String> bookSourceName = GeneratedColumn<String>(
      'book_source_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookSourceGroupMeta =
      const VerificationMeta('bookSourceGroup');
  @override
  late final GeneratedColumn<String> bookSourceGroup = GeneratedColumn<String>(
      'book_source_group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceCommentMeta =
      const VerificationMeta('bookSourceComment');
  @override
  late final GeneratedColumn<String> bookSourceComment =
      GeneratedColumn<String>('book_source_comment', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _jsLibMeta = const VerificationMeta('jsLib');
  @override
  late final GeneratedColumn<String> jsLib = GeneratedColumn<String>(
      'js_lib', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceUrlMeta =
      const VerificationMeta('bookSourceUrl');
  @override
  late final GeneratedColumn<String> bookSourceUrl = GeneratedColumn<String>(
      'book_source_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customOrderMeta =
      const VerificationMeta('customOrder');
  @override
  late final GeneratedColumn<int> customOrder = GeneratedColumn<int>(
      'custom_order', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookUrlPatternMeta =
      const VerificationMeta('bookUrlPattern');
  @override
  late final GeneratedColumn<String> bookUrlPattern = GeneratedColumn<String>(
      'book_url_pattern', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceTypeMeta =
      const VerificationMeta('bookSourceType');
  @override
  late final GeneratedColumn<int> bookSourceType = GeneratedColumn<int>(
      'book_source_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _enabledCookieJarMeta =
      const VerificationMeta('enabledCookieJar');
  @override
  late final GeneratedColumn<bool> enabledCookieJar = GeneratedColumn<bool>(
      'enabled_cookie_jar', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enabled_cookie_jar" IN (0, 1))'));
  static const VerificationMeta _enabledExploreMeta =
      const VerificationMeta('enabledExplore');
  @override
  late final GeneratedColumn<bool> enabledExplore = GeneratedColumn<bool>(
      'enabled_explore', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enabled_explore" IN (0, 1))'));
  static const VerificationMeta _headerMeta = const VerificationMeta('header');
  @override
  late final GeneratedColumn<String> header = GeneratedColumn<String>(
      'header', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loginUrlMeta =
      const VerificationMeta('loginUrl');
  @override
  late final GeneratedColumn<String> loginUrl = GeneratedColumn<String>(
      'login_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastUpdateTimeMeta =
      const VerificationMeta('lastUpdateTime');
  @override
  late final GeneratedColumn<String> lastUpdateTime = GeneratedColumn<String>(
      'last_update_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exploreUrlMeta =
      const VerificationMeta('exploreUrl');
  @override
  late final GeneratedColumn<String> exploreUrl = GeneratedColumn<String>(
      'explore_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _searchUrlMeta =
      const VerificationMeta('searchUrl');
  @override
  late final GeneratedColumn<String> searchUrl = GeneratedColumn<String>(
      'search_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
      'weight', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'));
  static const VerificationMeta _concurrentRateMeta =
      const VerificationMeta('concurrentRate');
  @override
  late final GeneratedColumn<String> concurrentRate = GeneratedColumn<String>(
      'concurrent_rate', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _respondTimeMeta =
      const VerificationMeta('respondTime');
  @override
  late final GeneratedColumn<int> respondTime = GeneratedColumn<int>(
      'respond_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _loginUiMeta =
      const VerificationMeta('loginUi');
  @override
  late final GeneratedColumn<String> loginUi = GeneratedColumn<String>(
      'login_ui', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loginCheckJsMeta =
      const VerificationMeta('loginCheckJs');
  @override
  late final GeneratedColumn<String> loginCheckJs = GeneratedColumn<String>(
      'login_check_js', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverDecodeJsMeta =
      const VerificationMeta('coverDecodeJs');
  @override
  late final GeneratedColumn<String> coverDecodeJs = GeneratedColumn<String>(
      'cover_decode_js', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variableCommentMeta =
      const VerificationMeta('variableComment');
  @override
  late final GeneratedColumn<String> variableComment = GeneratedColumn<String>(
      'variable_comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exploreScreenMeta =
      const VerificationMeta('exploreScreen');
  @override
  late final GeneratedColumn<String> exploreScreen = GeneratedColumn<String>(
      'explore_screen', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceName,
        bookSourceGroup,
        bookSourceComment,
        jsLib,
        bookSourceUrl,
        customOrder,
        bookUrlPattern,
        bookSourceType,
        enabled,
        enabledCookieJar,
        enabledExplore,
        header,
        loginUrl,
        lastUpdateTime,
        exploreUrl,
        searchUrl,
        weight,
        isEnabled,
        concurrentRate,
        respondTime,
        loginUi,
        loginCheckJs,
        coverDecodeJs,
        variableComment,
        exploreScreen
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_sources';
  @override
  VerificationContext validateIntegrity(Insertable<BookSource> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_name')) {
      context.handle(
          _bookSourceNameMeta,
          bookSourceName.isAcceptableOrUnknown(
              data['book_source_name']!, _bookSourceNameMeta));
    } else if (isInserting) {
      context.missing(_bookSourceNameMeta);
    }
    if (data.containsKey('book_source_group')) {
      context.handle(
          _bookSourceGroupMeta,
          bookSourceGroup.isAcceptableOrUnknown(
              data['book_source_group']!, _bookSourceGroupMeta));
    }
    if (data.containsKey('book_source_comment')) {
      context.handle(
          _bookSourceCommentMeta,
          bookSourceComment.isAcceptableOrUnknown(
              data['book_source_comment']!, _bookSourceCommentMeta));
    }
    if (data.containsKey('js_lib')) {
      context.handle(
          _jsLibMeta, jsLib.isAcceptableOrUnknown(data['js_lib']!, _jsLibMeta));
    }
    if (data.containsKey('book_source_url')) {
      context.handle(
          _bookSourceUrlMeta,
          bookSourceUrl.isAcceptableOrUnknown(
              data['book_source_url']!, _bookSourceUrlMeta));
    } else if (isInserting) {
      context.missing(_bookSourceUrlMeta);
    }
    if (data.containsKey('custom_order')) {
      context.handle(
          _customOrderMeta,
          customOrder.isAcceptableOrUnknown(
              data['custom_order']!, _customOrderMeta));
    }
    if (data.containsKey('book_url_pattern')) {
      context.handle(
          _bookUrlPatternMeta,
          bookUrlPattern.isAcceptableOrUnknown(
              data['book_url_pattern']!, _bookUrlPatternMeta));
    }
    if (data.containsKey('book_source_type')) {
      context.handle(
          _bookSourceTypeMeta,
          bookSourceType.isAcceptableOrUnknown(
              data['book_source_type']!, _bookSourceTypeMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('enabled_cookie_jar')) {
      context.handle(
          _enabledCookieJarMeta,
          enabledCookieJar.isAcceptableOrUnknown(
              data['enabled_cookie_jar']!, _enabledCookieJarMeta));
    }
    if (data.containsKey('enabled_explore')) {
      context.handle(
          _enabledExploreMeta,
          enabledExplore.isAcceptableOrUnknown(
              data['enabled_explore']!, _enabledExploreMeta));
    }
    if (data.containsKey('header')) {
      context.handle(_headerMeta,
          header.isAcceptableOrUnknown(data['header']!, _headerMeta));
    }
    if (data.containsKey('login_url')) {
      context.handle(_loginUrlMeta,
          loginUrl.isAcceptableOrUnknown(data['login_url']!, _loginUrlMeta));
    }
    if (data.containsKey('last_update_time')) {
      context.handle(
          _lastUpdateTimeMeta,
          lastUpdateTime.isAcceptableOrUnknown(
              data['last_update_time']!, _lastUpdateTimeMeta));
    }
    if (data.containsKey('explore_url')) {
      context.handle(
          _exploreUrlMeta,
          exploreUrl.isAcceptableOrUnknown(
              data['explore_url']!, _exploreUrlMeta));
    }
    if (data.containsKey('search_url')) {
      context.handle(_searchUrlMeta,
          searchUrl.isAcceptableOrUnknown(data['search_url']!, _searchUrlMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('concurrent_rate')) {
      context.handle(
          _concurrentRateMeta,
          concurrentRate.isAcceptableOrUnknown(
              data['concurrent_rate']!, _concurrentRateMeta));
    }
    if (data.containsKey('respond_time')) {
      context.handle(
          _respondTimeMeta,
          respondTime.isAcceptableOrUnknown(
              data['respond_time']!, _respondTimeMeta));
    }
    if (data.containsKey('login_ui')) {
      context.handle(_loginUiMeta,
          loginUi.isAcceptableOrUnknown(data['login_ui']!, _loginUiMeta));
    }
    if (data.containsKey('login_check_js')) {
      context.handle(
          _loginCheckJsMeta,
          loginCheckJs.isAcceptableOrUnknown(
              data['login_check_js']!, _loginCheckJsMeta));
    }
    if (data.containsKey('cover_decode_js')) {
      context.handle(
          _coverDecodeJsMeta,
          coverDecodeJs.isAcceptableOrUnknown(
              data['cover_decode_js']!, _coverDecodeJsMeta));
    }
    if (data.containsKey('variable_comment')) {
      context.handle(
          _variableCommentMeta,
          variableComment.isAcceptableOrUnknown(
              data['variable_comment']!, _variableCommentMeta));
    }
    if (data.containsKey('explore_screen')) {
      context.handle(
          _exploreScreenMeta,
          exploreScreen.isAcceptableOrUnknown(
              data['explore_screen']!, _exploreScreenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookSource(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}book_source_name'])!,
      bookSourceGroup: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}book_source_group']),
      bookSourceComment: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}book_source_comment']),
      jsLib: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}js_lib']),
      bookSourceUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}book_source_url'])!,
      customOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}custom_order']),
      bookUrlPattern: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}book_url_pattern']),
      bookSourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_type']),
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      enabledCookieJar: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}enabled_cookie_jar']),
      enabledExplore: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled_explore']),
      header: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}header']),
      loginUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}login_url']),
      lastUpdateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_update_time']),
      exploreUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explore_url']),
      searchUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_url']),
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weight']),
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled']),
      concurrentRate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concurrent_rate']),
      respondTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}respond_time']),
      loginUi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}login_ui']),
      loginCheckJs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}login_check_js']),
      coverDecodeJs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_decode_js']),
      variableComment: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}variable_comment']),
      exploreScreen: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explore_screen']),
    );
  }

  @override
  $BookSourcesTable createAlias(String alias) {
    return $BookSourcesTable(attachedDatabase, alias);
  }
}

class BookSource extends DataClass implements Insertable<BookSource> {
  final int id;
  final String bookSourceName;
  final String? bookSourceGroup;
  final String? bookSourceComment;
  final String? jsLib;
  final String bookSourceUrl;
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

  /// 并发速率限制，格式 "N,ms"
  final String? concurrentRate;

  /// 请求超时毫秒数，默认 180000
  final int? respondTime;

  /// 登录表单 UI 配置 JSON
  final String? loginUi;

  /// 每次请求后验证登录态的 JS
  final String? loginCheckJs;

  /// 封面图片解密 JS
  final String? coverDecodeJs;

  /// 书源变量说明
  final String? variableComment;

  /// 发现页筛选/分面配置 JSON
  final String? exploreScreen;
  const BookSource(
      {required this.id,
      required this.bookSourceName,
      this.bookSourceGroup,
      this.bookSourceComment,
      this.jsLib,
      required this.bookSourceUrl,
      this.customOrder,
      this.bookUrlPattern,
      this.bookSourceType,
      required this.enabled,
      this.enabledCookieJar,
      this.enabledExplore,
      this.header,
      this.loginUrl,
      this.lastUpdateTime,
      this.exploreUrl,
      this.searchUrl,
      this.weight,
      this.isEnabled,
      this.concurrentRate,
      this.respondTime,
      this.loginUi,
      this.loginCheckJs,
      this.coverDecodeJs,
      this.variableComment,
      this.exploreScreen});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_name'] = Variable<String>(bookSourceName);
    if (!nullToAbsent || bookSourceGroup != null) {
      map['book_source_group'] = Variable<String>(bookSourceGroup);
    }
    if (!nullToAbsent || bookSourceComment != null) {
      map['book_source_comment'] = Variable<String>(bookSourceComment);
    }
    if (!nullToAbsent || jsLib != null) {
      map['js_lib'] = Variable<String>(jsLib);
    }
    map['book_source_url'] = Variable<String>(bookSourceUrl);
    if (!nullToAbsent || customOrder != null) {
      map['custom_order'] = Variable<int>(customOrder);
    }
    if (!nullToAbsent || bookUrlPattern != null) {
      map['book_url_pattern'] = Variable<String>(bookUrlPattern);
    }
    if (!nullToAbsent || bookSourceType != null) {
      map['book_source_type'] = Variable<int>(bookSourceType);
    }
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || enabledCookieJar != null) {
      map['enabled_cookie_jar'] = Variable<bool>(enabledCookieJar);
    }
    if (!nullToAbsent || enabledExplore != null) {
      map['enabled_explore'] = Variable<bool>(enabledExplore);
    }
    if (!nullToAbsent || header != null) {
      map['header'] = Variable<String>(header);
    }
    if (!nullToAbsent || loginUrl != null) {
      map['login_url'] = Variable<String>(loginUrl);
    }
    if (!nullToAbsent || lastUpdateTime != null) {
      map['last_update_time'] = Variable<String>(lastUpdateTime);
    }
    if (!nullToAbsent || exploreUrl != null) {
      map['explore_url'] = Variable<String>(exploreUrl);
    }
    if (!nullToAbsent || searchUrl != null) {
      map['search_url'] = Variable<String>(searchUrl);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<int>(weight);
    }
    if (!nullToAbsent || isEnabled != null) {
      map['is_enabled'] = Variable<bool>(isEnabled);
    }
    if (!nullToAbsent || concurrentRate != null) {
      map['concurrent_rate'] = Variable<String>(concurrentRate);
    }
    if (!nullToAbsent || respondTime != null) {
      map['respond_time'] = Variable<int>(respondTime);
    }
    if (!nullToAbsent || loginUi != null) {
      map['login_ui'] = Variable<String>(loginUi);
    }
    if (!nullToAbsent || loginCheckJs != null) {
      map['login_check_js'] = Variable<String>(loginCheckJs);
    }
    if (!nullToAbsent || coverDecodeJs != null) {
      map['cover_decode_js'] = Variable<String>(coverDecodeJs);
    }
    if (!nullToAbsent || variableComment != null) {
      map['variable_comment'] = Variable<String>(variableComment);
    }
    if (!nullToAbsent || exploreScreen != null) {
      map['explore_screen'] = Variable<String>(exploreScreen);
    }
    return map;
  }

  BookSourcesCompanion toCompanion(bool nullToAbsent) {
    return BookSourcesCompanion(
      id: Value(id),
      bookSourceName: Value(bookSourceName),
      bookSourceGroup: bookSourceGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(bookSourceGroup),
      bookSourceComment: bookSourceComment == null && nullToAbsent
          ? const Value.absent()
          : Value(bookSourceComment),
      jsLib:
          jsLib == null && nullToAbsent ? const Value.absent() : Value(jsLib),
      bookSourceUrl: Value(bookSourceUrl),
      customOrder: customOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(customOrder),
      bookUrlPattern: bookUrlPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(bookUrlPattern),
      bookSourceType: bookSourceType == null && nullToAbsent
          ? const Value.absent()
          : Value(bookSourceType),
      enabled: Value(enabled),
      enabledCookieJar: enabledCookieJar == null && nullToAbsent
          ? const Value.absent()
          : Value(enabledCookieJar),
      enabledExplore: enabledExplore == null && nullToAbsent
          ? const Value.absent()
          : Value(enabledExplore),
      header:
          header == null && nullToAbsent ? const Value.absent() : Value(header),
      loginUrl: loginUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(loginUrl),
      lastUpdateTime: lastUpdateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdateTime),
      exploreUrl: exploreUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(exploreUrl),
      searchUrl: searchUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(searchUrl),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      isEnabled: isEnabled == null && nullToAbsent
          ? const Value.absent()
          : Value(isEnabled),
      concurrentRate: concurrentRate == null && nullToAbsent
          ? const Value.absent()
          : Value(concurrentRate),
      respondTime: respondTime == null && nullToAbsent
          ? const Value.absent()
          : Value(respondTime),
      loginUi: loginUi == null && nullToAbsent
          ? const Value.absent()
          : Value(loginUi),
      loginCheckJs: loginCheckJs == null && nullToAbsent
          ? const Value.absent()
          : Value(loginCheckJs),
      coverDecodeJs: coverDecodeJs == null && nullToAbsent
          ? const Value.absent()
          : Value(coverDecodeJs),
      variableComment: variableComment == null && nullToAbsent
          ? const Value.absent()
          : Value(variableComment),
      exploreScreen: exploreScreen == null && nullToAbsent
          ? const Value.absent()
          : Value(exploreScreen),
    );
  }

  factory BookSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookSource(
      id: serializer.fromJson<int>(json['id']),
      bookSourceName: serializer.fromJson<String>(json['bookSourceName']),
      bookSourceGroup: serializer.fromJson<String?>(json['bookSourceGroup']),
      bookSourceComment:
          serializer.fromJson<String?>(json['bookSourceComment']),
      jsLib: serializer.fromJson<String?>(json['jsLib']),
      bookSourceUrl: serializer.fromJson<String>(json['bookSourceUrl']),
      customOrder: serializer.fromJson<int?>(json['customOrder']),
      bookUrlPattern: serializer.fromJson<String?>(json['bookUrlPattern']),
      bookSourceType: serializer.fromJson<int?>(json['bookSourceType']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      enabledCookieJar: serializer.fromJson<bool?>(json['enabledCookieJar']),
      enabledExplore: serializer.fromJson<bool?>(json['enabledExplore']),
      header: serializer.fromJson<String?>(json['header']),
      loginUrl: serializer.fromJson<String?>(json['loginUrl']),
      lastUpdateTime: serializer.fromJson<String?>(json['lastUpdateTime']),
      exploreUrl: serializer.fromJson<String?>(json['exploreUrl']),
      searchUrl: serializer.fromJson<String?>(json['searchUrl']),
      weight: serializer.fromJson<int?>(json['weight']),
      isEnabled: serializer.fromJson<bool?>(json['isEnabled']),
      concurrentRate: serializer.fromJson<String?>(json['concurrentRate']),
      respondTime: serializer.fromJson<int?>(json['respondTime']),
      loginUi: serializer.fromJson<String?>(json['loginUi']),
      loginCheckJs: serializer.fromJson<String?>(json['loginCheckJs']),
      coverDecodeJs: serializer.fromJson<String?>(json['coverDecodeJs']),
      variableComment: serializer.fromJson<String?>(json['variableComment']),
      exploreScreen: serializer.fromJson<String?>(json['exploreScreen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceName': serializer.toJson<String>(bookSourceName),
      'bookSourceGroup': serializer.toJson<String?>(bookSourceGroup),
      'bookSourceComment': serializer.toJson<String?>(bookSourceComment),
      'jsLib': serializer.toJson<String?>(jsLib),
      'bookSourceUrl': serializer.toJson<String>(bookSourceUrl),
      'customOrder': serializer.toJson<int?>(customOrder),
      'bookUrlPattern': serializer.toJson<String?>(bookUrlPattern),
      'bookSourceType': serializer.toJson<int?>(bookSourceType),
      'enabled': serializer.toJson<bool>(enabled),
      'enabledCookieJar': serializer.toJson<bool?>(enabledCookieJar),
      'enabledExplore': serializer.toJson<bool?>(enabledExplore),
      'header': serializer.toJson<String?>(header),
      'loginUrl': serializer.toJson<String?>(loginUrl),
      'lastUpdateTime': serializer.toJson<String?>(lastUpdateTime),
      'exploreUrl': serializer.toJson<String?>(exploreUrl),
      'searchUrl': serializer.toJson<String?>(searchUrl),
      'weight': serializer.toJson<int?>(weight),
      'isEnabled': serializer.toJson<bool?>(isEnabled),
      'concurrentRate': serializer.toJson<String?>(concurrentRate),
      'respondTime': serializer.toJson<int?>(respondTime),
      'loginUi': serializer.toJson<String?>(loginUi),
      'loginCheckJs': serializer.toJson<String?>(loginCheckJs),
      'coverDecodeJs': serializer.toJson<String?>(coverDecodeJs),
      'variableComment': serializer.toJson<String?>(variableComment),
      'exploreScreen': serializer.toJson<String?>(exploreScreen),
    };
  }

  BookSource copyWith(
          {int? id,
          String? bookSourceName,
          Value<String?> bookSourceGroup = const Value.absent(),
          Value<String?> bookSourceComment = const Value.absent(),
          Value<String?> jsLib = const Value.absent(),
          String? bookSourceUrl,
          Value<int?> customOrder = const Value.absent(),
          Value<String?> bookUrlPattern = const Value.absent(),
          Value<int?> bookSourceType = const Value.absent(),
          bool? enabled,
          Value<bool?> enabledCookieJar = const Value.absent(),
          Value<bool?> enabledExplore = const Value.absent(),
          Value<String?> header = const Value.absent(),
          Value<String?> loginUrl = const Value.absent(),
          Value<String?> lastUpdateTime = const Value.absent(),
          Value<String?> exploreUrl = const Value.absent(),
          Value<String?> searchUrl = const Value.absent(),
          Value<int?> weight = const Value.absent(),
          Value<bool?> isEnabled = const Value.absent(),
          Value<String?> concurrentRate = const Value.absent(),
          Value<int?> respondTime = const Value.absent(),
          Value<String?> loginUi = const Value.absent(),
          Value<String?> loginCheckJs = const Value.absent(),
          Value<String?> coverDecodeJs = const Value.absent(),
          Value<String?> variableComment = const Value.absent(),
          Value<String?> exploreScreen = const Value.absent()}) =>
      BookSource(
        id: id ?? this.id,
        bookSourceName: bookSourceName ?? this.bookSourceName,
        bookSourceGroup: bookSourceGroup.present
            ? bookSourceGroup.value
            : this.bookSourceGroup,
        bookSourceComment: bookSourceComment.present
            ? bookSourceComment.value
            : this.bookSourceComment,
        jsLib: jsLib.present ? jsLib.value : this.jsLib,
        bookSourceUrl: bookSourceUrl ?? this.bookSourceUrl,
        customOrder: customOrder.present ? customOrder.value : this.customOrder,
        bookUrlPattern:
            bookUrlPattern.present ? bookUrlPattern.value : this.bookUrlPattern,
        bookSourceType:
            bookSourceType.present ? bookSourceType.value : this.bookSourceType,
        enabled: enabled ?? this.enabled,
        enabledCookieJar: enabledCookieJar.present
            ? enabledCookieJar.value
            : this.enabledCookieJar,
        enabledExplore:
            enabledExplore.present ? enabledExplore.value : this.enabledExplore,
        header: header.present ? header.value : this.header,
        loginUrl: loginUrl.present ? loginUrl.value : this.loginUrl,
        lastUpdateTime:
            lastUpdateTime.present ? lastUpdateTime.value : this.lastUpdateTime,
        exploreUrl: exploreUrl.present ? exploreUrl.value : this.exploreUrl,
        searchUrl: searchUrl.present ? searchUrl.value : this.searchUrl,
        weight: weight.present ? weight.value : this.weight,
        isEnabled: isEnabled.present ? isEnabled.value : this.isEnabled,
        concurrentRate:
            concurrentRate.present ? concurrentRate.value : this.concurrentRate,
        respondTime: respondTime.present ? respondTime.value : this.respondTime,
        loginUi: loginUi.present ? loginUi.value : this.loginUi,
        loginCheckJs:
            loginCheckJs.present ? loginCheckJs.value : this.loginCheckJs,
        coverDecodeJs:
            coverDecodeJs.present ? coverDecodeJs.value : this.coverDecodeJs,
        variableComment: variableComment.present
            ? variableComment.value
            : this.variableComment,
        exploreScreen:
            exploreScreen.present ? exploreScreen.value : this.exploreScreen,
      );
  BookSource copyWithCompanion(BookSourcesCompanion data) {
    return BookSource(
      id: data.id.present ? data.id.value : this.id,
      bookSourceName: data.bookSourceName.present
          ? data.bookSourceName.value
          : this.bookSourceName,
      bookSourceGroup: data.bookSourceGroup.present
          ? data.bookSourceGroup.value
          : this.bookSourceGroup,
      bookSourceComment: data.bookSourceComment.present
          ? data.bookSourceComment.value
          : this.bookSourceComment,
      jsLib: data.jsLib.present ? data.jsLib.value : this.jsLib,
      bookSourceUrl: data.bookSourceUrl.present
          ? data.bookSourceUrl.value
          : this.bookSourceUrl,
      customOrder:
          data.customOrder.present ? data.customOrder.value : this.customOrder,
      bookUrlPattern: data.bookUrlPattern.present
          ? data.bookUrlPattern.value
          : this.bookUrlPattern,
      bookSourceType: data.bookSourceType.present
          ? data.bookSourceType.value
          : this.bookSourceType,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      enabledCookieJar: data.enabledCookieJar.present
          ? data.enabledCookieJar.value
          : this.enabledCookieJar,
      enabledExplore: data.enabledExplore.present
          ? data.enabledExplore.value
          : this.enabledExplore,
      header: data.header.present ? data.header.value : this.header,
      loginUrl: data.loginUrl.present ? data.loginUrl.value : this.loginUrl,
      lastUpdateTime: data.lastUpdateTime.present
          ? data.lastUpdateTime.value
          : this.lastUpdateTime,
      exploreUrl:
          data.exploreUrl.present ? data.exploreUrl.value : this.exploreUrl,
      searchUrl: data.searchUrl.present ? data.searchUrl.value : this.searchUrl,
      weight: data.weight.present ? data.weight.value : this.weight,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      concurrentRate: data.concurrentRate.present
          ? data.concurrentRate.value
          : this.concurrentRate,
      respondTime:
          data.respondTime.present ? data.respondTime.value : this.respondTime,
      loginUi: data.loginUi.present ? data.loginUi.value : this.loginUi,
      loginCheckJs: data.loginCheckJs.present
          ? data.loginCheckJs.value
          : this.loginCheckJs,
      coverDecodeJs: data.coverDecodeJs.present
          ? data.coverDecodeJs.value
          : this.coverDecodeJs,
      variableComment: data.variableComment.present
          ? data.variableComment.value
          : this.variableComment,
      exploreScreen: data.exploreScreen.present
          ? data.exploreScreen.value
          : this.exploreScreen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookSource(')
          ..write('id: $id, ')
          ..write('bookSourceName: $bookSourceName, ')
          ..write('bookSourceGroup: $bookSourceGroup, ')
          ..write('bookSourceComment: $bookSourceComment, ')
          ..write('jsLib: $jsLib, ')
          ..write('bookSourceUrl: $bookSourceUrl, ')
          ..write('customOrder: $customOrder, ')
          ..write('bookUrlPattern: $bookUrlPattern, ')
          ..write('bookSourceType: $bookSourceType, ')
          ..write('enabled: $enabled, ')
          ..write('enabledCookieJar: $enabledCookieJar, ')
          ..write('enabledExplore: $enabledExplore, ')
          ..write('header: $header, ')
          ..write('loginUrl: $loginUrl, ')
          ..write('lastUpdateTime: $lastUpdateTime, ')
          ..write('exploreUrl: $exploreUrl, ')
          ..write('searchUrl: $searchUrl, ')
          ..write('weight: $weight, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('concurrentRate: $concurrentRate, ')
          ..write('respondTime: $respondTime, ')
          ..write('loginUi: $loginUi, ')
          ..write('loginCheckJs: $loginCheckJs, ')
          ..write('coverDecodeJs: $coverDecodeJs, ')
          ..write('variableComment: $variableComment, ')
          ..write('exploreScreen: $exploreScreen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        bookSourceName,
        bookSourceGroup,
        bookSourceComment,
        jsLib,
        bookSourceUrl,
        customOrder,
        bookUrlPattern,
        bookSourceType,
        enabled,
        enabledCookieJar,
        enabledExplore,
        header,
        loginUrl,
        lastUpdateTime,
        exploreUrl,
        searchUrl,
        weight,
        isEnabled,
        concurrentRate,
        respondTime,
        loginUi,
        loginCheckJs,
        coverDecodeJs,
        variableComment,
        exploreScreen
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookSource &&
          other.id == this.id &&
          other.bookSourceName == this.bookSourceName &&
          other.bookSourceGroup == this.bookSourceGroup &&
          other.bookSourceComment == this.bookSourceComment &&
          other.jsLib == this.jsLib &&
          other.bookSourceUrl == this.bookSourceUrl &&
          other.customOrder == this.customOrder &&
          other.bookUrlPattern == this.bookUrlPattern &&
          other.bookSourceType == this.bookSourceType &&
          other.enabled == this.enabled &&
          other.enabledCookieJar == this.enabledCookieJar &&
          other.enabledExplore == this.enabledExplore &&
          other.header == this.header &&
          other.loginUrl == this.loginUrl &&
          other.lastUpdateTime == this.lastUpdateTime &&
          other.exploreUrl == this.exploreUrl &&
          other.searchUrl == this.searchUrl &&
          other.weight == this.weight &&
          other.isEnabled == this.isEnabled &&
          other.concurrentRate == this.concurrentRate &&
          other.respondTime == this.respondTime &&
          other.loginUi == this.loginUi &&
          other.loginCheckJs == this.loginCheckJs &&
          other.coverDecodeJs == this.coverDecodeJs &&
          other.variableComment == this.variableComment &&
          other.exploreScreen == this.exploreScreen);
}

class BookSourcesCompanion extends UpdateCompanion<BookSource> {
  final Value<int> id;
  final Value<String> bookSourceName;
  final Value<String?> bookSourceGroup;
  final Value<String?> bookSourceComment;
  final Value<String?> jsLib;
  final Value<String> bookSourceUrl;
  final Value<int?> customOrder;
  final Value<String?> bookUrlPattern;
  final Value<int?> bookSourceType;
  final Value<bool> enabled;
  final Value<bool?> enabledCookieJar;
  final Value<bool?> enabledExplore;
  final Value<String?> header;
  final Value<String?> loginUrl;
  final Value<String?> lastUpdateTime;
  final Value<String?> exploreUrl;
  final Value<String?> searchUrl;
  final Value<int?> weight;
  final Value<bool?> isEnabled;
  final Value<String?> concurrentRate;
  final Value<int?> respondTime;
  final Value<String?> loginUi;
  final Value<String?> loginCheckJs;
  final Value<String?> coverDecodeJs;
  final Value<String?> variableComment;
  final Value<String?> exploreScreen;
  const BookSourcesCompanion({
    this.id = const Value.absent(),
    this.bookSourceName = const Value.absent(),
    this.bookSourceGroup = const Value.absent(),
    this.bookSourceComment = const Value.absent(),
    this.jsLib = const Value.absent(),
    this.bookSourceUrl = const Value.absent(),
    this.customOrder = const Value.absent(),
    this.bookUrlPattern = const Value.absent(),
    this.bookSourceType = const Value.absent(),
    this.enabled = const Value.absent(),
    this.enabledCookieJar = const Value.absent(),
    this.enabledExplore = const Value.absent(),
    this.header = const Value.absent(),
    this.loginUrl = const Value.absent(),
    this.lastUpdateTime = const Value.absent(),
    this.exploreUrl = const Value.absent(),
    this.searchUrl = const Value.absent(),
    this.weight = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.concurrentRate = const Value.absent(),
    this.respondTime = const Value.absent(),
    this.loginUi = const Value.absent(),
    this.loginCheckJs = const Value.absent(),
    this.coverDecodeJs = const Value.absent(),
    this.variableComment = const Value.absent(),
    this.exploreScreen = const Value.absent(),
  });
  BookSourcesCompanion.insert({
    this.id = const Value.absent(),
    required String bookSourceName,
    this.bookSourceGroup = const Value.absent(),
    this.bookSourceComment = const Value.absent(),
    this.jsLib = const Value.absent(),
    required String bookSourceUrl,
    this.customOrder = const Value.absent(),
    this.bookUrlPattern = const Value.absent(),
    this.bookSourceType = const Value.absent(),
    this.enabled = const Value.absent(),
    this.enabledCookieJar = const Value.absent(),
    this.enabledExplore = const Value.absent(),
    this.header = const Value.absent(),
    this.loginUrl = const Value.absent(),
    this.lastUpdateTime = const Value.absent(),
    this.exploreUrl = const Value.absent(),
    this.searchUrl = const Value.absent(),
    this.weight = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.concurrentRate = const Value.absent(),
    this.respondTime = const Value.absent(),
    this.loginUi = const Value.absent(),
    this.loginCheckJs = const Value.absent(),
    this.coverDecodeJs = const Value.absent(),
    this.variableComment = const Value.absent(),
    this.exploreScreen = const Value.absent(),
  })  : bookSourceName = Value(bookSourceName),
        bookSourceUrl = Value(bookSourceUrl);
  static Insertable<BookSource> custom({
    Expression<int>? id,
    Expression<String>? bookSourceName,
    Expression<String>? bookSourceGroup,
    Expression<String>? bookSourceComment,
    Expression<String>? jsLib,
    Expression<String>? bookSourceUrl,
    Expression<int>? customOrder,
    Expression<String>? bookUrlPattern,
    Expression<int>? bookSourceType,
    Expression<bool>? enabled,
    Expression<bool>? enabledCookieJar,
    Expression<bool>? enabledExplore,
    Expression<String>? header,
    Expression<String>? loginUrl,
    Expression<String>? lastUpdateTime,
    Expression<String>? exploreUrl,
    Expression<String>? searchUrl,
    Expression<int>? weight,
    Expression<bool>? isEnabled,
    Expression<String>? concurrentRate,
    Expression<int>? respondTime,
    Expression<String>? loginUi,
    Expression<String>? loginCheckJs,
    Expression<String>? coverDecodeJs,
    Expression<String>? variableComment,
    Expression<String>? exploreScreen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceName != null) 'book_source_name': bookSourceName,
      if (bookSourceGroup != null) 'book_source_group': bookSourceGroup,
      if (bookSourceComment != null) 'book_source_comment': bookSourceComment,
      if (jsLib != null) 'js_lib': jsLib,
      if (bookSourceUrl != null) 'book_source_url': bookSourceUrl,
      if (customOrder != null) 'custom_order': customOrder,
      if (bookUrlPattern != null) 'book_url_pattern': bookUrlPattern,
      if (bookSourceType != null) 'book_source_type': bookSourceType,
      if (enabled != null) 'enabled': enabled,
      if (enabledCookieJar != null) 'enabled_cookie_jar': enabledCookieJar,
      if (enabledExplore != null) 'enabled_explore': enabledExplore,
      if (header != null) 'header': header,
      if (loginUrl != null) 'login_url': loginUrl,
      if (lastUpdateTime != null) 'last_update_time': lastUpdateTime,
      if (exploreUrl != null) 'explore_url': exploreUrl,
      if (searchUrl != null) 'search_url': searchUrl,
      if (weight != null) 'weight': weight,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (concurrentRate != null) 'concurrent_rate': concurrentRate,
      if (respondTime != null) 'respond_time': respondTime,
      if (loginUi != null) 'login_ui': loginUi,
      if (loginCheckJs != null) 'login_check_js': loginCheckJs,
      if (coverDecodeJs != null) 'cover_decode_js': coverDecodeJs,
      if (variableComment != null) 'variable_comment': variableComment,
      if (exploreScreen != null) 'explore_screen': exploreScreen,
    });
  }

  BookSourcesCompanion copyWith(
      {Value<int>? id,
      Value<String>? bookSourceName,
      Value<String?>? bookSourceGroup,
      Value<String?>? bookSourceComment,
      Value<String?>? jsLib,
      Value<String>? bookSourceUrl,
      Value<int?>? customOrder,
      Value<String?>? bookUrlPattern,
      Value<int?>? bookSourceType,
      Value<bool>? enabled,
      Value<bool?>? enabledCookieJar,
      Value<bool?>? enabledExplore,
      Value<String?>? header,
      Value<String?>? loginUrl,
      Value<String?>? lastUpdateTime,
      Value<String?>? exploreUrl,
      Value<String?>? searchUrl,
      Value<int?>? weight,
      Value<bool?>? isEnabled,
      Value<String?>? concurrentRate,
      Value<int?>? respondTime,
      Value<String?>? loginUi,
      Value<String?>? loginCheckJs,
      Value<String?>? coverDecodeJs,
      Value<String?>? variableComment,
      Value<String?>? exploreScreen}) {
    return BookSourcesCompanion(
      id: id ?? this.id,
      bookSourceName: bookSourceName ?? this.bookSourceName,
      bookSourceGroup: bookSourceGroup ?? this.bookSourceGroup,
      bookSourceComment: bookSourceComment ?? this.bookSourceComment,
      jsLib: jsLib ?? this.jsLib,
      bookSourceUrl: bookSourceUrl ?? this.bookSourceUrl,
      customOrder: customOrder ?? this.customOrder,
      bookUrlPattern: bookUrlPattern ?? this.bookUrlPattern,
      bookSourceType: bookSourceType ?? this.bookSourceType,
      enabled: enabled ?? this.enabled,
      enabledCookieJar: enabledCookieJar ?? this.enabledCookieJar,
      enabledExplore: enabledExplore ?? this.enabledExplore,
      header: header ?? this.header,
      loginUrl: loginUrl ?? this.loginUrl,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      exploreUrl: exploreUrl ?? this.exploreUrl,
      searchUrl: searchUrl ?? this.searchUrl,
      weight: weight ?? this.weight,
      isEnabled: isEnabled ?? this.isEnabled,
      concurrentRate: concurrentRate ?? this.concurrentRate,
      respondTime: respondTime ?? this.respondTime,
      loginUi: loginUi ?? this.loginUi,
      loginCheckJs: loginCheckJs ?? this.loginCheckJs,
      coverDecodeJs: coverDecodeJs ?? this.coverDecodeJs,
      variableComment: variableComment ?? this.variableComment,
      exploreScreen: exploreScreen ?? this.exploreScreen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceName.present) {
      map['book_source_name'] = Variable<String>(bookSourceName.value);
    }
    if (bookSourceGroup.present) {
      map['book_source_group'] = Variable<String>(bookSourceGroup.value);
    }
    if (bookSourceComment.present) {
      map['book_source_comment'] = Variable<String>(bookSourceComment.value);
    }
    if (jsLib.present) {
      map['js_lib'] = Variable<String>(jsLib.value);
    }
    if (bookSourceUrl.present) {
      map['book_source_url'] = Variable<String>(bookSourceUrl.value);
    }
    if (customOrder.present) {
      map['custom_order'] = Variable<int>(customOrder.value);
    }
    if (bookUrlPattern.present) {
      map['book_url_pattern'] = Variable<String>(bookUrlPattern.value);
    }
    if (bookSourceType.present) {
      map['book_source_type'] = Variable<int>(bookSourceType.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (enabledCookieJar.present) {
      map['enabled_cookie_jar'] = Variable<bool>(enabledCookieJar.value);
    }
    if (enabledExplore.present) {
      map['enabled_explore'] = Variable<bool>(enabledExplore.value);
    }
    if (header.present) {
      map['header'] = Variable<String>(header.value);
    }
    if (loginUrl.present) {
      map['login_url'] = Variable<String>(loginUrl.value);
    }
    if (lastUpdateTime.present) {
      map['last_update_time'] = Variable<String>(lastUpdateTime.value);
    }
    if (exploreUrl.present) {
      map['explore_url'] = Variable<String>(exploreUrl.value);
    }
    if (searchUrl.present) {
      map['search_url'] = Variable<String>(searchUrl.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (concurrentRate.present) {
      map['concurrent_rate'] = Variable<String>(concurrentRate.value);
    }
    if (respondTime.present) {
      map['respond_time'] = Variable<int>(respondTime.value);
    }
    if (loginUi.present) {
      map['login_ui'] = Variable<String>(loginUi.value);
    }
    if (loginCheckJs.present) {
      map['login_check_js'] = Variable<String>(loginCheckJs.value);
    }
    if (coverDecodeJs.present) {
      map['cover_decode_js'] = Variable<String>(coverDecodeJs.value);
    }
    if (variableComment.present) {
      map['variable_comment'] = Variable<String>(variableComment.value);
    }
    if (exploreScreen.present) {
      map['explore_screen'] = Variable<String>(exploreScreen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookSourcesCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceName: $bookSourceName, ')
          ..write('bookSourceGroup: $bookSourceGroup, ')
          ..write('bookSourceComment: $bookSourceComment, ')
          ..write('jsLib: $jsLib, ')
          ..write('bookSourceUrl: $bookSourceUrl, ')
          ..write('customOrder: $customOrder, ')
          ..write('bookUrlPattern: $bookUrlPattern, ')
          ..write('bookSourceType: $bookSourceType, ')
          ..write('enabled: $enabled, ')
          ..write('enabledCookieJar: $enabledCookieJar, ')
          ..write('enabledExplore: $enabledExplore, ')
          ..write('header: $header, ')
          ..write('loginUrl: $loginUrl, ')
          ..write('lastUpdateTime: $lastUpdateTime, ')
          ..write('exploreUrl: $exploreUrl, ')
          ..write('searchUrl: $searchUrl, ')
          ..write('weight: $weight, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('concurrentRate: $concurrentRate, ')
          ..write('respondTime: $respondTime, ')
          ..write('loginUi: $loginUi, ')
          ..write('loginCheckJs: $loginCheckJs, ')
          ..write('coverDecodeJs: $coverDecodeJs, ')
          ..write('variableComment: $variableComment, ')
          ..write('exploreScreen: $exploreScreen')
          ..write(')'))
        .toString();
  }
}

class $RuleBookInfosTable extends RuleBookInfos
    with TableInfo<$RuleBookInfosTable, RuleBookInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RuleBookInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _initMeta = const VerificationMeta('init');
  @override
  late final GeneratedColumn<String> init = GeneratedColumn<String>(
      'init', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _introMeta = const VerificationMeta('intro');
  @override
  late final GeneratedColumn<String> intro = GeneratedColumn<String>(
      'intro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastChapterMeta =
      const VerificationMeta('lastChapter');
  @override
  late final GeneratedColumn<String> lastChapter = GeneratedColumn<String>(
      'last_chapter', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tocUrlMeta = const VerificationMeta('tocUrl');
  @override
  late final GeneratedColumn<String> tocUrl = GeneratedColumn<String>(
      'toc_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wordCountMeta =
      const VerificationMeta('wordCount');
  @override
  late final GeneratedColumn<String> wordCount = GeneratedColumn<String>(
      'word_count', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastReadChapterMeta =
      const VerificationMeta('lastReadChapter');
  @override
  late final GeneratedColumn<String> lastReadChapter = GeneratedColumn<String>(
      'last_read_chapter', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _canReNameMeta =
      const VerificationMeta('canReName');
  @override
  late final GeneratedColumn<String> canReName = GeneratedColumn<String>(
      'can_re_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _downloadUrlsMeta =
      const VerificationMeta('downloadUrls');
  @override
  late final GeneratedColumn<String> downloadUrls = GeneratedColumn<String>(
      'download_urls', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updateTimeMeta =
      const VerificationMeta('updateTime');
  @override
  late final GeneratedColumn<String> updateTime = GeneratedColumn<String>(
      'update_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        author,
        coverUrl,
        init,
        intro,
        kind,
        lastChapter,
        name,
        tocUrl,
        wordCount,
        lastReadChapter,
        canReName,
        downloadUrls,
        updateTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule_book_infos';
  @override
  VerificationContext validateIntegrity(Insertable<RuleBookInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    }
    if (data.containsKey('init')) {
      context.handle(
          _initMeta, init.isAcceptableOrUnknown(data['init']!, _initMeta));
    }
    if (data.containsKey('intro')) {
      context.handle(
          _introMeta, intro.isAcceptableOrUnknown(data['intro']!, _introMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('last_chapter')) {
      context.handle(
          _lastChapterMeta,
          lastChapter.isAcceptableOrUnknown(
              data['last_chapter']!, _lastChapterMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('toc_url')) {
      context.handle(_tocUrlMeta,
          tocUrl.isAcceptableOrUnknown(data['toc_url']!, _tocUrlMeta));
    }
    if (data.containsKey('word_count')) {
      context.handle(_wordCountMeta,
          wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta));
    }
    if (data.containsKey('last_read_chapter')) {
      context.handle(
          _lastReadChapterMeta,
          lastReadChapter.isAcceptableOrUnknown(
              data['last_read_chapter']!, _lastReadChapterMeta));
    }
    if (data.containsKey('can_re_name')) {
      context.handle(
          _canReNameMeta,
          canReName.isAcceptableOrUnknown(
              data['can_re_name']!, _canReNameMeta));
    }
    if (data.containsKey('download_urls')) {
      context.handle(
          _downloadUrlsMeta,
          downloadUrls.isAcceptableOrUnknown(
              data['download_urls']!, _downloadUrlsMeta));
    }
    if (data.containsKey('update_time')) {
      context.handle(
          _updateTimeMeta,
          updateTime.isAcceptableOrUnknown(
              data['update_time']!, _updateTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleBookInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleBookInfo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url']),
      init: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}init']),
      intro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intro']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind']),
      lastChapter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_chapter']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      tocUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}toc_url']),
      wordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word_count']),
      lastReadChapter: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_read_chapter']),
      canReName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}can_re_name']),
      downloadUrls: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}download_urls']),
      updateTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}update_time']),
    );
  }

  @override
  $RuleBookInfosTable createAlias(String alias) {
    return $RuleBookInfosTable(attachedDatabase, alias);
  }
}

class RuleBookInfo extends DataClass implements Insertable<RuleBookInfo> {
  final int id;
  final int bookSourceId;
  final String? author;
  final String? coverUrl;
  final String? init;
  final String? intro;
  final String? kind;
  final String? lastChapter;
  final String? name;
  final String? tocUrl;
  final String? wordCount;
  final String? lastReadChapter;

  /// 是否允许用户重命名书名
  final String? canReName;

  /// 文件型书源下载链接规则
  final String? downloadUrls;

  /// 更新时间规则
  final String? updateTime;
  const RuleBookInfo(
      {required this.id,
      required this.bookSourceId,
      this.author,
      this.coverUrl,
      this.init,
      this.intro,
      this.kind,
      this.lastChapter,
      this.name,
      this.tocUrl,
      this.wordCount,
      this.lastReadChapter,
      this.canReName,
      this.downloadUrls,
      this.updateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || init != null) {
      map['init'] = Variable<String>(init);
    }
    if (!nullToAbsent || intro != null) {
      map['intro'] = Variable<String>(intro);
    }
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(kind);
    }
    if (!nullToAbsent || lastChapter != null) {
      map['last_chapter'] = Variable<String>(lastChapter);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || tocUrl != null) {
      map['toc_url'] = Variable<String>(tocUrl);
    }
    if (!nullToAbsent || wordCount != null) {
      map['word_count'] = Variable<String>(wordCount);
    }
    if (!nullToAbsent || lastReadChapter != null) {
      map['last_read_chapter'] = Variable<String>(lastReadChapter);
    }
    if (!nullToAbsent || canReName != null) {
      map['can_re_name'] = Variable<String>(canReName);
    }
    if (!nullToAbsent || downloadUrls != null) {
      map['download_urls'] = Variable<String>(downloadUrls);
    }
    if (!nullToAbsent || updateTime != null) {
      map['update_time'] = Variable<String>(updateTime);
    }
    return map;
  }

  RuleBookInfosCompanion toCompanion(bool nullToAbsent) {
    return RuleBookInfosCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      init: init == null && nullToAbsent ? const Value.absent() : Value(init),
      intro:
          intro == null && nullToAbsent ? const Value.absent() : Value(intro),
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
      lastChapter: lastChapter == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChapter),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      tocUrl:
          tocUrl == null && nullToAbsent ? const Value.absent() : Value(tocUrl),
      wordCount: wordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordCount),
      lastReadChapter: lastReadChapter == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadChapter),
      canReName: canReName == null && nullToAbsent
          ? const Value.absent()
          : Value(canReName),
      downloadUrls: downloadUrls == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadUrls),
      updateTime: updateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(updateTime),
    );
  }

  factory RuleBookInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleBookInfo(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      author: serializer.fromJson<String?>(json['author']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      init: serializer.fromJson<String?>(json['init']),
      intro: serializer.fromJson<String?>(json['intro']),
      kind: serializer.fromJson<String?>(json['kind']),
      lastChapter: serializer.fromJson<String?>(json['lastChapter']),
      name: serializer.fromJson<String?>(json['name']),
      tocUrl: serializer.fromJson<String?>(json['tocUrl']),
      wordCount: serializer.fromJson<String?>(json['wordCount']),
      lastReadChapter: serializer.fromJson<String?>(json['lastReadChapter']),
      canReName: serializer.fromJson<String?>(json['canReName']),
      downloadUrls: serializer.fromJson<String?>(json['downloadUrls']),
      updateTime: serializer.fromJson<String?>(json['updateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'author': serializer.toJson<String?>(author),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'init': serializer.toJson<String?>(init),
      'intro': serializer.toJson<String?>(intro),
      'kind': serializer.toJson<String?>(kind),
      'lastChapter': serializer.toJson<String?>(lastChapter),
      'name': serializer.toJson<String?>(name),
      'tocUrl': serializer.toJson<String?>(tocUrl),
      'wordCount': serializer.toJson<String?>(wordCount),
      'lastReadChapter': serializer.toJson<String?>(lastReadChapter),
      'canReName': serializer.toJson<String?>(canReName),
      'downloadUrls': serializer.toJson<String?>(downloadUrls),
      'updateTime': serializer.toJson<String?>(updateTime),
    };
  }

  RuleBookInfo copyWith(
          {int? id,
          int? bookSourceId,
          Value<String?> author = const Value.absent(),
          Value<String?> coverUrl = const Value.absent(),
          Value<String?> init = const Value.absent(),
          Value<String?> intro = const Value.absent(),
          Value<String?> kind = const Value.absent(),
          Value<String?> lastChapter = const Value.absent(),
          Value<String?> name = const Value.absent(),
          Value<String?> tocUrl = const Value.absent(),
          Value<String?> wordCount = const Value.absent(),
          Value<String?> lastReadChapter = const Value.absent(),
          Value<String?> canReName = const Value.absent(),
          Value<String?> downloadUrls = const Value.absent(),
          Value<String?> updateTime = const Value.absent()}) =>
      RuleBookInfo(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        author: author.present ? author.value : this.author,
        coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
        init: init.present ? init.value : this.init,
        intro: intro.present ? intro.value : this.intro,
        kind: kind.present ? kind.value : this.kind,
        lastChapter: lastChapter.present ? lastChapter.value : this.lastChapter,
        name: name.present ? name.value : this.name,
        tocUrl: tocUrl.present ? tocUrl.value : this.tocUrl,
        wordCount: wordCount.present ? wordCount.value : this.wordCount,
        lastReadChapter: lastReadChapter.present
            ? lastReadChapter.value
            : this.lastReadChapter,
        canReName: canReName.present ? canReName.value : this.canReName,
        downloadUrls:
            downloadUrls.present ? downloadUrls.value : this.downloadUrls,
        updateTime: updateTime.present ? updateTime.value : this.updateTime,
      );
  RuleBookInfo copyWithCompanion(RuleBookInfosCompanion data) {
    return RuleBookInfo(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      author: data.author.present ? data.author.value : this.author,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      init: data.init.present ? data.init.value : this.init,
      intro: data.intro.present ? data.intro.value : this.intro,
      kind: data.kind.present ? data.kind.value : this.kind,
      lastChapter:
          data.lastChapter.present ? data.lastChapter.value : this.lastChapter,
      name: data.name.present ? data.name.value : this.name,
      tocUrl: data.tocUrl.present ? data.tocUrl.value : this.tocUrl,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      lastReadChapter: data.lastReadChapter.present
          ? data.lastReadChapter.value
          : this.lastReadChapter,
      canReName: data.canReName.present ? data.canReName.value : this.canReName,
      downloadUrls: data.downloadUrls.present
          ? data.downloadUrls.value
          : this.downloadUrls,
      updateTime:
          data.updateTime.present ? data.updateTime.value : this.updateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleBookInfo(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('author: $author, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('init: $init, ')
          ..write('intro: $intro, ')
          ..write('kind: $kind, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('name: $name, ')
          ..write('tocUrl: $tocUrl, ')
          ..write('wordCount: $wordCount, ')
          ..write('lastReadChapter: $lastReadChapter, ')
          ..write('canReName: $canReName, ')
          ..write('downloadUrls: $downloadUrls, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookSourceId,
      author,
      coverUrl,
      init,
      intro,
      kind,
      lastChapter,
      name,
      tocUrl,
      wordCount,
      lastReadChapter,
      canReName,
      downloadUrls,
      updateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleBookInfo &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.author == this.author &&
          other.coverUrl == this.coverUrl &&
          other.init == this.init &&
          other.intro == this.intro &&
          other.kind == this.kind &&
          other.lastChapter == this.lastChapter &&
          other.name == this.name &&
          other.tocUrl == this.tocUrl &&
          other.wordCount == this.wordCount &&
          other.lastReadChapter == this.lastReadChapter &&
          other.canReName == this.canReName &&
          other.downloadUrls == this.downloadUrls &&
          other.updateTime == this.updateTime);
}

class RuleBookInfosCompanion extends UpdateCompanion<RuleBookInfo> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String?> author;
  final Value<String?> coverUrl;
  final Value<String?> init;
  final Value<String?> intro;
  final Value<String?> kind;
  final Value<String?> lastChapter;
  final Value<String?> name;
  final Value<String?> tocUrl;
  final Value<String?> wordCount;
  final Value<String?> lastReadChapter;
  final Value<String?> canReName;
  final Value<String?> downloadUrls;
  final Value<String?> updateTime;
  const RuleBookInfosCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.author = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.init = const Value.absent(),
    this.intro = const Value.absent(),
    this.kind = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.name = const Value.absent(),
    this.tocUrl = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.lastReadChapter = const Value.absent(),
    this.canReName = const Value.absent(),
    this.downloadUrls = const Value.absent(),
    this.updateTime = const Value.absent(),
  });
  RuleBookInfosCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    this.author = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.init = const Value.absent(),
    this.intro = const Value.absent(),
    this.kind = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.name = const Value.absent(),
    this.tocUrl = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.lastReadChapter = const Value.absent(),
    this.canReName = const Value.absent(),
    this.downloadUrls = const Value.absent(),
    this.updateTime = const Value.absent(),
  }) : bookSourceId = Value(bookSourceId);
  static Insertable<RuleBookInfo> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? author,
    Expression<String>? coverUrl,
    Expression<String>? init,
    Expression<String>? intro,
    Expression<String>? kind,
    Expression<String>? lastChapter,
    Expression<String>? name,
    Expression<String>? tocUrl,
    Expression<String>? wordCount,
    Expression<String>? lastReadChapter,
    Expression<String>? canReName,
    Expression<String>? downloadUrls,
    Expression<String>? updateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (author != null) 'author': author,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (init != null) 'init': init,
      if (intro != null) 'intro': intro,
      if (kind != null) 'kind': kind,
      if (lastChapter != null) 'last_chapter': lastChapter,
      if (name != null) 'name': name,
      if (tocUrl != null) 'toc_url': tocUrl,
      if (wordCount != null) 'word_count': wordCount,
      if (lastReadChapter != null) 'last_read_chapter': lastReadChapter,
      if (canReName != null) 'can_re_name': canReName,
      if (downloadUrls != null) 'download_urls': downloadUrls,
      if (updateTime != null) 'update_time': updateTime,
    });
  }

  RuleBookInfosCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String?>? author,
      Value<String?>? coverUrl,
      Value<String?>? init,
      Value<String?>? intro,
      Value<String?>? kind,
      Value<String?>? lastChapter,
      Value<String?>? name,
      Value<String?>? tocUrl,
      Value<String?>? wordCount,
      Value<String?>? lastReadChapter,
      Value<String?>? canReName,
      Value<String?>? downloadUrls,
      Value<String?>? updateTime}) {
    return RuleBookInfosCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      init: init ?? this.init,
      intro: intro ?? this.intro,
      kind: kind ?? this.kind,
      lastChapter: lastChapter ?? this.lastChapter,
      name: name ?? this.name,
      tocUrl: tocUrl ?? this.tocUrl,
      wordCount: wordCount ?? this.wordCount,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
      canReName: canReName ?? this.canReName,
      downloadUrls: downloadUrls ?? this.downloadUrls,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (init.present) {
      map['init'] = Variable<String>(init.value);
    }
    if (intro.present) {
      map['intro'] = Variable<String>(intro.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (lastChapter.present) {
      map['last_chapter'] = Variable<String>(lastChapter.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tocUrl.present) {
      map['toc_url'] = Variable<String>(tocUrl.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<String>(wordCount.value);
    }
    if (lastReadChapter.present) {
      map['last_read_chapter'] = Variable<String>(lastReadChapter.value);
    }
    if (canReName.present) {
      map['can_re_name'] = Variable<String>(canReName.value);
    }
    if (downloadUrls.present) {
      map['download_urls'] = Variable<String>(downloadUrls.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<String>(updateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RuleBookInfosCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('author: $author, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('init: $init, ')
          ..write('intro: $intro, ')
          ..write('kind: $kind, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('name: $name, ')
          ..write('tocUrl: $tocUrl, ')
          ..write('wordCount: $wordCount, ')
          ..write('lastReadChapter: $lastReadChapter, ')
          ..write('canReName: $canReName, ')
          ..write('downloadUrls: $downloadUrls, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }
}

class $RuleContentsTable extends RuleContents
    with TableInfo<$RuleContentsTable, RuleContent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RuleContentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextContentUrlMeta =
      const VerificationMeta('nextContentUrl');
  @override
  late final GeneratedColumn<String> nextContentUrl = GeneratedColumn<String>(
      'next_content_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _replaceRegexMeta =
      const VerificationMeta('replaceRegex');
  @override
  late final GeneratedColumn<String> replaceRegex = GeneratedColumn<String>(
      'replace_regex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _webJsMeta = const VerificationMeta('webJs');
  @override
  late final GeneratedColumn<String> webJs = GeneratedColumn<String>(
      'web_js', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceRegexMeta =
      const VerificationMeta('sourceRegex');
  @override
  late final GeneratedColumn<String> sourceRegex = GeneratedColumn<String>(
      'source_regex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageStyleMeta =
      const VerificationMeta('imageStyle');
  @override
  late final GeneratedColumn<String> imageStyle = GeneratedColumn<String>(
      'image_style', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageDecodeMeta =
      const VerificationMeta('imageDecode');
  @override
  late final GeneratedColumn<String> imageDecode = GeneratedColumn<String>(
      'image_decode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payActionMeta =
      const VerificationMeta('payAction');
  @override
  late final GeneratedColumn<String> payAction = GeneratedColumn<String>(
      'pay_action', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        content,
        nextContentUrl,
        replaceRegex,
        title,
        webJs,
        sourceRegex,
        imageStyle,
        imageDecode,
        payAction
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule_contents';
  @override
  VerificationContext validateIntegrity(Insertable<RuleContent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('next_content_url')) {
      context.handle(
          _nextContentUrlMeta,
          nextContentUrl.isAcceptableOrUnknown(
              data['next_content_url']!, _nextContentUrlMeta));
    }
    if (data.containsKey('replace_regex')) {
      context.handle(
          _replaceRegexMeta,
          replaceRegex.isAcceptableOrUnknown(
              data['replace_regex']!, _replaceRegexMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('web_js')) {
      context.handle(
          _webJsMeta, webJs.isAcceptableOrUnknown(data['web_js']!, _webJsMeta));
    }
    if (data.containsKey('source_regex')) {
      context.handle(
          _sourceRegexMeta,
          sourceRegex.isAcceptableOrUnknown(
              data['source_regex']!, _sourceRegexMeta));
    }
    if (data.containsKey('image_style')) {
      context.handle(
          _imageStyleMeta,
          imageStyle.isAcceptableOrUnknown(
              data['image_style']!, _imageStyleMeta));
    }
    if (data.containsKey('image_decode')) {
      context.handle(
          _imageDecodeMeta,
          imageDecode.isAcceptableOrUnknown(
              data['image_decode']!, _imageDecodeMeta));
    }
    if (data.containsKey('pay_action')) {
      context.handle(_payActionMeta,
          payAction.isAcceptableOrUnknown(data['pay_action']!, _payActionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleContent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleContent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      nextContentUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}next_content_url']),
      replaceRegex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}replace_regex']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      webJs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}web_js']),
      sourceRegex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_regex']),
      imageStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_style']),
      imageDecode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_decode']),
      payAction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pay_action']),
    );
  }

  @override
  $RuleContentsTable createAlias(String alias) {
    return $RuleContentsTable(attachedDatabase, alias);
  }
}

class RuleContent extends DataClass implements Insertable<RuleContent> {
  final int id;
  final int bookSourceId;
  final String? content;
  final String? nextContentUrl;
  final String? replaceRegex;

  /// 正文页标题规则
  final String? title;

  /// 正文 WebView 预注入 JS
  final String? webJs;

  /// 响应体过滤正则，提取真实内容区域
  final String? sourceRegex;

  /// 图片样式
  final String? imageStyle;

  /// 图片解密 JS
  final String? imageDecode;

  /// 付费章节解锁动作
  final String? payAction;
  const RuleContent(
      {required this.id,
      required this.bookSourceId,
      this.content,
      this.nextContentUrl,
      this.replaceRegex,
      this.title,
      this.webJs,
      this.sourceRegex,
      this.imageStyle,
      this.imageDecode,
      this.payAction});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || nextContentUrl != null) {
      map['next_content_url'] = Variable<String>(nextContentUrl);
    }
    if (!nullToAbsent || replaceRegex != null) {
      map['replace_regex'] = Variable<String>(replaceRegex);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || webJs != null) {
      map['web_js'] = Variable<String>(webJs);
    }
    if (!nullToAbsent || sourceRegex != null) {
      map['source_regex'] = Variable<String>(sourceRegex);
    }
    if (!nullToAbsent || imageStyle != null) {
      map['image_style'] = Variable<String>(imageStyle);
    }
    if (!nullToAbsent || imageDecode != null) {
      map['image_decode'] = Variable<String>(imageDecode);
    }
    if (!nullToAbsent || payAction != null) {
      map['pay_action'] = Variable<String>(payAction);
    }
    return map;
  }

  RuleContentsCompanion toCompanion(bool nullToAbsent) {
    return RuleContentsCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      nextContentUrl: nextContentUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(nextContentUrl),
      replaceRegex: replaceRegex == null && nullToAbsent
          ? const Value.absent()
          : Value(replaceRegex),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      webJs:
          webJs == null && nullToAbsent ? const Value.absent() : Value(webJs),
      sourceRegex: sourceRegex == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRegex),
      imageStyle: imageStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(imageStyle),
      imageDecode: imageDecode == null && nullToAbsent
          ? const Value.absent()
          : Value(imageDecode),
      payAction: payAction == null && nullToAbsent
          ? const Value.absent()
          : Value(payAction),
    );
  }

  factory RuleContent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleContent(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      content: serializer.fromJson<String?>(json['content']),
      nextContentUrl: serializer.fromJson<String?>(json['nextContentUrl']),
      replaceRegex: serializer.fromJson<String?>(json['replaceRegex']),
      title: serializer.fromJson<String?>(json['title']),
      webJs: serializer.fromJson<String?>(json['webJs']),
      sourceRegex: serializer.fromJson<String?>(json['sourceRegex']),
      imageStyle: serializer.fromJson<String?>(json['imageStyle']),
      imageDecode: serializer.fromJson<String?>(json['imageDecode']),
      payAction: serializer.fromJson<String?>(json['payAction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'content': serializer.toJson<String?>(content),
      'nextContentUrl': serializer.toJson<String?>(nextContentUrl),
      'replaceRegex': serializer.toJson<String?>(replaceRegex),
      'title': serializer.toJson<String?>(title),
      'webJs': serializer.toJson<String?>(webJs),
      'sourceRegex': serializer.toJson<String?>(sourceRegex),
      'imageStyle': serializer.toJson<String?>(imageStyle),
      'imageDecode': serializer.toJson<String?>(imageDecode),
      'payAction': serializer.toJson<String?>(payAction),
    };
  }

  RuleContent copyWith(
          {int? id,
          int? bookSourceId,
          Value<String?> content = const Value.absent(),
          Value<String?> nextContentUrl = const Value.absent(),
          Value<String?> replaceRegex = const Value.absent(),
          Value<String?> title = const Value.absent(),
          Value<String?> webJs = const Value.absent(),
          Value<String?> sourceRegex = const Value.absent(),
          Value<String?> imageStyle = const Value.absent(),
          Value<String?> imageDecode = const Value.absent(),
          Value<String?> payAction = const Value.absent()}) =>
      RuleContent(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        content: content.present ? content.value : this.content,
        nextContentUrl:
            nextContentUrl.present ? nextContentUrl.value : this.nextContentUrl,
        replaceRegex:
            replaceRegex.present ? replaceRegex.value : this.replaceRegex,
        title: title.present ? title.value : this.title,
        webJs: webJs.present ? webJs.value : this.webJs,
        sourceRegex: sourceRegex.present ? sourceRegex.value : this.sourceRegex,
        imageStyle: imageStyle.present ? imageStyle.value : this.imageStyle,
        imageDecode: imageDecode.present ? imageDecode.value : this.imageDecode,
        payAction: payAction.present ? payAction.value : this.payAction,
      );
  RuleContent copyWithCompanion(RuleContentsCompanion data) {
    return RuleContent(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      content: data.content.present ? data.content.value : this.content,
      nextContentUrl: data.nextContentUrl.present
          ? data.nextContentUrl.value
          : this.nextContentUrl,
      replaceRegex: data.replaceRegex.present
          ? data.replaceRegex.value
          : this.replaceRegex,
      title: data.title.present ? data.title.value : this.title,
      webJs: data.webJs.present ? data.webJs.value : this.webJs,
      sourceRegex:
          data.sourceRegex.present ? data.sourceRegex.value : this.sourceRegex,
      imageStyle:
          data.imageStyle.present ? data.imageStyle.value : this.imageStyle,
      imageDecode:
          data.imageDecode.present ? data.imageDecode.value : this.imageDecode,
      payAction: data.payAction.present ? data.payAction.value : this.payAction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleContent(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('content: $content, ')
          ..write('nextContentUrl: $nextContentUrl, ')
          ..write('replaceRegex: $replaceRegex, ')
          ..write('title: $title, ')
          ..write('webJs: $webJs, ')
          ..write('sourceRegex: $sourceRegex, ')
          ..write('imageStyle: $imageStyle, ')
          ..write('imageDecode: $imageDecode, ')
          ..write('payAction: $payAction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookSourceId,
      content,
      nextContentUrl,
      replaceRegex,
      title,
      webJs,
      sourceRegex,
      imageStyle,
      imageDecode,
      payAction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleContent &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.content == this.content &&
          other.nextContentUrl == this.nextContentUrl &&
          other.replaceRegex == this.replaceRegex &&
          other.title == this.title &&
          other.webJs == this.webJs &&
          other.sourceRegex == this.sourceRegex &&
          other.imageStyle == this.imageStyle &&
          other.imageDecode == this.imageDecode &&
          other.payAction == this.payAction);
}

class RuleContentsCompanion extends UpdateCompanion<RuleContent> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String?> content;
  final Value<String?> nextContentUrl;
  final Value<String?> replaceRegex;
  final Value<String?> title;
  final Value<String?> webJs;
  final Value<String?> sourceRegex;
  final Value<String?> imageStyle;
  final Value<String?> imageDecode;
  final Value<String?> payAction;
  const RuleContentsCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.content = const Value.absent(),
    this.nextContentUrl = const Value.absent(),
    this.replaceRegex = const Value.absent(),
    this.title = const Value.absent(),
    this.webJs = const Value.absent(),
    this.sourceRegex = const Value.absent(),
    this.imageStyle = const Value.absent(),
    this.imageDecode = const Value.absent(),
    this.payAction = const Value.absent(),
  });
  RuleContentsCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    this.content = const Value.absent(),
    this.nextContentUrl = const Value.absent(),
    this.replaceRegex = const Value.absent(),
    this.title = const Value.absent(),
    this.webJs = const Value.absent(),
    this.sourceRegex = const Value.absent(),
    this.imageStyle = const Value.absent(),
    this.imageDecode = const Value.absent(),
    this.payAction = const Value.absent(),
  }) : bookSourceId = Value(bookSourceId);
  static Insertable<RuleContent> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? content,
    Expression<String>? nextContentUrl,
    Expression<String>? replaceRegex,
    Expression<String>? title,
    Expression<String>? webJs,
    Expression<String>? sourceRegex,
    Expression<String>? imageStyle,
    Expression<String>? imageDecode,
    Expression<String>? payAction,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (content != null) 'content': content,
      if (nextContentUrl != null) 'next_content_url': nextContentUrl,
      if (replaceRegex != null) 'replace_regex': replaceRegex,
      if (title != null) 'title': title,
      if (webJs != null) 'web_js': webJs,
      if (sourceRegex != null) 'source_regex': sourceRegex,
      if (imageStyle != null) 'image_style': imageStyle,
      if (imageDecode != null) 'image_decode': imageDecode,
      if (payAction != null) 'pay_action': payAction,
    });
  }

  RuleContentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String?>? content,
      Value<String?>? nextContentUrl,
      Value<String?>? replaceRegex,
      Value<String?>? title,
      Value<String?>? webJs,
      Value<String?>? sourceRegex,
      Value<String?>? imageStyle,
      Value<String?>? imageDecode,
      Value<String?>? payAction}) {
    return RuleContentsCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      content: content ?? this.content,
      nextContentUrl: nextContentUrl ?? this.nextContentUrl,
      replaceRegex: replaceRegex ?? this.replaceRegex,
      title: title ?? this.title,
      webJs: webJs ?? this.webJs,
      sourceRegex: sourceRegex ?? this.sourceRegex,
      imageStyle: imageStyle ?? this.imageStyle,
      imageDecode: imageDecode ?? this.imageDecode,
      payAction: payAction ?? this.payAction,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (nextContentUrl.present) {
      map['next_content_url'] = Variable<String>(nextContentUrl.value);
    }
    if (replaceRegex.present) {
      map['replace_regex'] = Variable<String>(replaceRegex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (webJs.present) {
      map['web_js'] = Variable<String>(webJs.value);
    }
    if (sourceRegex.present) {
      map['source_regex'] = Variable<String>(sourceRegex.value);
    }
    if (imageStyle.present) {
      map['image_style'] = Variable<String>(imageStyle.value);
    }
    if (imageDecode.present) {
      map['image_decode'] = Variable<String>(imageDecode.value);
    }
    if (payAction.present) {
      map['pay_action'] = Variable<String>(payAction.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RuleContentsCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('content: $content, ')
          ..write('nextContentUrl: $nextContentUrl, ')
          ..write('replaceRegex: $replaceRegex, ')
          ..write('title: $title, ')
          ..write('webJs: $webJs, ')
          ..write('sourceRegex: $sourceRegex, ')
          ..write('imageStyle: $imageStyle, ')
          ..write('imageDecode: $imageDecode, ')
          ..write('payAction: $payAction')
          ..write(')'))
        .toString();
  }
}

class $RuleSearchsTable extends RuleSearchs
    with TableInfo<$RuleSearchsTable, RuleSearch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RuleSearchsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bookListMeta =
      const VerificationMeta('bookList');
  @override
  late final GeneratedColumn<String> bookList = GeneratedColumn<String>(
      'book_list', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bookUrlMeta =
      const VerificationMeta('bookUrl');
  @override
  late final GeneratedColumn<String> bookUrl = GeneratedColumn<String>(
      'book_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _introMeta = const VerificationMeta('intro');
  @override
  late final GeneratedColumn<String> intro = GeneratedColumn<String>(
      'intro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastChapterMeta =
      const VerificationMeta('lastChapter');
  @override
  late final GeneratedColumn<String> lastChapter = GeneratedColumn<String>(
      'last_chapter', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wordCountMeta =
      const VerificationMeta('wordCount');
  @override
  late final GeneratedColumn<String> wordCount = GeneratedColumn<String>(
      'word_count', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tocUrlMeta = const VerificationMeta('tocUrl');
  @override
  late final GeneratedColumn<String> tocUrl = GeneratedColumn<String>(
      'toc_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checkKeyWordMeta =
      const VerificationMeta('checkKeyWord');
  @override
  late final GeneratedColumn<String> checkKeyWord = GeneratedColumn<String>(
      'check_key_word', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updateTimeMeta =
      const VerificationMeta('updateTime');
  @override
  late final GeneratedColumn<String> updateTime = GeneratedColumn<String>(
      'update_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        name,
        author,
        bookList,
        bookUrl,
        coverUrl,
        intro,
        kind,
        lastChapter,
        wordCount,
        tocUrl,
        checkKeyWord,
        updateTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule_searchs';
  @override
  VerificationContext validateIntegrity(Insertable<RuleSearch> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('book_list')) {
      context.handle(_bookListMeta,
          bookList.isAcceptableOrUnknown(data['book_list']!, _bookListMeta));
    }
    if (data.containsKey('book_url')) {
      context.handle(_bookUrlMeta,
          bookUrl.isAcceptableOrUnknown(data['book_url']!, _bookUrlMeta));
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    }
    if (data.containsKey('intro')) {
      context.handle(
          _introMeta, intro.isAcceptableOrUnknown(data['intro']!, _introMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('last_chapter')) {
      context.handle(
          _lastChapterMeta,
          lastChapter.isAcceptableOrUnknown(
              data['last_chapter']!, _lastChapterMeta));
    }
    if (data.containsKey('word_count')) {
      context.handle(_wordCountMeta,
          wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta));
    }
    if (data.containsKey('toc_url')) {
      context.handle(_tocUrlMeta,
          tocUrl.isAcceptableOrUnknown(data['toc_url']!, _tocUrlMeta));
    }
    if (data.containsKey('check_key_word')) {
      context.handle(
          _checkKeyWordMeta,
          checkKeyWord.isAcceptableOrUnknown(
              data['check_key_word']!, _checkKeyWordMeta));
    }
    if (data.containsKey('update_time')) {
      context.handle(
          _updateTimeMeta,
          updateTime.isAcceptableOrUnknown(
              data['update_time']!, _updateTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleSearch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleSearch(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      bookList: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_list']),
      bookUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_url']),
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url']),
      intro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intro']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind']),
      lastChapter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_chapter']),
      wordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word_count']),
      tocUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}toc_url']),
      checkKeyWord: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}check_key_word']),
      updateTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}update_time']),
    );
  }

  @override
  $RuleSearchsTable createAlias(String alias) {
    return $RuleSearchsTable(attachedDatabase, alias);
  }
}

class RuleSearch extends DataClass implements Insertable<RuleSearch> {
  final int id;
  final int bookSourceId;
  final String? name;
  final String? author;
  final String? bookList;
  final String? bookUrl;
  final String? coverUrl;
  final String? intro;
  final String? kind;
  final String? lastChapter;
  final String? wordCount;
  final String? tocUrl;

  /// 验证搜索关键词命中规则
  final String? checkKeyWord;

  /// 更新时间规则
  final String? updateTime;
  const RuleSearch(
      {required this.id,
      required this.bookSourceId,
      this.name,
      this.author,
      this.bookList,
      this.bookUrl,
      this.coverUrl,
      this.intro,
      this.kind,
      this.lastChapter,
      this.wordCount,
      this.tocUrl,
      this.checkKeyWord,
      this.updateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || bookList != null) {
      map['book_list'] = Variable<String>(bookList);
    }
    if (!nullToAbsent || bookUrl != null) {
      map['book_url'] = Variable<String>(bookUrl);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || intro != null) {
      map['intro'] = Variable<String>(intro);
    }
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(kind);
    }
    if (!nullToAbsent || lastChapter != null) {
      map['last_chapter'] = Variable<String>(lastChapter);
    }
    if (!nullToAbsent || wordCount != null) {
      map['word_count'] = Variable<String>(wordCount);
    }
    if (!nullToAbsent || tocUrl != null) {
      map['toc_url'] = Variable<String>(tocUrl);
    }
    if (!nullToAbsent || checkKeyWord != null) {
      map['check_key_word'] = Variable<String>(checkKeyWord);
    }
    if (!nullToAbsent || updateTime != null) {
      map['update_time'] = Variable<String>(updateTime);
    }
    return map;
  }

  RuleSearchsCompanion toCompanion(bool nullToAbsent) {
    return RuleSearchsCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      bookList: bookList == null && nullToAbsent
          ? const Value.absent()
          : Value(bookList),
      bookUrl: bookUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(bookUrl),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      intro:
          intro == null && nullToAbsent ? const Value.absent() : Value(intro),
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
      lastChapter: lastChapter == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChapter),
      wordCount: wordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordCount),
      tocUrl:
          tocUrl == null && nullToAbsent ? const Value.absent() : Value(tocUrl),
      checkKeyWord: checkKeyWord == null && nullToAbsent
          ? const Value.absent()
          : Value(checkKeyWord),
      updateTime: updateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(updateTime),
    );
  }

  factory RuleSearch.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleSearch(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      name: serializer.fromJson<String?>(json['name']),
      author: serializer.fromJson<String?>(json['author']),
      bookList: serializer.fromJson<String?>(json['bookList']),
      bookUrl: serializer.fromJson<String?>(json['bookUrl']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      intro: serializer.fromJson<String?>(json['intro']),
      kind: serializer.fromJson<String?>(json['kind']),
      lastChapter: serializer.fromJson<String?>(json['lastChapter']),
      wordCount: serializer.fromJson<String?>(json['wordCount']),
      tocUrl: serializer.fromJson<String?>(json['tocUrl']),
      checkKeyWord: serializer.fromJson<String?>(json['checkKeyWord']),
      updateTime: serializer.fromJson<String?>(json['updateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'name': serializer.toJson<String?>(name),
      'author': serializer.toJson<String?>(author),
      'bookList': serializer.toJson<String?>(bookList),
      'bookUrl': serializer.toJson<String?>(bookUrl),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'intro': serializer.toJson<String?>(intro),
      'kind': serializer.toJson<String?>(kind),
      'lastChapter': serializer.toJson<String?>(lastChapter),
      'wordCount': serializer.toJson<String?>(wordCount),
      'tocUrl': serializer.toJson<String?>(tocUrl),
      'checkKeyWord': serializer.toJson<String?>(checkKeyWord),
      'updateTime': serializer.toJson<String?>(updateTime),
    };
  }

  RuleSearch copyWith(
          {int? id,
          int? bookSourceId,
          Value<String?> name = const Value.absent(),
          Value<String?> author = const Value.absent(),
          Value<String?> bookList = const Value.absent(),
          Value<String?> bookUrl = const Value.absent(),
          Value<String?> coverUrl = const Value.absent(),
          Value<String?> intro = const Value.absent(),
          Value<String?> kind = const Value.absent(),
          Value<String?> lastChapter = const Value.absent(),
          Value<String?> wordCount = const Value.absent(),
          Value<String?> tocUrl = const Value.absent(),
          Value<String?> checkKeyWord = const Value.absent(),
          Value<String?> updateTime = const Value.absent()}) =>
      RuleSearch(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        name: name.present ? name.value : this.name,
        author: author.present ? author.value : this.author,
        bookList: bookList.present ? bookList.value : this.bookList,
        bookUrl: bookUrl.present ? bookUrl.value : this.bookUrl,
        coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
        intro: intro.present ? intro.value : this.intro,
        kind: kind.present ? kind.value : this.kind,
        lastChapter: lastChapter.present ? lastChapter.value : this.lastChapter,
        wordCount: wordCount.present ? wordCount.value : this.wordCount,
        tocUrl: tocUrl.present ? tocUrl.value : this.tocUrl,
        checkKeyWord:
            checkKeyWord.present ? checkKeyWord.value : this.checkKeyWord,
        updateTime: updateTime.present ? updateTime.value : this.updateTime,
      );
  RuleSearch copyWithCompanion(RuleSearchsCompanion data) {
    return RuleSearch(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      name: data.name.present ? data.name.value : this.name,
      author: data.author.present ? data.author.value : this.author,
      bookList: data.bookList.present ? data.bookList.value : this.bookList,
      bookUrl: data.bookUrl.present ? data.bookUrl.value : this.bookUrl,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      intro: data.intro.present ? data.intro.value : this.intro,
      kind: data.kind.present ? data.kind.value : this.kind,
      lastChapter:
          data.lastChapter.present ? data.lastChapter.value : this.lastChapter,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      tocUrl: data.tocUrl.present ? data.tocUrl.value : this.tocUrl,
      checkKeyWord: data.checkKeyWord.present
          ? data.checkKeyWord.value
          : this.checkKeyWord,
      updateTime:
          data.updateTime.present ? data.updateTime.value : this.updateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleSearch(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('bookList: $bookList, ')
          ..write('bookUrl: $bookUrl, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('intro: $intro, ')
          ..write('kind: $kind, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('wordCount: $wordCount, ')
          ..write('tocUrl: $tocUrl, ')
          ..write('checkKeyWord: $checkKeyWord, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookSourceId,
      name,
      author,
      bookList,
      bookUrl,
      coverUrl,
      intro,
      kind,
      lastChapter,
      wordCount,
      tocUrl,
      checkKeyWord,
      updateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleSearch &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.name == this.name &&
          other.author == this.author &&
          other.bookList == this.bookList &&
          other.bookUrl == this.bookUrl &&
          other.coverUrl == this.coverUrl &&
          other.intro == this.intro &&
          other.kind == this.kind &&
          other.lastChapter == this.lastChapter &&
          other.wordCount == this.wordCount &&
          other.tocUrl == this.tocUrl &&
          other.checkKeyWord == this.checkKeyWord &&
          other.updateTime == this.updateTime);
}

class RuleSearchsCompanion extends UpdateCompanion<RuleSearch> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String?> name;
  final Value<String?> author;
  final Value<String?> bookList;
  final Value<String?> bookUrl;
  final Value<String?> coverUrl;
  final Value<String?> intro;
  final Value<String?> kind;
  final Value<String?> lastChapter;
  final Value<String?> wordCount;
  final Value<String?> tocUrl;
  final Value<String?> checkKeyWord;
  final Value<String?> updateTime;
  const RuleSearchsCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.bookList = const Value.absent(),
    this.bookUrl = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.intro = const Value.absent(),
    this.kind = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.tocUrl = const Value.absent(),
    this.checkKeyWord = const Value.absent(),
    this.updateTime = const Value.absent(),
  });
  RuleSearchsCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.bookList = const Value.absent(),
    this.bookUrl = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.intro = const Value.absent(),
    this.kind = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.tocUrl = const Value.absent(),
    this.checkKeyWord = const Value.absent(),
    this.updateTime = const Value.absent(),
  }) : bookSourceId = Value(bookSourceId);
  static Insertable<RuleSearch> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? name,
    Expression<String>? author,
    Expression<String>? bookList,
    Expression<String>? bookUrl,
    Expression<String>? coverUrl,
    Expression<String>? intro,
    Expression<String>? kind,
    Expression<String>? lastChapter,
    Expression<String>? wordCount,
    Expression<String>? tocUrl,
    Expression<String>? checkKeyWord,
    Expression<String>? updateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (name != null) 'name': name,
      if (author != null) 'author': author,
      if (bookList != null) 'book_list': bookList,
      if (bookUrl != null) 'book_url': bookUrl,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (intro != null) 'intro': intro,
      if (kind != null) 'kind': kind,
      if (lastChapter != null) 'last_chapter': lastChapter,
      if (wordCount != null) 'word_count': wordCount,
      if (tocUrl != null) 'toc_url': tocUrl,
      if (checkKeyWord != null) 'check_key_word': checkKeyWord,
      if (updateTime != null) 'update_time': updateTime,
    });
  }

  RuleSearchsCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String?>? name,
      Value<String?>? author,
      Value<String?>? bookList,
      Value<String?>? bookUrl,
      Value<String?>? coverUrl,
      Value<String?>? intro,
      Value<String?>? kind,
      Value<String?>? lastChapter,
      Value<String?>? wordCount,
      Value<String?>? tocUrl,
      Value<String?>? checkKeyWord,
      Value<String?>? updateTime}) {
    return RuleSearchsCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      name: name ?? this.name,
      author: author ?? this.author,
      bookList: bookList ?? this.bookList,
      bookUrl: bookUrl ?? this.bookUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      intro: intro ?? this.intro,
      kind: kind ?? this.kind,
      lastChapter: lastChapter ?? this.lastChapter,
      wordCount: wordCount ?? this.wordCount,
      tocUrl: tocUrl ?? this.tocUrl,
      checkKeyWord: checkKeyWord ?? this.checkKeyWord,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (bookList.present) {
      map['book_list'] = Variable<String>(bookList.value);
    }
    if (bookUrl.present) {
      map['book_url'] = Variable<String>(bookUrl.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (intro.present) {
      map['intro'] = Variable<String>(intro.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (lastChapter.present) {
      map['last_chapter'] = Variable<String>(lastChapter.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<String>(wordCount.value);
    }
    if (tocUrl.present) {
      map['toc_url'] = Variable<String>(tocUrl.value);
    }
    if (checkKeyWord.present) {
      map['check_key_word'] = Variable<String>(checkKeyWord.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<String>(updateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RuleSearchsCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('bookList: $bookList, ')
          ..write('bookUrl: $bookUrl, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('intro: $intro, ')
          ..write('kind: $kind, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('wordCount: $wordCount, ')
          ..write('tocUrl: $tocUrl, ')
          ..write('checkKeyWord: $checkKeyWord, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }
}

class $RuleTocsTable extends RuleTocs with TableInfo<$RuleTocsTable, RuleToc> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RuleTocsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chapterListMeta =
      const VerificationMeta('chapterList');
  @override
  late final GeneratedColumn<String> chapterList = GeneratedColumn<String>(
      'chapter_list', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterNameMeta =
      const VerificationMeta('chapterName');
  @override
  late final GeneratedColumn<String> chapterName = GeneratedColumn<String>(
      'chapter_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterUrlMeta =
      const VerificationMeta('chapterUrl');
  @override
  late final GeneratedColumn<String> chapterUrl = GeneratedColumn<String>(
      'chapter_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextTocUrlMeta =
      const VerificationMeta('nextTocUrl');
  @override
  late final GeneratedColumn<String> nextTocUrl = GeneratedColumn<String>(
      'next_toc_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preUpdateJsMeta =
      const VerificationMeta('preUpdateJs');
  @override
  late final GeneratedColumn<String> preUpdateJs = GeneratedColumn<String>(
      'pre_update_js', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formatJsMeta =
      const VerificationMeta('formatJs');
  @override
  late final GeneratedColumn<String> formatJs = GeneratedColumn<String>(
      'format_js', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isVolumeMeta =
      const VerificationMeta('isVolume');
  @override
  late final GeneratedColumn<String> isVolume = GeneratedColumn<String>(
      'is_volume', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isVipMeta = const VerificationMeta('isVip');
  @override
  late final GeneratedColumn<String> isVip = GeneratedColumn<String>(
      'is_vip', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPayMeta = const VerificationMeta('isPay');
  @override
  late final GeneratedColumn<String> isPay = GeneratedColumn<String>(
      'is_pay', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updateTimeMeta =
      const VerificationMeta('updateTime');
  @override
  late final GeneratedColumn<String> updateTime = GeneratedColumn<String>(
      'update_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        chapterList,
        chapterName,
        chapterUrl,
        nextTocUrl,
        preUpdateJs,
        formatJs,
        isVolume,
        isVip,
        isPay,
        updateTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule_tocs';
  @override
  VerificationContext validateIntegrity(Insertable<RuleToc> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('chapter_list')) {
      context.handle(
          _chapterListMeta,
          chapterList.isAcceptableOrUnknown(
              data['chapter_list']!, _chapterListMeta));
    }
    if (data.containsKey('chapter_name')) {
      context.handle(
          _chapterNameMeta,
          chapterName.isAcceptableOrUnknown(
              data['chapter_name']!, _chapterNameMeta));
    }
    if (data.containsKey('chapter_url')) {
      context.handle(
          _chapterUrlMeta,
          chapterUrl.isAcceptableOrUnknown(
              data['chapter_url']!, _chapterUrlMeta));
    }
    if (data.containsKey('next_toc_url')) {
      context.handle(
          _nextTocUrlMeta,
          nextTocUrl.isAcceptableOrUnknown(
              data['next_toc_url']!, _nextTocUrlMeta));
    }
    if (data.containsKey('pre_update_js')) {
      context.handle(
          _preUpdateJsMeta,
          preUpdateJs.isAcceptableOrUnknown(
              data['pre_update_js']!, _preUpdateJsMeta));
    }
    if (data.containsKey('format_js')) {
      context.handle(_formatJsMeta,
          formatJs.isAcceptableOrUnknown(data['format_js']!, _formatJsMeta));
    }
    if (data.containsKey('is_volume')) {
      context.handle(_isVolumeMeta,
          isVolume.isAcceptableOrUnknown(data['is_volume']!, _isVolumeMeta));
    }
    if (data.containsKey('is_vip')) {
      context.handle(
          _isVipMeta, isVip.isAcceptableOrUnknown(data['is_vip']!, _isVipMeta));
    }
    if (data.containsKey('is_pay')) {
      context.handle(
          _isPayMeta, isPay.isAcceptableOrUnknown(data['is_pay']!, _isPayMeta));
    }
    if (data.containsKey('update_time')) {
      context.handle(
          _updateTimeMeta,
          updateTime.isAcceptableOrUnknown(
              data['update_time']!, _updateTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleToc map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleToc(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      chapterList: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_list']),
      chapterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_name']),
      chapterUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_url']),
      nextTocUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}next_toc_url']),
      preUpdateJs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pre_update_js']),
      formatJs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format_js']),
      isVolume: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}is_volume']),
      isVip: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}is_vip']),
      isPay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}is_pay']),
      updateTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}update_time']),
    );
  }

  @override
  $RuleTocsTable createAlias(String alias) {
    return $RuleTocsTable(attachedDatabase, alias);
  }
}

class RuleToc extends DataClass implements Insertable<RuleToc> {
  final int id;
  final int bookSourceId;
  final String? chapterList;
  final String? chapterName;
  final String? chapterUrl;
  final String? nextTocUrl;

  /// 目录请求前执行的 JS，用于初始化 cookie/变量
  final String? preUpdateJs;

  /// 章节名后处理 JS
  final String? formatJs;

  /// 是否为分卷标记规则
  final String? isVolume;

  /// VIP 章节识别规则
  final String? isVip;

  /// 付费章节识别规则
  final String? isPay;

  /// 更新时间规则
  final String? updateTime;
  const RuleToc(
      {required this.id,
      required this.bookSourceId,
      this.chapterList,
      this.chapterName,
      this.chapterUrl,
      this.nextTocUrl,
      this.preUpdateJs,
      this.formatJs,
      this.isVolume,
      this.isVip,
      this.isPay,
      this.updateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    if (!nullToAbsent || chapterList != null) {
      map['chapter_list'] = Variable<String>(chapterList);
    }
    if (!nullToAbsent || chapterName != null) {
      map['chapter_name'] = Variable<String>(chapterName);
    }
    if (!nullToAbsent || chapterUrl != null) {
      map['chapter_url'] = Variable<String>(chapterUrl);
    }
    if (!nullToAbsent || nextTocUrl != null) {
      map['next_toc_url'] = Variable<String>(nextTocUrl);
    }
    if (!nullToAbsent || preUpdateJs != null) {
      map['pre_update_js'] = Variable<String>(preUpdateJs);
    }
    if (!nullToAbsent || formatJs != null) {
      map['format_js'] = Variable<String>(formatJs);
    }
    if (!nullToAbsent || isVolume != null) {
      map['is_volume'] = Variable<String>(isVolume);
    }
    if (!nullToAbsent || isVip != null) {
      map['is_vip'] = Variable<String>(isVip);
    }
    if (!nullToAbsent || isPay != null) {
      map['is_pay'] = Variable<String>(isPay);
    }
    if (!nullToAbsent || updateTime != null) {
      map['update_time'] = Variable<String>(updateTime);
    }
    return map;
  }

  RuleTocsCompanion toCompanion(bool nullToAbsent) {
    return RuleTocsCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      chapterList: chapterList == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterList),
      chapterName: chapterName == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterName),
      chapterUrl: chapterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterUrl),
      nextTocUrl: nextTocUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(nextTocUrl),
      preUpdateJs: preUpdateJs == null && nullToAbsent
          ? const Value.absent()
          : Value(preUpdateJs),
      formatJs: formatJs == null && nullToAbsent
          ? const Value.absent()
          : Value(formatJs),
      isVolume: isVolume == null && nullToAbsent
          ? const Value.absent()
          : Value(isVolume),
      isVip:
          isVip == null && nullToAbsent ? const Value.absent() : Value(isVip),
      isPay:
          isPay == null && nullToAbsent ? const Value.absent() : Value(isPay),
      updateTime: updateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(updateTime),
    );
  }

  factory RuleToc.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleToc(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      chapterList: serializer.fromJson<String?>(json['chapterList']),
      chapterName: serializer.fromJson<String?>(json['chapterName']),
      chapterUrl: serializer.fromJson<String?>(json['chapterUrl']),
      nextTocUrl: serializer.fromJson<String?>(json['nextTocUrl']),
      preUpdateJs: serializer.fromJson<String?>(json['preUpdateJs']),
      formatJs: serializer.fromJson<String?>(json['formatJs']),
      isVolume: serializer.fromJson<String?>(json['isVolume']),
      isVip: serializer.fromJson<String?>(json['isVip']),
      isPay: serializer.fromJson<String?>(json['isPay']),
      updateTime: serializer.fromJson<String?>(json['updateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'chapterList': serializer.toJson<String?>(chapterList),
      'chapterName': serializer.toJson<String?>(chapterName),
      'chapterUrl': serializer.toJson<String?>(chapterUrl),
      'nextTocUrl': serializer.toJson<String?>(nextTocUrl),
      'preUpdateJs': serializer.toJson<String?>(preUpdateJs),
      'formatJs': serializer.toJson<String?>(formatJs),
      'isVolume': serializer.toJson<String?>(isVolume),
      'isVip': serializer.toJson<String?>(isVip),
      'isPay': serializer.toJson<String?>(isPay),
      'updateTime': serializer.toJson<String?>(updateTime),
    };
  }

  RuleToc copyWith(
          {int? id,
          int? bookSourceId,
          Value<String?> chapterList = const Value.absent(),
          Value<String?> chapterName = const Value.absent(),
          Value<String?> chapterUrl = const Value.absent(),
          Value<String?> nextTocUrl = const Value.absent(),
          Value<String?> preUpdateJs = const Value.absent(),
          Value<String?> formatJs = const Value.absent(),
          Value<String?> isVolume = const Value.absent(),
          Value<String?> isVip = const Value.absent(),
          Value<String?> isPay = const Value.absent(),
          Value<String?> updateTime = const Value.absent()}) =>
      RuleToc(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        chapterList: chapterList.present ? chapterList.value : this.chapterList,
        chapterName: chapterName.present ? chapterName.value : this.chapterName,
        chapterUrl: chapterUrl.present ? chapterUrl.value : this.chapterUrl,
        nextTocUrl: nextTocUrl.present ? nextTocUrl.value : this.nextTocUrl,
        preUpdateJs: preUpdateJs.present ? preUpdateJs.value : this.preUpdateJs,
        formatJs: formatJs.present ? formatJs.value : this.formatJs,
        isVolume: isVolume.present ? isVolume.value : this.isVolume,
        isVip: isVip.present ? isVip.value : this.isVip,
        isPay: isPay.present ? isPay.value : this.isPay,
        updateTime: updateTime.present ? updateTime.value : this.updateTime,
      );
  RuleToc copyWithCompanion(RuleTocsCompanion data) {
    return RuleToc(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      chapterList:
          data.chapterList.present ? data.chapterList.value : this.chapterList,
      chapterName:
          data.chapterName.present ? data.chapterName.value : this.chapterName,
      chapterUrl:
          data.chapterUrl.present ? data.chapterUrl.value : this.chapterUrl,
      nextTocUrl:
          data.nextTocUrl.present ? data.nextTocUrl.value : this.nextTocUrl,
      preUpdateJs:
          data.preUpdateJs.present ? data.preUpdateJs.value : this.preUpdateJs,
      formatJs: data.formatJs.present ? data.formatJs.value : this.formatJs,
      isVolume: data.isVolume.present ? data.isVolume.value : this.isVolume,
      isVip: data.isVip.present ? data.isVip.value : this.isVip,
      isPay: data.isPay.present ? data.isPay.value : this.isPay,
      updateTime:
          data.updateTime.present ? data.updateTime.value : this.updateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleToc(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('chapterList: $chapterList, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('nextTocUrl: $nextTocUrl, ')
          ..write('preUpdateJs: $preUpdateJs, ')
          ..write('formatJs: $formatJs, ')
          ..write('isVolume: $isVolume, ')
          ..write('isVip: $isVip, ')
          ..write('isPay: $isPay, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookSourceId,
      chapterList,
      chapterName,
      chapterUrl,
      nextTocUrl,
      preUpdateJs,
      formatJs,
      isVolume,
      isVip,
      isPay,
      updateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleToc &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.chapterList == this.chapterList &&
          other.chapterName == this.chapterName &&
          other.chapterUrl == this.chapterUrl &&
          other.nextTocUrl == this.nextTocUrl &&
          other.preUpdateJs == this.preUpdateJs &&
          other.formatJs == this.formatJs &&
          other.isVolume == this.isVolume &&
          other.isVip == this.isVip &&
          other.isPay == this.isPay &&
          other.updateTime == this.updateTime);
}

class RuleTocsCompanion extends UpdateCompanion<RuleToc> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String?> chapterList;
  final Value<String?> chapterName;
  final Value<String?> chapterUrl;
  final Value<String?> nextTocUrl;
  final Value<String?> preUpdateJs;
  final Value<String?> formatJs;
  final Value<String?> isVolume;
  final Value<String?> isVip;
  final Value<String?> isPay;
  final Value<String?> updateTime;
  const RuleTocsCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.chapterList = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.chapterUrl = const Value.absent(),
    this.nextTocUrl = const Value.absent(),
    this.preUpdateJs = const Value.absent(),
    this.formatJs = const Value.absent(),
    this.isVolume = const Value.absent(),
    this.isVip = const Value.absent(),
    this.isPay = const Value.absent(),
    this.updateTime = const Value.absent(),
  });
  RuleTocsCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    this.chapterList = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.chapterUrl = const Value.absent(),
    this.nextTocUrl = const Value.absent(),
    this.preUpdateJs = const Value.absent(),
    this.formatJs = const Value.absent(),
    this.isVolume = const Value.absent(),
    this.isVip = const Value.absent(),
    this.isPay = const Value.absent(),
    this.updateTime = const Value.absent(),
  }) : bookSourceId = Value(bookSourceId);
  static Insertable<RuleToc> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? chapterList,
    Expression<String>? chapterName,
    Expression<String>? chapterUrl,
    Expression<String>? nextTocUrl,
    Expression<String>? preUpdateJs,
    Expression<String>? formatJs,
    Expression<String>? isVolume,
    Expression<String>? isVip,
    Expression<String>? isPay,
    Expression<String>? updateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (chapterList != null) 'chapter_list': chapterList,
      if (chapterName != null) 'chapter_name': chapterName,
      if (chapterUrl != null) 'chapter_url': chapterUrl,
      if (nextTocUrl != null) 'next_toc_url': nextTocUrl,
      if (preUpdateJs != null) 'pre_update_js': preUpdateJs,
      if (formatJs != null) 'format_js': formatJs,
      if (isVolume != null) 'is_volume': isVolume,
      if (isVip != null) 'is_vip': isVip,
      if (isPay != null) 'is_pay': isPay,
      if (updateTime != null) 'update_time': updateTime,
    });
  }

  RuleTocsCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String?>? chapterList,
      Value<String?>? chapterName,
      Value<String?>? chapterUrl,
      Value<String?>? nextTocUrl,
      Value<String?>? preUpdateJs,
      Value<String?>? formatJs,
      Value<String?>? isVolume,
      Value<String?>? isVip,
      Value<String?>? isPay,
      Value<String?>? updateTime}) {
    return RuleTocsCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      chapterList: chapterList ?? this.chapterList,
      chapterName: chapterName ?? this.chapterName,
      chapterUrl: chapterUrl ?? this.chapterUrl,
      nextTocUrl: nextTocUrl ?? this.nextTocUrl,
      preUpdateJs: preUpdateJs ?? this.preUpdateJs,
      formatJs: formatJs ?? this.formatJs,
      isVolume: isVolume ?? this.isVolume,
      isVip: isVip ?? this.isVip,
      isPay: isPay ?? this.isPay,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (chapterList.present) {
      map['chapter_list'] = Variable<String>(chapterList.value);
    }
    if (chapterName.present) {
      map['chapter_name'] = Variable<String>(chapterName.value);
    }
    if (chapterUrl.present) {
      map['chapter_url'] = Variable<String>(chapterUrl.value);
    }
    if (nextTocUrl.present) {
      map['next_toc_url'] = Variable<String>(nextTocUrl.value);
    }
    if (preUpdateJs.present) {
      map['pre_update_js'] = Variable<String>(preUpdateJs.value);
    }
    if (formatJs.present) {
      map['format_js'] = Variable<String>(formatJs.value);
    }
    if (isVolume.present) {
      map['is_volume'] = Variable<String>(isVolume.value);
    }
    if (isVip.present) {
      map['is_vip'] = Variable<String>(isVip.value);
    }
    if (isPay.present) {
      map['is_pay'] = Variable<String>(isPay.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<String>(updateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RuleTocsCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('chapterList: $chapterList, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('nextTocUrl: $nextTocUrl, ')
          ..write('preUpdateJs: $preUpdateJs, ')
          ..write('formatJs: $formatJs, ')
          ..write('isVolume: $isVolume, ')
          ..write('isVip: $isVip, ')
          ..write('isPay: $isPay, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }
}

class $RuleExploresTable extends RuleExplores
    with TableInfo<$RuleExploresTable, RuleExplore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RuleExploresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bookListMeta =
      const VerificationMeta('bookList');
  @override
  late final GeneratedColumn<String> bookList = GeneratedColumn<String>(
      'book_list', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bookUrlMeta =
      const VerificationMeta('bookUrl');
  @override
  late final GeneratedColumn<String> bookUrl = GeneratedColumn<String>(
      'book_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _introMeta = const VerificationMeta('intro');
  @override
  late final GeneratedColumn<String> intro = GeneratedColumn<String>(
      'intro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastChapterMeta =
      const VerificationMeta('lastChapter');
  @override
  late final GeneratedColumn<String> lastChapter = GeneratedColumn<String>(
      'last_chapter', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wordCountMeta =
      const VerificationMeta('wordCount');
  @override
  late final GeneratedColumn<String> wordCount = GeneratedColumn<String>(
      'word_count', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        bookList,
        name,
        author,
        bookUrl,
        coverUrl,
        intro,
        kind,
        lastChapter,
        wordCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule_explores';
  @override
  VerificationContext validateIntegrity(Insertable<RuleExplore> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('book_list')) {
      context.handle(_bookListMeta,
          bookList.isAcceptableOrUnknown(data['book_list']!, _bookListMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('book_url')) {
      context.handle(_bookUrlMeta,
          bookUrl.isAcceptableOrUnknown(data['book_url']!, _bookUrlMeta));
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    }
    if (data.containsKey('intro')) {
      context.handle(
          _introMeta, intro.isAcceptableOrUnknown(data['intro']!, _introMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('last_chapter')) {
      context.handle(
          _lastChapterMeta,
          lastChapter.isAcceptableOrUnknown(
              data['last_chapter']!, _lastChapterMeta));
    }
    if (data.containsKey('word_count')) {
      context.handle(_wordCountMeta,
          wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleExplore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleExplore(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      bookList: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_list']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      bookUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_url']),
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url']),
      intro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intro']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind']),
      lastChapter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_chapter']),
      wordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word_count']),
    );
  }

  @override
  $RuleExploresTable createAlias(String alias) {
    return $RuleExploresTable(attachedDatabase, alias);
  }
}

class RuleExplore extends DataClass implements Insertable<RuleExplore> {
  final int id;
  final int bookSourceId;
  final String? bookList;
  final String? name;
  final String? author;
  final String? bookUrl;
  final String? coverUrl;
  final String? intro;
  final String? kind;
  final String? lastChapter;

  /// 字数规则
  final String? wordCount;
  const RuleExplore(
      {required this.id,
      required this.bookSourceId,
      this.bookList,
      this.name,
      this.author,
      this.bookUrl,
      this.coverUrl,
      this.intro,
      this.kind,
      this.lastChapter,
      this.wordCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    if (!nullToAbsent || bookList != null) {
      map['book_list'] = Variable<String>(bookList);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || bookUrl != null) {
      map['book_url'] = Variable<String>(bookUrl);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || intro != null) {
      map['intro'] = Variable<String>(intro);
    }
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(kind);
    }
    if (!nullToAbsent || lastChapter != null) {
      map['last_chapter'] = Variable<String>(lastChapter);
    }
    if (!nullToAbsent || wordCount != null) {
      map['word_count'] = Variable<String>(wordCount);
    }
    return map;
  }

  RuleExploresCompanion toCompanion(bool nullToAbsent) {
    return RuleExploresCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      bookList: bookList == null && nullToAbsent
          ? const Value.absent()
          : Value(bookList),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      bookUrl: bookUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(bookUrl),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      intro:
          intro == null && nullToAbsent ? const Value.absent() : Value(intro),
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
      lastChapter: lastChapter == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChapter),
      wordCount: wordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordCount),
    );
  }

  factory RuleExplore.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleExplore(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      bookList: serializer.fromJson<String?>(json['bookList']),
      name: serializer.fromJson<String?>(json['name']),
      author: serializer.fromJson<String?>(json['author']),
      bookUrl: serializer.fromJson<String?>(json['bookUrl']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      intro: serializer.fromJson<String?>(json['intro']),
      kind: serializer.fromJson<String?>(json['kind']),
      lastChapter: serializer.fromJson<String?>(json['lastChapter']),
      wordCount: serializer.fromJson<String?>(json['wordCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'bookList': serializer.toJson<String?>(bookList),
      'name': serializer.toJson<String?>(name),
      'author': serializer.toJson<String?>(author),
      'bookUrl': serializer.toJson<String?>(bookUrl),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'intro': serializer.toJson<String?>(intro),
      'kind': serializer.toJson<String?>(kind),
      'lastChapter': serializer.toJson<String?>(lastChapter),
      'wordCount': serializer.toJson<String?>(wordCount),
    };
  }

  RuleExplore copyWith(
          {int? id,
          int? bookSourceId,
          Value<String?> bookList = const Value.absent(),
          Value<String?> name = const Value.absent(),
          Value<String?> author = const Value.absent(),
          Value<String?> bookUrl = const Value.absent(),
          Value<String?> coverUrl = const Value.absent(),
          Value<String?> intro = const Value.absent(),
          Value<String?> kind = const Value.absent(),
          Value<String?> lastChapter = const Value.absent(),
          Value<String?> wordCount = const Value.absent()}) =>
      RuleExplore(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        bookList: bookList.present ? bookList.value : this.bookList,
        name: name.present ? name.value : this.name,
        author: author.present ? author.value : this.author,
        bookUrl: bookUrl.present ? bookUrl.value : this.bookUrl,
        coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
        intro: intro.present ? intro.value : this.intro,
        kind: kind.present ? kind.value : this.kind,
        lastChapter: lastChapter.present ? lastChapter.value : this.lastChapter,
        wordCount: wordCount.present ? wordCount.value : this.wordCount,
      );
  RuleExplore copyWithCompanion(RuleExploresCompanion data) {
    return RuleExplore(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      bookList: data.bookList.present ? data.bookList.value : this.bookList,
      name: data.name.present ? data.name.value : this.name,
      author: data.author.present ? data.author.value : this.author,
      bookUrl: data.bookUrl.present ? data.bookUrl.value : this.bookUrl,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      intro: data.intro.present ? data.intro.value : this.intro,
      kind: data.kind.present ? data.kind.value : this.kind,
      lastChapter:
          data.lastChapter.present ? data.lastChapter.value : this.lastChapter,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleExplore(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookList: $bookList, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('bookUrl: $bookUrl, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('intro: $intro, ')
          ..write('kind: $kind, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('wordCount: $wordCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookSourceId, bookList, name, author,
      bookUrl, coverUrl, intro, kind, lastChapter, wordCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleExplore &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.bookList == this.bookList &&
          other.name == this.name &&
          other.author == this.author &&
          other.bookUrl == this.bookUrl &&
          other.coverUrl == this.coverUrl &&
          other.intro == this.intro &&
          other.kind == this.kind &&
          other.lastChapter == this.lastChapter &&
          other.wordCount == this.wordCount);
}

class RuleExploresCompanion extends UpdateCompanion<RuleExplore> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String?> bookList;
  final Value<String?> name;
  final Value<String?> author;
  final Value<String?> bookUrl;
  final Value<String?> coverUrl;
  final Value<String?> intro;
  final Value<String?> kind;
  final Value<String?> lastChapter;
  final Value<String?> wordCount;
  const RuleExploresCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.bookList = const Value.absent(),
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.bookUrl = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.intro = const Value.absent(),
    this.kind = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.wordCount = const Value.absent(),
  });
  RuleExploresCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    this.bookList = const Value.absent(),
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.bookUrl = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.intro = const Value.absent(),
    this.kind = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.wordCount = const Value.absent(),
  }) : bookSourceId = Value(bookSourceId);
  static Insertable<RuleExplore> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? bookList,
    Expression<String>? name,
    Expression<String>? author,
    Expression<String>? bookUrl,
    Expression<String>? coverUrl,
    Expression<String>? intro,
    Expression<String>? kind,
    Expression<String>? lastChapter,
    Expression<String>? wordCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (bookList != null) 'book_list': bookList,
      if (name != null) 'name': name,
      if (author != null) 'author': author,
      if (bookUrl != null) 'book_url': bookUrl,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (intro != null) 'intro': intro,
      if (kind != null) 'kind': kind,
      if (lastChapter != null) 'last_chapter': lastChapter,
      if (wordCount != null) 'word_count': wordCount,
    });
  }

  RuleExploresCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String?>? bookList,
      Value<String?>? name,
      Value<String?>? author,
      Value<String?>? bookUrl,
      Value<String?>? coverUrl,
      Value<String?>? intro,
      Value<String?>? kind,
      Value<String?>? lastChapter,
      Value<String?>? wordCount}) {
    return RuleExploresCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      bookList: bookList ?? this.bookList,
      name: name ?? this.name,
      author: author ?? this.author,
      bookUrl: bookUrl ?? this.bookUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      intro: intro ?? this.intro,
      kind: kind ?? this.kind,
      lastChapter: lastChapter ?? this.lastChapter,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (bookList.present) {
      map['book_list'] = Variable<String>(bookList.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (bookUrl.present) {
      map['book_url'] = Variable<String>(bookUrl.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (intro.present) {
      map['intro'] = Variable<String>(intro.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (lastChapter.present) {
      map['last_chapter'] = Variable<String>(lastChapter.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<String>(wordCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RuleExploresCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookList: $bookList, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('bookUrl: $bookUrl, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('intro: $intro, ')
          ..write('kind: $kind, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('wordCount: $wordCount')
          ..write(')'))
        .toString();
  }
}

class $BookReadSettingsTable extends BookReadSettings
    with TableInfo<$BookReadSettingsTable, BookReadSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookReadSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _updateTimeMeta =
      const VerificationMeta('updateTime');
  @override
  late final GeneratedColumn<DateTime> updateTime = GeneratedColumn<DateTime>(
      'update_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fontSizeMeta =
      const VerificationMeta('fontSize');
  @override
  late final GeneratedColumn<double> fontSize = GeneratedColumn<double>(
      'font_size', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fontHeightMeta =
      const VerificationMeta('fontHeight');
  @override
  late final GeneratedColumn<double> fontHeight = GeneratedColumn<double>(
      'font_height', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _wordSpacingMeta =
      const VerificationMeta('wordSpacing');
  @override
  late final GeneratedColumn<double> wordSpacing = GeneratedColumn<double>(
      'word_spacing', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _letterSpacingMeta =
      const VerificationMeta('letterSpacing');
  @override
  late final GeneratedColumn<double> letterSpacing = GeneratedColumn<double>(
      'letter_spacing', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fontFamilyMeta =
      const VerificationMeta('fontFamily');
  @override
  late final GeneratedColumn<String> fontFamily = GeneratedColumn<String>(
      'font_family', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _brightnessMeta =
      const VerificationMeta('brightness');
  @override
  late final GeneratedColumn<double> brightness = GeneratedColumn<double>(
      'brightness', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _backgroundColorMeta =
      const VerificationMeta('backgroundColor');
  @override
  late final GeneratedColumn<int> backgroundColor = GeneratedColumn<int>(
      'background_color', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pageTurnTypeMeta =
      const VerificationMeta('pageTurnType');
  @override
  late final GeneratedColumn<String> pageTurnType = GeneratedColumn<String>(
      'page_turn_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isEyeProtectionModeMeta =
      const VerificationMeta('isEyeProtectionMode');
  @override
  late final GeneratedColumn<bool> isEyeProtectionMode = GeneratedColumn<bool>(
      'is_eye_protection_mode', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_eye_protection_mode" IN (0, 1))'));
  static const VerificationMeta _ttsRateMeta =
      const VerificationMeta('ttsRate');
  @override
  late final GeneratedColumn<double> ttsRate = GeneratedColumn<double>(
      'tts_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _ttsPitchMeta =
      const VerificationMeta('ttsPitch');
  @override
  late final GeneratedColumn<double> ttsPitch = GeneratedColumn<double>(
      'tts_pitch', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _ttsVolumeMeta =
      const VerificationMeta('ttsVolume');
  @override
  late final GeneratedColumn<double> ttsVolume = GeneratedColumn<double>(
      'tts_volume', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _ttsVoiceNameMeta =
      const VerificationMeta('ttsVoiceName');
  @override
  late final GeneratedColumn<String> ttsVoiceName = GeneratedColumn<String>(
      'tts_voice_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ttsAutoNextPageMeta =
      const VerificationMeta('ttsAutoNextPage');
  @override
  late final GeneratedColumn<bool> ttsAutoNextPage = GeneratedColumn<bool>(
      'tts_auto_next_page', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("tts_auto_next_page" IN (0, 1))'));
  static const VerificationMeta _ttsAutoNextChapterMeta =
      const VerificationMeta('ttsAutoNextChapter');
  @override
  late final GeneratedColumn<bool> ttsAutoNextChapter = GeneratedColumn<bool>(
      'tts_auto_next_chapter', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("tts_auto_next_chapter" IN (0, 1))'));
  static const VerificationMeta _ttsResumeAfterInterruptMeta =
      const VerificationMeta('ttsResumeAfterInterrupt');
  @override
  late final GeneratedColumn<bool> ttsResumeAfterInterrupt =
      GeneratedColumn<bool>('tts_resume_after_interrupt', aliasedName, true,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("tts_resume_after_interrupt" IN (0, 1))'));
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bookshelfLayoutMeta =
      const VerificationMeta('bookshelfLayout');
  @override
  late final GeneratedColumn<String> bookshelfLayout = GeneratedColumn<String>(
      'bookshelf_layout', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updateTime,
        fontSize,
        fontHeight,
        wordSpacing,
        letterSpacing,
        fontFamily,
        brightness,
        backgroundColor,
        pageTurnType,
        isEyeProtectionMode,
        ttsRate,
        ttsPitch,
        ttsVolume,
        ttsVoiceName,
        ttsAutoNextPage,
        ttsAutoNextChapter,
        ttsResumeAfterInterrupt,
        themeMode,
        bookshelfLayout
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_read_settings';
  @override
  VerificationContext validateIntegrity(Insertable<BookReadSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('update_time')) {
      context.handle(
          _updateTimeMeta,
          updateTime.isAcceptableOrUnknown(
              data['update_time']!, _updateTimeMeta));
    } else if (isInserting) {
      context.missing(_updateTimeMeta);
    }
    if (data.containsKey('font_size')) {
      context.handle(_fontSizeMeta,
          fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta));
    }
    if (data.containsKey('font_height')) {
      context.handle(
          _fontHeightMeta,
          fontHeight.isAcceptableOrUnknown(
              data['font_height']!, _fontHeightMeta));
    }
    if (data.containsKey('word_spacing')) {
      context.handle(
          _wordSpacingMeta,
          wordSpacing.isAcceptableOrUnknown(
              data['word_spacing']!, _wordSpacingMeta));
    }
    if (data.containsKey('letter_spacing')) {
      context.handle(
          _letterSpacingMeta,
          letterSpacing.isAcceptableOrUnknown(
              data['letter_spacing']!, _letterSpacingMeta));
    }
    if (data.containsKey('font_family')) {
      context.handle(
          _fontFamilyMeta,
          fontFamily.isAcceptableOrUnknown(
              data['font_family']!, _fontFamilyMeta));
    }
    if (data.containsKey('brightness')) {
      context.handle(
          _brightnessMeta,
          brightness.isAcceptableOrUnknown(
              data['brightness']!, _brightnessMeta));
    }
    if (data.containsKey('background_color')) {
      context.handle(
          _backgroundColorMeta,
          backgroundColor.isAcceptableOrUnknown(
              data['background_color']!, _backgroundColorMeta));
    }
    if (data.containsKey('page_turn_type')) {
      context.handle(
          _pageTurnTypeMeta,
          pageTurnType.isAcceptableOrUnknown(
              data['page_turn_type']!, _pageTurnTypeMeta));
    }
    if (data.containsKey('is_eye_protection_mode')) {
      context.handle(
          _isEyeProtectionModeMeta,
          isEyeProtectionMode.isAcceptableOrUnknown(
              data['is_eye_protection_mode']!, _isEyeProtectionModeMeta));
    }
    if (data.containsKey('tts_rate')) {
      context.handle(_ttsRateMeta,
          ttsRate.isAcceptableOrUnknown(data['tts_rate']!, _ttsRateMeta));
    }
    if (data.containsKey('tts_pitch')) {
      context.handle(_ttsPitchMeta,
          ttsPitch.isAcceptableOrUnknown(data['tts_pitch']!, _ttsPitchMeta));
    }
    if (data.containsKey('tts_volume')) {
      context.handle(_ttsVolumeMeta,
          ttsVolume.isAcceptableOrUnknown(data['tts_volume']!, _ttsVolumeMeta));
    }
    if (data.containsKey('tts_voice_name')) {
      context.handle(
          _ttsVoiceNameMeta,
          ttsVoiceName.isAcceptableOrUnknown(
              data['tts_voice_name']!, _ttsVoiceNameMeta));
    }
    if (data.containsKey('tts_auto_next_page')) {
      context.handle(
          _ttsAutoNextPageMeta,
          ttsAutoNextPage.isAcceptableOrUnknown(
              data['tts_auto_next_page']!, _ttsAutoNextPageMeta));
    }
    if (data.containsKey('tts_auto_next_chapter')) {
      context.handle(
          _ttsAutoNextChapterMeta,
          ttsAutoNextChapter.isAcceptableOrUnknown(
              data['tts_auto_next_chapter']!, _ttsAutoNextChapterMeta));
    }
    if (data.containsKey('tts_resume_after_interrupt')) {
      context.handle(
          _ttsResumeAfterInterruptMeta,
          ttsResumeAfterInterrupt.isAcceptableOrUnknown(
              data['tts_resume_after_interrupt']!,
              _ttsResumeAfterInterruptMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('bookshelf_layout')) {
      context.handle(
          _bookshelfLayoutMeta,
          bookshelfLayout.isAcceptableOrUnknown(
              data['bookshelf_layout']!, _bookshelfLayoutMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookReadSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookReadSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      updateTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_time'])!,
      fontSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}font_size']),
      fontHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}font_height']),
      wordSpacing: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}word_spacing']),
      letterSpacing: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}letter_spacing']),
      fontFamily: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}font_family']),
      brightness: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}brightness']),
      backgroundColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}background_color']),
      pageTurnType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}page_turn_type']),
      isEyeProtectionMode: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_eye_protection_mode']),
      ttsRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tts_rate']),
      ttsPitch: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tts_pitch']),
      ttsVolume: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tts_volume']),
      ttsVoiceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tts_voice_name']),
      ttsAutoNextPage: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}tts_auto_next_page']),
      ttsAutoNextChapter: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}tts_auto_next_chapter']),
      ttsResumeAfterInterrupt: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}tts_resume_after_interrupt']),
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode']),
      bookshelfLayout: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bookshelf_layout']),
    );
  }

  @override
  $BookReadSettingsTable createAlias(String alias) {
    return $BookReadSettingsTable(attachedDatabase, alias);
  }
}

class BookReadSetting extends DataClass implements Insertable<BookReadSetting> {
  final int id;
  final DateTime updateTime;
  final double? fontSize;
  final double? fontHeight;
  final double? wordSpacing;
  final double? letterSpacing;
  final String? fontFamily;
  final double? brightness;
  final int? backgroundColor;
  final String? pageTurnType;
  final bool? isEyeProtectionMode;
  final double? ttsRate;
  final double? ttsPitch;
  final double? ttsVolume;
  final String? ttsVoiceName;
  final bool? ttsAutoNextPage;
  final bool? ttsAutoNextChapter;
  final bool? ttsResumeAfterInterrupt;
  final String? themeMode;
  final String? bookshelfLayout;
  const BookReadSetting(
      {required this.id,
      required this.updateTime,
      this.fontSize,
      this.fontHeight,
      this.wordSpacing,
      this.letterSpacing,
      this.fontFamily,
      this.brightness,
      this.backgroundColor,
      this.pageTurnType,
      this.isEyeProtectionMode,
      this.ttsRate,
      this.ttsPitch,
      this.ttsVolume,
      this.ttsVoiceName,
      this.ttsAutoNextPage,
      this.ttsAutoNextChapter,
      this.ttsResumeAfterInterrupt,
      this.themeMode,
      this.bookshelfLayout});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['update_time'] = Variable<DateTime>(updateTime);
    if (!nullToAbsent || fontSize != null) {
      map['font_size'] = Variable<double>(fontSize);
    }
    if (!nullToAbsent || fontHeight != null) {
      map['font_height'] = Variable<double>(fontHeight);
    }
    if (!nullToAbsent || wordSpacing != null) {
      map['word_spacing'] = Variable<double>(wordSpacing);
    }
    if (!nullToAbsent || letterSpacing != null) {
      map['letter_spacing'] = Variable<double>(letterSpacing);
    }
    if (!nullToAbsent || fontFamily != null) {
      map['font_family'] = Variable<String>(fontFamily);
    }
    if (!nullToAbsent || brightness != null) {
      map['brightness'] = Variable<double>(brightness);
    }
    if (!nullToAbsent || backgroundColor != null) {
      map['background_color'] = Variable<int>(backgroundColor);
    }
    if (!nullToAbsent || pageTurnType != null) {
      map['page_turn_type'] = Variable<String>(pageTurnType);
    }
    if (!nullToAbsent || isEyeProtectionMode != null) {
      map['is_eye_protection_mode'] = Variable<bool>(isEyeProtectionMode);
    }
    if (!nullToAbsent || ttsRate != null) {
      map['tts_rate'] = Variable<double>(ttsRate);
    }
    if (!nullToAbsent || ttsPitch != null) {
      map['tts_pitch'] = Variable<double>(ttsPitch);
    }
    if (!nullToAbsent || ttsVolume != null) {
      map['tts_volume'] = Variable<double>(ttsVolume);
    }
    if (!nullToAbsent || ttsVoiceName != null) {
      map['tts_voice_name'] = Variable<String>(ttsVoiceName);
    }
    if (!nullToAbsent || ttsAutoNextPage != null) {
      map['tts_auto_next_page'] = Variable<bool>(ttsAutoNextPage);
    }
    if (!nullToAbsent || ttsAutoNextChapter != null) {
      map['tts_auto_next_chapter'] = Variable<bool>(ttsAutoNextChapter);
    }
    if (!nullToAbsent || ttsResumeAfterInterrupt != null) {
      map['tts_resume_after_interrupt'] =
          Variable<bool>(ttsResumeAfterInterrupt);
    }
    if (!nullToAbsent || themeMode != null) {
      map['theme_mode'] = Variable<String>(themeMode);
    }
    if (!nullToAbsent || bookshelfLayout != null) {
      map['bookshelf_layout'] = Variable<String>(bookshelfLayout);
    }
    return map;
  }

  BookReadSettingsCompanion toCompanion(bool nullToAbsent) {
    return BookReadSettingsCompanion(
      id: Value(id),
      updateTime: Value(updateTime),
      fontSize: fontSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fontSize),
      fontHeight: fontHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(fontHeight),
      wordSpacing: wordSpacing == null && nullToAbsent
          ? const Value.absent()
          : Value(wordSpacing),
      letterSpacing: letterSpacing == null && nullToAbsent
          ? const Value.absent()
          : Value(letterSpacing),
      fontFamily: fontFamily == null && nullToAbsent
          ? const Value.absent()
          : Value(fontFamily),
      brightness: brightness == null && nullToAbsent
          ? const Value.absent()
          : Value(brightness),
      backgroundColor: backgroundColor == null && nullToAbsent
          ? const Value.absent()
          : Value(backgroundColor),
      pageTurnType: pageTurnType == null && nullToAbsent
          ? const Value.absent()
          : Value(pageTurnType),
      isEyeProtectionMode: isEyeProtectionMode == null && nullToAbsent
          ? const Value.absent()
          : Value(isEyeProtectionMode),
      ttsRate: ttsRate == null && nullToAbsent
          ? const Value.absent()
          : Value(ttsRate),
      ttsPitch: ttsPitch == null && nullToAbsent
          ? const Value.absent()
          : Value(ttsPitch),
      ttsVolume: ttsVolume == null && nullToAbsent
          ? const Value.absent()
          : Value(ttsVolume),
      ttsVoiceName: ttsVoiceName == null && nullToAbsent
          ? const Value.absent()
          : Value(ttsVoiceName),
      ttsAutoNextPage: ttsAutoNextPage == null && nullToAbsent
          ? const Value.absent()
          : Value(ttsAutoNextPage),
      ttsAutoNextChapter: ttsAutoNextChapter == null && nullToAbsent
          ? const Value.absent()
          : Value(ttsAutoNextChapter),
      ttsResumeAfterInterrupt: ttsResumeAfterInterrupt == null && nullToAbsent
          ? const Value.absent()
          : Value(ttsResumeAfterInterrupt),
      themeMode: themeMode == null && nullToAbsent
          ? const Value.absent()
          : Value(themeMode),
      bookshelfLayout: bookshelfLayout == null && nullToAbsent
          ? const Value.absent()
          : Value(bookshelfLayout),
    );
  }

  factory BookReadSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookReadSetting(
      id: serializer.fromJson<int>(json['id']),
      updateTime: serializer.fromJson<DateTime>(json['updateTime']),
      fontSize: serializer.fromJson<double?>(json['fontSize']),
      fontHeight: serializer.fromJson<double?>(json['fontHeight']),
      wordSpacing: serializer.fromJson<double?>(json['wordSpacing']),
      letterSpacing: serializer.fromJson<double?>(json['letterSpacing']),
      fontFamily: serializer.fromJson<String?>(json['fontFamily']),
      brightness: serializer.fromJson<double?>(json['brightness']),
      backgroundColor: serializer.fromJson<int?>(json['backgroundColor']),
      pageTurnType: serializer.fromJson<String?>(json['pageTurnType']),
      isEyeProtectionMode:
          serializer.fromJson<bool?>(json['isEyeProtectionMode']),
      ttsRate: serializer.fromJson<double?>(json['ttsRate']),
      ttsPitch: serializer.fromJson<double?>(json['ttsPitch']),
      ttsVolume: serializer.fromJson<double?>(json['ttsVolume']),
      ttsVoiceName: serializer.fromJson<String?>(json['ttsVoiceName']),
      ttsAutoNextPage: serializer.fromJson<bool?>(json['ttsAutoNextPage']),
      ttsAutoNextChapter:
          serializer.fromJson<bool?>(json['ttsAutoNextChapter']),
      ttsResumeAfterInterrupt:
          serializer.fromJson<bool?>(json['ttsResumeAfterInterrupt']),
      themeMode: serializer.fromJson<String?>(json['themeMode']),
      bookshelfLayout: serializer.fromJson<String?>(json['bookshelfLayout']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'updateTime': serializer.toJson<DateTime>(updateTime),
      'fontSize': serializer.toJson<double?>(fontSize),
      'fontHeight': serializer.toJson<double?>(fontHeight),
      'wordSpacing': serializer.toJson<double?>(wordSpacing),
      'letterSpacing': serializer.toJson<double?>(letterSpacing),
      'fontFamily': serializer.toJson<String?>(fontFamily),
      'brightness': serializer.toJson<double?>(brightness),
      'backgroundColor': serializer.toJson<int?>(backgroundColor),
      'pageTurnType': serializer.toJson<String?>(pageTurnType),
      'isEyeProtectionMode': serializer.toJson<bool?>(isEyeProtectionMode),
      'ttsRate': serializer.toJson<double?>(ttsRate),
      'ttsPitch': serializer.toJson<double?>(ttsPitch),
      'ttsVolume': serializer.toJson<double?>(ttsVolume),
      'ttsVoiceName': serializer.toJson<String?>(ttsVoiceName),
      'ttsAutoNextPage': serializer.toJson<bool?>(ttsAutoNextPage),
      'ttsAutoNextChapter': serializer.toJson<bool?>(ttsAutoNextChapter),
      'ttsResumeAfterInterrupt':
          serializer.toJson<bool?>(ttsResumeAfterInterrupt),
      'themeMode': serializer.toJson<String?>(themeMode),
      'bookshelfLayout': serializer.toJson<String?>(bookshelfLayout),
    };
  }

  BookReadSetting copyWith(
          {int? id,
          DateTime? updateTime,
          Value<double?> fontSize = const Value.absent(),
          Value<double?> fontHeight = const Value.absent(),
          Value<double?> wordSpacing = const Value.absent(),
          Value<double?> letterSpacing = const Value.absent(),
          Value<String?> fontFamily = const Value.absent(),
          Value<double?> brightness = const Value.absent(),
          Value<int?> backgroundColor = const Value.absent(),
          Value<String?> pageTurnType = const Value.absent(),
          Value<bool?> isEyeProtectionMode = const Value.absent(),
          Value<double?> ttsRate = const Value.absent(),
          Value<double?> ttsPitch = const Value.absent(),
          Value<double?> ttsVolume = const Value.absent(),
          Value<String?> ttsVoiceName = const Value.absent(),
          Value<bool?> ttsAutoNextPage = const Value.absent(),
          Value<bool?> ttsAutoNextChapter = const Value.absent(),
          Value<bool?> ttsResumeAfterInterrupt = const Value.absent(),
          Value<String?> themeMode = const Value.absent(),
          Value<String?> bookshelfLayout = const Value.absent()}) =>
      BookReadSetting(
        id: id ?? this.id,
        updateTime: updateTime ?? this.updateTime,
        fontSize: fontSize.present ? fontSize.value : this.fontSize,
        fontHeight: fontHeight.present ? fontHeight.value : this.fontHeight,
        wordSpacing: wordSpacing.present ? wordSpacing.value : this.wordSpacing,
        letterSpacing:
            letterSpacing.present ? letterSpacing.value : this.letterSpacing,
        fontFamily: fontFamily.present ? fontFamily.value : this.fontFamily,
        brightness: brightness.present ? brightness.value : this.brightness,
        backgroundColor: backgroundColor.present
            ? backgroundColor.value
            : this.backgroundColor,
        pageTurnType:
            pageTurnType.present ? pageTurnType.value : this.pageTurnType,
        isEyeProtectionMode: isEyeProtectionMode.present
            ? isEyeProtectionMode.value
            : this.isEyeProtectionMode,
        ttsRate: ttsRate.present ? ttsRate.value : this.ttsRate,
        ttsPitch: ttsPitch.present ? ttsPitch.value : this.ttsPitch,
        ttsVolume: ttsVolume.present ? ttsVolume.value : this.ttsVolume,
        ttsVoiceName:
            ttsVoiceName.present ? ttsVoiceName.value : this.ttsVoiceName,
        ttsAutoNextPage: ttsAutoNextPage.present
            ? ttsAutoNextPage.value
            : this.ttsAutoNextPage,
        ttsAutoNextChapter: ttsAutoNextChapter.present
            ? ttsAutoNextChapter.value
            : this.ttsAutoNextChapter,
        ttsResumeAfterInterrupt: ttsResumeAfterInterrupt.present
            ? ttsResumeAfterInterrupt.value
            : this.ttsResumeAfterInterrupt,
        themeMode: themeMode.present ? themeMode.value : this.themeMode,
        bookshelfLayout: bookshelfLayout.present
            ? bookshelfLayout.value
            : this.bookshelfLayout,
      );
  BookReadSetting copyWithCompanion(BookReadSettingsCompanion data) {
    return BookReadSetting(
      id: data.id.present ? data.id.value : this.id,
      updateTime:
          data.updateTime.present ? data.updateTime.value : this.updateTime,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      fontHeight:
          data.fontHeight.present ? data.fontHeight.value : this.fontHeight,
      wordSpacing:
          data.wordSpacing.present ? data.wordSpacing.value : this.wordSpacing,
      letterSpacing: data.letterSpacing.present
          ? data.letterSpacing.value
          : this.letterSpacing,
      fontFamily:
          data.fontFamily.present ? data.fontFamily.value : this.fontFamily,
      brightness:
          data.brightness.present ? data.brightness.value : this.brightness,
      backgroundColor: data.backgroundColor.present
          ? data.backgroundColor.value
          : this.backgroundColor,
      pageTurnType: data.pageTurnType.present
          ? data.pageTurnType.value
          : this.pageTurnType,
      isEyeProtectionMode: data.isEyeProtectionMode.present
          ? data.isEyeProtectionMode.value
          : this.isEyeProtectionMode,
      ttsRate: data.ttsRate.present ? data.ttsRate.value : this.ttsRate,
      ttsPitch: data.ttsPitch.present ? data.ttsPitch.value : this.ttsPitch,
      ttsVolume: data.ttsVolume.present ? data.ttsVolume.value : this.ttsVolume,
      ttsVoiceName: data.ttsVoiceName.present
          ? data.ttsVoiceName.value
          : this.ttsVoiceName,
      ttsAutoNextPage: data.ttsAutoNextPage.present
          ? data.ttsAutoNextPage.value
          : this.ttsAutoNextPage,
      ttsAutoNextChapter: data.ttsAutoNextChapter.present
          ? data.ttsAutoNextChapter.value
          : this.ttsAutoNextChapter,
      ttsResumeAfterInterrupt: data.ttsResumeAfterInterrupt.present
          ? data.ttsResumeAfterInterrupt.value
          : this.ttsResumeAfterInterrupt,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      bookshelfLayout: data.bookshelfLayout.present
          ? data.bookshelfLayout.value
          : this.bookshelfLayout,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookReadSetting(')
          ..write('id: $id, ')
          ..write('updateTime: $updateTime, ')
          ..write('fontSize: $fontSize, ')
          ..write('fontHeight: $fontHeight, ')
          ..write('wordSpacing: $wordSpacing, ')
          ..write('letterSpacing: $letterSpacing, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('brightness: $brightness, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('pageTurnType: $pageTurnType, ')
          ..write('isEyeProtectionMode: $isEyeProtectionMode, ')
          ..write('ttsRate: $ttsRate, ')
          ..write('ttsPitch: $ttsPitch, ')
          ..write('ttsVolume: $ttsVolume, ')
          ..write('ttsVoiceName: $ttsVoiceName, ')
          ..write('ttsAutoNextPage: $ttsAutoNextPage, ')
          ..write('ttsAutoNextChapter: $ttsAutoNextChapter, ')
          ..write('ttsResumeAfterInterrupt: $ttsResumeAfterInterrupt, ')
          ..write('themeMode: $themeMode, ')
          ..write('bookshelfLayout: $bookshelfLayout')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      updateTime,
      fontSize,
      fontHeight,
      wordSpacing,
      letterSpacing,
      fontFamily,
      brightness,
      backgroundColor,
      pageTurnType,
      isEyeProtectionMode,
      ttsRate,
      ttsPitch,
      ttsVolume,
      ttsVoiceName,
      ttsAutoNextPage,
      ttsAutoNextChapter,
      ttsResumeAfterInterrupt,
      themeMode,
      bookshelfLayout);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookReadSetting &&
          other.id == this.id &&
          other.updateTime == this.updateTime &&
          other.fontSize == this.fontSize &&
          other.fontHeight == this.fontHeight &&
          other.wordSpacing == this.wordSpacing &&
          other.letterSpacing == this.letterSpacing &&
          other.fontFamily == this.fontFamily &&
          other.brightness == this.brightness &&
          other.backgroundColor == this.backgroundColor &&
          other.pageTurnType == this.pageTurnType &&
          other.isEyeProtectionMode == this.isEyeProtectionMode &&
          other.ttsRate == this.ttsRate &&
          other.ttsPitch == this.ttsPitch &&
          other.ttsVolume == this.ttsVolume &&
          other.ttsVoiceName == this.ttsVoiceName &&
          other.ttsAutoNextPage == this.ttsAutoNextPage &&
          other.ttsAutoNextChapter == this.ttsAutoNextChapter &&
          other.ttsResumeAfterInterrupt == this.ttsResumeAfterInterrupt &&
          other.themeMode == this.themeMode &&
          other.bookshelfLayout == this.bookshelfLayout);
}

class BookReadSettingsCompanion extends UpdateCompanion<BookReadSetting> {
  final Value<int> id;
  final Value<DateTime> updateTime;
  final Value<double?> fontSize;
  final Value<double?> fontHeight;
  final Value<double?> wordSpacing;
  final Value<double?> letterSpacing;
  final Value<String?> fontFamily;
  final Value<double?> brightness;
  final Value<int?> backgroundColor;
  final Value<String?> pageTurnType;
  final Value<bool?> isEyeProtectionMode;
  final Value<double?> ttsRate;
  final Value<double?> ttsPitch;
  final Value<double?> ttsVolume;
  final Value<String?> ttsVoiceName;
  final Value<bool?> ttsAutoNextPage;
  final Value<bool?> ttsAutoNextChapter;
  final Value<bool?> ttsResumeAfterInterrupt;
  final Value<String?> themeMode;
  final Value<String?> bookshelfLayout;
  const BookReadSettingsCompanion({
    this.id = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.fontHeight = const Value.absent(),
    this.wordSpacing = const Value.absent(),
    this.letterSpacing = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.brightness = const Value.absent(),
    this.backgroundColor = const Value.absent(),
    this.pageTurnType = const Value.absent(),
    this.isEyeProtectionMode = const Value.absent(),
    this.ttsRate = const Value.absent(),
    this.ttsPitch = const Value.absent(),
    this.ttsVolume = const Value.absent(),
    this.ttsVoiceName = const Value.absent(),
    this.ttsAutoNextPage = const Value.absent(),
    this.ttsAutoNextChapter = const Value.absent(),
    this.ttsResumeAfterInterrupt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.bookshelfLayout = const Value.absent(),
  });
  BookReadSettingsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime updateTime,
    this.fontSize = const Value.absent(),
    this.fontHeight = const Value.absent(),
    this.wordSpacing = const Value.absent(),
    this.letterSpacing = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.brightness = const Value.absent(),
    this.backgroundColor = const Value.absent(),
    this.pageTurnType = const Value.absent(),
    this.isEyeProtectionMode = const Value.absent(),
    this.ttsRate = const Value.absent(),
    this.ttsPitch = const Value.absent(),
    this.ttsVolume = const Value.absent(),
    this.ttsVoiceName = const Value.absent(),
    this.ttsAutoNextPage = const Value.absent(),
    this.ttsAutoNextChapter = const Value.absent(),
    this.ttsResumeAfterInterrupt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.bookshelfLayout = const Value.absent(),
  }) : updateTime = Value(updateTime);
  static Insertable<BookReadSetting> custom({
    Expression<int>? id,
    Expression<DateTime>? updateTime,
    Expression<double>? fontSize,
    Expression<double>? fontHeight,
    Expression<double>? wordSpacing,
    Expression<double>? letterSpacing,
    Expression<String>? fontFamily,
    Expression<double>? brightness,
    Expression<int>? backgroundColor,
    Expression<String>? pageTurnType,
    Expression<bool>? isEyeProtectionMode,
    Expression<double>? ttsRate,
    Expression<double>? ttsPitch,
    Expression<double>? ttsVolume,
    Expression<String>? ttsVoiceName,
    Expression<bool>? ttsAutoNextPage,
    Expression<bool>? ttsAutoNextChapter,
    Expression<bool>? ttsResumeAfterInterrupt,
    Expression<String>? themeMode,
    Expression<String>? bookshelfLayout,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updateTime != null) 'update_time': updateTime,
      if (fontSize != null) 'font_size': fontSize,
      if (fontHeight != null) 'font_height': fontHeight,
      if (wordSpacing != null) 'word_spacing': wordSpacing,
      if (letterSpacing != null) 'letter_spacing': letterSpacing,
      if (fontFamily != null) 'font_family': fontFamily,
      if (brightness != null) 'brightness': brightness,
      if (backgroundColor != null) 'background_color': backgroundColor,
      if (pageTurnType != null) 'page_turn_type': pageTurnType,
      if (isEyeProtectionMode != null)
        'is_eye_protection_mode': isEyeProtectionMode,
      if (ttsRate != null) 'tts_rate': ttsRate,
      if (ttsPitch != null) 'tts_pitch': ttsPitch,
      if (ttsVolume != null) 'tts_volume': ttsVolume,
      if (ttsVoiceName != null) 'tts_voice_name': ttsVoiceName,
      if (ttsAutoNextPage != null) 'tts_auto_next_page': ttsAutoNextPage,
      if (ttsAutoNextChapter != null)
        'tts_auto_next_chapter': ttsAutoNextChapter,
      if (ttsResumeAfterInterrupt != null)
        'tts_resume_after_interrupt': ttsResumeAfterInterrupt,
      if (themeMode != null) 'theme_mode': themeMode,
      if (bookshelfLayout != null) 'bookshelf_layout': bookshelfLayout,
    });
  }

  BookReadSettingsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? updateTime,
      Value<double?>? fontSize,
      Value<double?>? fontHeight,
      Value<double?>? wordSpacing,
      Value<double?>? letterSpacing,
      Value<String?>? fontFamily,
      Value<double?>? brightness,
      Value<int?>? backgroundColor,
      Value<String?>? pageTurnType,
      Value<bool?>? isEyeProtectionMode,
      Value<double?>? ttsRate,
      Value<double?>? ttsPitch,
      Value<double?>? ttsVolume,
      Value<String?>? ttsVoiceName,
      Value<bool?>? ttsAutoNextPage,
      Value<bool?>? ttsAutoNextChapter,
      Value<bool?>? ttsResumeAfterInterrupt,
      Value<String?>? themeMode,
      Value<String?>? bookshelfLayout}) {
    return BookReadSettingsCompanion(
      id: id ?? this.id,
      updateTime: updateTime ?? this.updateTime,
      fontSize: fontSize ?? this.fontSize,
      fontHeight: fontHeight ?? this.fontHeight,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      fontFamily: fontFamily ?? this.fontFamily,
      brightness: brightness ?? this.brightness,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pageTurnType: pageTurnType ?? this.pageTurnType,
      isEyeProtectionMode: isEyeProtectionMode ?? this.isEyeProtectionMode,
      ttsRate: ttsRate ?? this.ttsRate,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      ttsVolume: ttsVolume ?? this.ttsVolume,
      ttsVoiceName: ttsVoiceName ?? this.ttsVoiceName,
      ttsAutoNextPage: ttsAutoNextPage ?? this.ttsAutoNextPage,
      ttsAutoNextChapter: ttsAutoNextChapter ?? this.ttsAutoNextChapter,
      ttsResumeAfterInterrupt:
          ttsResumeAfterInterrupt ?? this.ttsResumeAfterInterrupt,
      themeMode: themeMode ?? this.themeMode,
      bookshelfLayout: bookshelfLayout ?? this.bookshelfLayout,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<DateTime>(updateTime.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<double>(fontSize.value);
    }
    if (fontHeight.present) {
      map['font_height'] = Variable<double>(fontHeight.value);
    }
    if (wordSpacing.present) {
      map['word_spacing'] = Variable<double>(wordSpacing.value);
    }
    if (letterSpacing.present) {
      map['letter_spacing'] = Variable<double>(letterSpacing.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(fontFamily.value);
    }
    if (brightness.present) {
      map['brightness'] = Variable<double>(brightness.value);
    }
    if (backgroundColor.present) {
      map['background_color'] = Variable<int>(backgroundColor.value);
    }
    if (pageTurnType.present) {
      map['page_turn_type'] = Variable<String>(pageTurnType.value);
    }
    if (isEyeProtectionMode.present) {
      map['is_eye_protection_mode'] = Variable<bool>(isEyeProtectionMode.value);
    }
    if (ttsRate.present) {
      map['tts_rate'] = Variable<double>(ttsRate.value);
    }
    if (ttsPitch.present) {
      map['tts_pitch'] = Variable<double>(ttsPitch.value);
    }
    if (ttsVolume.present) {
      map['tts_volume'] = Variable<double>(ttsVolume.value);
    }
    if (ttsVoiceName.present) {
      map['tts_voice_name'] = Variable<String>(ttsVoiceName.value);
    }
    if (ttsAutoNextPage.present) {
      map['tts_auto_next_page'] = Variable<bool>(ttsAutoNextPage.value);
    }
    if (ttsAutoNextChapter.present) {
      map['tts_auto_next_chapter'] = Variable<bool>(ttsAutoNextChapter.value);
    }
    if (ttsResumeAfterInterrupt.present) {
      map['tts_resume_after_interrupt'] =
          Variable<bool>(ttsResumeAfterInterrupt.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (bookshelfLayout.present) {
      map['bookshelf_layout'] = Variable<String>(bookshelfLayout.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookReadSettingsCompanion(')
          ..write('id: $id, ')
          ..write('updateTime: $updateTime, ')
          ..write('fontSize: $fontSize, ')
          ..write('fontHeight: $fontHeight, ')
          ..write('wordSpacing: $wordSpacing, ')
          ..write('letterSpacing: $letterSpacing, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('brightness: $brightness, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('pageTurnType: $pageTurnType, ')
          ..write('isEyeProtectionMode: $isEyeProtectionMode, ')
          ..write('ttsRate: $ttsRate, ')
          ..write('ttsPitch: $ttsPitch, ')
          ..write('ttsVolume: $ttsVolume, ')
          ..write('ttsVoiceName: $ttsVoiceName, ')
          ..write('ttsAutoNextPage: $ttsAutoNextPage, ')
          ..write('ttsAutoNextChapter: $ttsAutoNextChapter, ')
          ..write('ttsResumeAfterInterrupt: $ttsResumeAfterInterrupt, ')
          ..write('themeMode: $themeMode, ')
          ..write('bookshelfLayout: $bookshelfLayout')
          ..write(')'))
        .toString();
  }
}

class $BookContentInfosTable extends BookContentInfos
    with TableInfo<$BookContentInfosTable, BookContentInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookContentInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterNameMeta =
      const VerificationMeta('chapterName');
  @override
  late final GeneratedColumn<String> chapterName = GeneratedColumn<String>(
      'chapter_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookContentMeta =
      const VerificationMeta('bookContent');
  @override
  late final GeneratedColumn<String> bookContent = GeneratedColumn<String>(
      'book_content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookSourceId, name, chapterName, chapterIndex, bookContent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_content_infos';
  @override
  VerificationContext validateIntegrity(Insertable<BookContentInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('chapter_name')) {
      context.handle(
          _chapterNameMeta,
          chapterName.isAcceptableOrUnknown(
              data['chapter_name']!, _chapterNameMeta));
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    }
    if (data.containsKey('book_content')) {
      context.handle(
          _bookContentMeta,
          bookContent.isAcceptableOrUnknown(
              data['book_content']!, _bookContentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookContentInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookContentInfo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      chapterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_name']),
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index']),
      bookContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_content']),
    );
  }

  @override
  $BookContentInfosTable createAlias(String alias) {
    return $BookContentInfosTable(attachedDatabase, alias);
  }
}

class BookContentInfo extends DataClass implements Insertable<BookContentInfo> {
  final int id;
  final int bookSourceId;
  final String? name;
  final String? chapterName;
  final int? chapterIndex;
  final String? bookContent;
  const BookContentInfo(
      {required this.id,
      required this.bookSourceId,
      this.name,
      this.chapterName,
      this.chapterIndex,
      this.bookContent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || chapterName != null) {
      map['chapter_name'] = Variable<String>(chapterName);
    }
    if (!nullToAbsent || chapterIndex != null) {
      map['chapter_index'] = Variable<int>(chapterIndex);
    }
    if (!nullToAbsent || bookContent != null) {
      map['book_content'] = Variable<String>(bookContent);
    }
    return map;
  }

  BookContentInfosCompanion toCompanion(bool nullToAbsent) {
    return BookContentInfosCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      chapterName: chapterName == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterName),
      chapterIndex: chapterIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterIndex),
      bookContent: bookContent == null && nullToAbsent
          ? const Value.absent()
          : Value(bookContent),
    );
  }

  factory BookContentInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookContentInfo(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      name: serializer.fromJson<String?>(json['name']),
      chapterName: serializer.fromJson<String?>(json['chapterName']),
      chapterIndex: serializer.fromJson<int?>(json['chapterIndex']),
      bookContent: serializer.fromJson<String?>(json['bookContent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'name': serializer.toJson<String?>(name),
      'chapterName': serializer.toJson<String?>(chapterName),
      'chapterIndex': serializer.toJson<int?>(chapterIndex),
      'bookContent': serializer.toJson<String?>(bookContent),
    };
  }

  BookContentInfo copyWith(
          {int? id,
          int? bookSourceId,
          Value<String?> name = const Value.absent(),
          Value<String?> chapterName = const Value.absent(),
          Value<int?> chapterIndex = const Value.absent(),
          Value<String?> bookContent = const Value.absent()}) =>
      BookContentInfo(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        name: name.present ? name.value : this.name,
        chapterName: chapterName.present ? chapterName.value : this.chapterName,
        chapterIndex:
            chapterIndex.present ? chapterIndex.value : this.chapterIndex,
        bookContent: bookContent.present ? bookContent.value : this.bookContent,
      );
  BookContentInfo copyWithCompanion(BookContentInfosCompanion data) {
    return BookContentInfo(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      name: data.name.present ? data.name.value : this.name,
      chapterName:
          data.chapterName.present ? data.chapterName.value : this.chapterName,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      bookContent:
          data.bookContent.present ? data.bookContent.value : this.bookContent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookContentInfo(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('name: $name, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('bookContent: $bookContent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, bookSourceId, name, chapterName, chapterIndex, bookContent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookContentInfo &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.name == this.name &&
          other.chapterName == this.chapterName &&
          other.chapterIndex == this.chapterIndex &&
          other.bookContent == this.bookContent);
}

class BookContentInfosCompanion extends UpdateCompanion<BookContentInfo> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String?> name;
  final Value<String?> chapterName;
  final Value<int?> chapterIndex;
  final Value<String?> bookContent;
  const BookContentInfosCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.bookContent = const Value.absent(),
  });
  BookContentInfosCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    this.name = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.bookContent = const Value.absent(),
  }) : bookSourceId = Value(bookSourceId);
  static Insertable<BookContentInfo> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? name,
    Expression<String>? chapterName,
    Expression<int>? chapterIndex,
    Expression<String>? bookContent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (name != null) 'name': name,
      if (chapterName != null) 'chapter_name': chapterName,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (bookContent != null) 'book_content': bookContent,
    });
  }

  BookContentInfosCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String?>? name,
      Value<String?>? chapterName,
      Value<int?>? chapterIndex,
      Value<String?>? bookContent}) {
    return BookContentInfosCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      name: name ?? this.name,
      chapterName: chapterName ?? this.chapterName,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      bookContent: bookContent ?? this.bookContent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (chapterName.present) {
      map['chapter_name'] = Variable<String>(chapterName.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (bookContent.present) {
      map['book_content'] = Variable<String>(bookContent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookContentInfosCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('name: $name, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('bookContent: $bookContent')
          ..write(')'))
        .toString();
  }
}

class $BookSearchInfosTable extends BookSearchInfos
    with TableInfo<$BookSearchInfosTable, BookSearchInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookSearchInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _searchUrlMeta =
      const VerificationMeta('searchUrl');
  @override
  late final GeneratedColumn<String> searchUrl = GeneratedColumn<String>(
      'search_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _charsetMeta =
      const VerificationMeta('charset');
  @override
  late final GeneratedColumn<String> charset = GeneratedColumn<String>(
      'charset', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _headersMeta =
      const VerificationMeta('headers');
  @override
  late final GeneratedColumn<String> headers = GeneratedColumn<String>(
      'headers', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookSourceId, searchUrl, method, charset, headers, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_search_infos';
  @override
  VerificationContext validateIntegrity(Insertable<BookSearchInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('search_url')) {
      context.handle(_searchUrlMeta,
          searchUrl.isAcceptableOrUnknown(data['search_url']!, _searchUrlMeta));
    } else if (isInserting) {
      context.missing(_searchUrlMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('charset')) {
      context.handle(_charsetMeta,
          charset.isAcceptableOrUnknown(data['charset']!, _charsetMeta));
    } else if (isInserting) {
      context.missing(_charsetMeta);
    }
    if (data.containsKey('headers')) {
      context.handle(_headersMeta,
          headers.isAcceptableOrUnknown(data['headers']!, _headersMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookSearchInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookSearchInfo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      searchUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_url'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      charset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}charset'])!,
      headers: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}headers']),
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
    );
  }

  @override
  $BookSearchInfosTable createAlias(String alias) {
    return $BookSearchInfosTable(attachedDatabase, alias);
  }
}

class BookSearchInfo extends DataClass implements Insertable<BookSearchInfo> {
  final int id;
  final int bookSourceId;
  final String searchUrl;
  final String method;
  final String charset;
  final String? headers;
  final String? body;
  const BookSearchInfo(
      {required this.id,
      required this.bookSourceId,
      required this.searchUrl,
      required this.method,
      required this.charset,
      this.headers,
      this.body});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    map['search_url'] = Variable<String>(searchUrl);
    map['method'] = Variable<String>(method);
    map['charset'] = Variable<String>(charset);
    if (!nullToAbsent || headers != null) {
      map['headers'] = Variable<String>(headers);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    return map;
  }

  BookSearchInfosCompanion toCompanion(bool nullToAbsent) {
    return BookSearchInfosCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      searchUrl: Value(searchUrl),
      method: Value(method),
      charset: Value(charset),
      headers: headers == null && nullToAbsent
          ? const Value.absent()
          : Value(headers),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
    );
  }

  factory BookSearchInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookSearchInfo(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      searchUrl: serializer.fromJson<String>(json['searchUrl']),
      method: serializer.fromJson<String>(json['method']),
      charset: serializer.fromJson<String>(json['charset']),
      headers: serializer.fromJson<String?>(json['headers']),
      body: serializer.fromJson<String?>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'searchUrl': serializer.toJson<String>(searchUrl),
      'method': serializer.toJson<String>(method),
      'charset': serializer.toJson<String>(charset),
      'headers': serializer.toJson<String?>(headers),
      'body': serializer.toJson<String?>(body),
    };
  }

  BookSearchInfo copyWith(
          {int? id,
          int? bookSourceId,
          String? searchUrl,
          String? method,
          String? charset,
          Value<String?> headers = const Value.absent(),
          Value<String?> body = const Value.absent()}) =>
      BookSearchInfo(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        searchUrl: searchUrl ?? this.searchUrl,
        method: method ?? this.method,
        charset: charset ?? this.charset,
        headers: headers.present ? headers.value : this.headers,
        body: body.present ? body.value : this.body,
      );
  BookSearchInfo copyWithCompanion(BookSearchInfosCompanion data) {
    return BookSearchInfo(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      searchUrl: data.searchUrl.present ? data.searchUrl.value : this.searchUrl,
      method: data.method.present ? data.method.value : this.method,
      charset: data.charset.present ? data.charset.value : this.charset,
      headers: data.headers.present ? data.headers.value : this.headers,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookSearchInfo(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('searchUrl: $searchUrl, ')
          ..write('method: $method, ')
          ..write('charset: $charset, ')
          ..write('headers: $headers, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookSourceId, searchUrl, method, charset, headers, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookSearchInfo &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.searchUrl == this.searchUrl &&
          other.method == this.method &&
          other.charset == this.charset &&
          other.headers == this.headers &&
          other.body == this.body);
}

class BookSearchInfosCompanion extends UpdateCompanion<BookSearchInfo> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String> searchUrl;
  final Value<String> method;
  final Value<String> charset;
  final Value<String?> headers;
  final Value<String?> body;
  const BookSearchInfosCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.searchUrl = const Value.absent(),
    this.method = const Value.absent(),
    this.charset = const Value.absent(),
    this.headers = const Value.absent(),
    this.body = const Value.absent(),
  });
  BookSearchInfosCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    required String searchUrl,
    required String method,
    required String charset,
    this.headers = const Value.absent(),
    this.body = const Value.absent(),
  })  : bookSourceId = Value(bookSourceId),
        searchUrl = Value(searchUrl),
        method = Value(method),
        charset = Value(charset);
  static Insertable<BookSearchInfo> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? searchUrl,
    Expression<String>? method,
    Expression<String>? charset,
    Expression<String>? headers,
    Expression<String>? body,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (searchUrl != null) 'search_url': searchUrl,
      if (method != null) 'method': method,
      if (charset != null) 'charset': charset,
      if (headers != null) 'headers': headers,
      if (body != null) 'body': body,
    });
  }

  BookSearchInfosCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String>? searchUrl,
      Value<String>? method,
      Value<String>? charset,
      Value<String?>? headers,
      Value<String?>? body}) {
    return BookSearchInfosCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      searchUrl: searchUrl ?? this.searchUrl,
      method: method ?? this.method,
      charset: charset ?? this.charset,
      headers: headers ?? this.headers,
      body: body ?? this.body,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (searchUrl.present) {
      map['search_url'] = Variable<String>(searchUrl.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (charset.present) {
      map['charset'] = Variable<String>(charset.value);
    }
    if (headers.present) {
      map['headers'] = Variable<String>(headers.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookSearchInfosCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('searchUrl: $searchUrl, ')
          ..write('method: $method, ')
          ..write('charset: $charset, ')
          ..write('headers: $headers, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }
}

class $BookReadProgressesTable extends BookReadProgresses
    with TableInfo<$BookReadProgressesTable, BookReadProgressesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookReadProgressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bookNameMeta =
      const VerificationMeta('bookName');
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
      'book_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNameMeta =
      const VerificationMeta('chapterName');
  @override
  late final GeneratedColumn<String> chapterName = GeneratedColumn<String>(
      'chapter_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _locatorJsonMeta =
      const VerificationMeta('locatorJson');
  @override
  late final GeneratedColumn<String> locatorJson = GeneratedColumn<String>(
      'locator_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updateTimeMeta =
      const VerificationMeta('updateTime');
  @override
  late final GeneratedColumn<DateTime> updateTime = GeneratedColumn<DateTime>(
      'update_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        bookName,
        chapterName,
        chapterIndex,
        locatorJson,
        updateTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_read_progresses';
  @override
  VerificationContext validateIntegrity(
      Insertable<BookReadProgressesData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(_bookNameMeta,
          bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta));
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('chapter_name')) {
      context.handle(
          _chapterNameMeta,
          chapterName.isAcceptableOrUnknown(
              data['chapter_name']!, _chapterNameMeta));
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('locator_json')) {
      context.handle(
          _locatorJsonMeta,
          locatorJson.isAcceptableOrUnknown(
              data['locator_json']!, _locatorJsonMeta));
    } else if (isInserting) {
      context.missing(_locatorJsonMeta);
    }
    if (data.containsKey('update_time')) {
      context.handle(
          _updateTimeMeta,
          updateTime.isAcceptableOrUnknown(
              data['update_time']!, _updateTimeMeta));
    } else if (isInserting) {
      context.missing(_updateTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookReadProgressesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookReadProgressesData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      bookName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_name'])!,
      chapterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_name']),
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index'])!,
      locatorJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locator_json'])!,
      updateTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_time'])!,
    );
  }

  @override
  $BookReadProgressesTable createAlias(String alias) {
    return $BookReadProgressesTable(attachedDatabase, alias);
  }
}

class BookReadProgressesData extends DataClass
    implements Insertable<BookReadProgressesData> {
  final int id;
  final int bookSourceId;
  final String bookName;
  final String? chapterName;
  final int chapterIndex;
  final String locatorJson;
  final DateTime updateTime;
  const BookReadProgressesData(
      {required this.id,
      required this.bookSourceId,
      required this.bookName,
      this.chapterName,
      required this.chapterIndex,
      required this.locatorJson,
      required this.updateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    map['book_name'] = Variable<String>(bookName);
    if (!nullToAbsent || chapterName != null) {
      map['chapter_name'] = Variable<String>(chapterName);
    }
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['locator_json'] = Variable<String>(locatorJson);
    map['update_time'] = Variable<DateTime>(updateTime);
    return map;
  }

  BookReadProgressesCompanion toCompanion(bool nullToAbsent) {
    return BookReadProgressesCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      bookName: Value(bookName),
      chapterName: chapterName == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterName),
      chapterIndex: Value(chapterIndex),
      locatorJson: Value(locatorJson),
      updateTime: Value(updateTime),
    );
  }

  factory BookReadProgressesData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookReadProgressesData(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      bookName: serializer.fromJson<String>(json['bookName']),
      chapterName: serializer.fromJson<String?>(json['chapterName']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      locatorJson: serializer.fromJson<String>(json['locatorJson']),
      updateTime: serializer.fromJson<DateTime>(json['updateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'bookName': serializer.toJson<String>(bookName),
      'chapterName': serializer.toJson<String?>(chapterName),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'locatorJson': serializer.toJson<String>(locatorJson),
      'updateTime': serializer.toJson<DateTime>(updateTime),
    };
  }

  BookReadProgressesData copyWith(
          {int? id,
          int? bookSourceId,
          String? bookName,
          Value<String?> chapterName = const Value.absent(),
          int? chapterIndex,
          String? locatorJson,
          DateTime? updateTime}) =>
      BookReadProgressesData(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        bookName: bookName ?? this.bookName,
        chapterName: chapterName.present ? chapterName.value : this.chapterName,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        locatorJson: locatorJson ?? this.locatorJson,
        updateTime: updateTime ?? this.updateTime,
      );
  BookReadProgressesData copyWithCompanion(BookReadProgressesCompanion data) {
    return BookReadProgressesData(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      chapterName:
          data.chapterName.present ? data.chapterName.value : this.chapterName,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      locatorJson:
          data.locatorJson.present ? data.locatorJson.value : this.locatorJson,
      updateTime:
          data.updateTime.present ? data.updateTime.value : this.updateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookReadProgressesData(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookSourceId, bookName, chapterName,
      chapterIndex, locatorJson, updateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookReadProgressesData &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.bookName == this.bookName &&
          other.chapterName == this.chapterName &&
          other.chapterIndex == this.chapterIndex &&
          other.locatorJson == this.locatorJson &&
          other.updateTime == this.updateTime);
}

class BookReadProgressesCompanion
    extends UpdateCompanion<BookReadProgressesData> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String> bookName;
  final Value<String?> chapterName;
  final Value<int> chapterIndex;
  final Value<String> locatorJson;
  final Value<DateTime> updateTime;
  const BookReadProgressesCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.bookName = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.locatorJson = const Value.absent(),
    this.updateTime = const Value.absent(),
  });
  BookReadProgressesCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    required String bookName,
    this.chapterName = const Value.absent(),
    required int chapterIndex,
    required String locatorJson,
    required DateTime updateTime,
  })  : bookSourceId = Value(bookSourceId),
        bookName = Value(bookName),
        chapterIndex = Value(chapterIndex),
        locatorJson = Value(locatorJson),
        updateTime = Value(updateTime);
  static Insertable<BookReadProgressesData> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? bookName,
    Expression<String>? chapterName,
    Expression<int>? chapterIndex,
    Expression<String>? locatorJson,
    Expression<DateTime>? updateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (bookName != null) 'book_name': bookName,
      if (chapterName != null) 'chapter_name': chapterName,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (locatorJson != null) 'locator_json': locatorJson,
      if (updateTime != null) 'update_time': updateTime,
    });
  }

  BookReadProgressesCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String>? bookName,
      Value<String?>? chapterName,
      Value<int>? chapterIndex,
      Value<String>? locatorJson,
      Value<DateTime>? updateTime}) {
    return BookReadProgressesCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      bookName: bookName ?? this.bookName,
      chapterName: chapterName ?? this.chapterName,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      locatorJson: locatorJson ?? this.locatorJson,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (chapterName.present) {
      map['chapter_name'] = Variable<String>(chapterName.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (locatorJson.present) {
      map['locator_json'] = Variable<String>(locatorJson.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<DateTime>(updateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookReadProgressesCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoriesTable extends SearchHistories
    with TableInfo<$SearchHistoriesTable, SearchHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keywordMeta =
      const VerificationMeta('keyword');
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
      'keyword', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _searchTimeMeta =
      const VerificationMeta('searchTime');
  @override
  late final GeneratedColumn<DateTime> searchTime = GeneratedColumn<DateTime>(
      'search_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, keyword, searchTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_histories';
  @override
  VerificationContext validateIntegrity(Insertable<SearchHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('keyword')) {
      context.handle(_keywordMeta,
          keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta));
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    if (data.containsKey('search_time')) {
      context.handle(
          _searchTimeMeta,
          searchTime.isAcceptableOrUnknown(
              data['search_time']!, _searchTimeMeta));
    } else if (isInserting) {
      context.missing(_searchTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      keyword: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}keyword'])!,
      searchTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}search_time'])!,
    );
  }

  @override
  $SearchHistoriesTable createAlias(String alias) {
    return $SearchHistoriesTable(attachedDatabase, alias);
  }
}

class SearchHistory extends DataClass implements Insertable<SearchHistory> {
  final int id;
  final String keyword;
  final DateTime searchTime;
  const SearchHistory(
      {required this.id, required this.keyword, required this.searchTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['keyword'] = Variable<String>(keyword);
    map['search_time'] = Variable<DateTime>(searchTime);
    return map;
  }

  SearchHistoriesCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoriesCompanion(
      id: Value(id),
      keyword: Value(keyword),
      searchTime: Value(searchTime),
    );
  }

  factory SearchHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistory(
      id: serializer.fromJson<int>(json['id']),
      keyword: serializer.fromJson<String>(json['keyword']),
      searchTime: serializer.fromJson<DateTime>(json['searchTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'keyword': serializer.toJson<String>(keyword),
      'searchTime': serializer.toJson<DateTime>(searchTime),
    };
  }

  SearchHistory copyWith({int? id, String? keyword, DateTime? searchTime}) =>
      SearchHistory(
        id: id ?? this.id,
        keyword: keyword ?? this.keyword,
        searchTime: searchTime ?? this.searchTime,
      );
  SearchHistory copyWithCompanion(SearchHistoriesCompanion data) {
    return SearchHistory(
      id: data.id.present ? data.id.value : this.id,
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
      searchTime:
          data.searchTime.present ? data.searchTime.value : this.searchTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistory(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('searchTime: $searchTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, keyword, searchTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistory &&
          other.id == this.id &&
          other.keyword == this.keyword &&
          other.searchTime == this.searchTime);
}

class SearchHistoriesCompanion extends UpdateCompanion<SearchHistory> {
  final Value<int> id;
  final Value<String> keyword;
  final Value<DateTime> searchTime;
  const SearchHistoriesCompanion({
    this.id = const Value.absent(),
    this.keyword = const Value.absent(),
    this.searchTime = const Value.absent(),
  });
  SearchHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required String keyword,
    required DateTime searchTime,
  })  : keyword = Value(keyword),
        searchTime = Value(searchTime);
  static Insertable<SearchHistory> custom({
    Expression<int>? id,
    Expression<String>? keyword,
    Expression<DateTime>? searchTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (keyword != null) 'keyword': keyword,
      if (searchTime != null) 'search_time': searchTime,
    });
  }

  SearchHistoriesCompanion copyWith(
      {Value<int>? id, Value<String>? keyword, Value<DateTime>? searchTime}) {
    return SearchHistoriesCompanion(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      searchTime: searchTime ?? this.searchTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (searchTime.present) {
      map['search_time'] = Variable<DateTime>(searchTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('searchTime: $searchTime')
          ..write(')'))
        .toString();
  }
}

class $BookReadHistoriesTable extends BookReadHistories
    with TableInfo<$BookReadHistoriesTable, BookReadHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookReadHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bookNameMeta =
      const VerificationMeta('bookName');
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
      'book_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNameMeta =
      const VerificationMeta('chapterName');
  @override
  late final GeneratedColumn<String> chapterName = GeneratedColumn<String>(
      'chapter_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookSourceId, bookName, chapterName, chapterIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_read_histories';
  @override
  VerificationContext validateIntegrity(Insertable<BookReadHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(_bookNameMeta,
          bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta));
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('chapter_name')) {
      context.handle(
          _chapterNameMeta,
          chapterName.isAcceptableOrUnknown(
              data['chapter_name']!, _chapterNameMeta));
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookReadHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookReadHistory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      bookName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_name'])!,
      chapterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_name']),
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index'])!,
    );
  }

  @override
  $BookReadHistoriesTable createAlias(String alias) {
    return $BookReadHistoriesTable(attachedDatabase, alias);
  }
}

class BookReadHistory extends DataClass implements Insertable<BookReadHistory> {
  final int id;
  final int bookSourceId;
  final String bookName;
  final String? chapterName;
  final int chapterIndex;
  const BookReadHistory(
      {required this.id,
      required this.bookSourceId,
      required this.bookName,
      this.chapterName,
      required this.chapterIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    map['book_name'] = Variable<String>(bookName);
    if (!nullToAbsent || chapterName != null) {
      map['chapter_name'] = Variable<String>(chapterName);
    }
    map['chapter_index'] = Variable<int>(chapterIndex);
    return map;
  }

  BookReadHistoriesCompanion toCompanion(bool nullToAbsent) {
    return BookReadHistoriesCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      bookName: Value(bookName),
      chapterName: chapterName == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterName),
      chapterIndex: Value(chapterIndex),
    );
  }

  factory BookReadHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookReadHistory(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      bookName: serializer.fromJson<String>(json['bookName']),
      chapterName: serializer.fromJson<String?>(json['chapterName']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'bookName': serializer.toJson<String>(bookName),
      'chapterName': serializer.toJson<String?>(chapterName),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
    };
  }

  BookReadHistory copyWith(
          {int? id,
          int? bookSourceId,
          String? bookName,
          Value<String?> chapterName = const Value.absent(),
          int? chapterIndex}) =>
      BookReadHistory(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        bookName: bookName ?? this.bookName,
        chapterName: chapterName.present ? chapterName.value : this.chapterName,
        chapterIndex: chapterIndex ?? this.chapterIndex,
      );
  BookReadHistory copyWithCompanion(BookReadHistoriesCompanion data) {
    return BookReadHistory(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      chapterName:
          data.chapterName.present ? data.chapterName.value : this.chapterName,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookReadHistory(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterIndex: $chapterIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookSourceId, bookName, chapterName, chapterIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookReadHistory &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.bookName == this.bookName &&
          other.chapterName == this.chapterName &&
          other.chapterIndex == this.chapterIndex);
}

class BookReadHistoriesCompanion extends UpdateCompanion<BookReadHistory> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String> bookName;
  final Value<String?> chapterName;
  final Value<int> chapterIndex;
  const BookReadHistoriesCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.bookName = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.chapterIndex = const Value.absent(),
  });
  BookReadHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    required String bookName,
    this.chapterName = const Value.absent(),
    required int chapterIndex,
  })  : bookSourceId = Value(bookSourceId),
        bookName = Value(bookName),
        chapterIndex = Value(chapterIndex);
  static Insertable<BookReadHistory> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? bookName,
    Expression<String>? chapterName,
    Expression<int>? chapterIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (bookName != null) 'book_name': bookName,
      if (chapterName != null) 'chapter_name': chapterName,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
    });
  }

  BookReadHistoriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String>? bookName,
      Value<String?>? chapterName,
      Value<int>? chapterIndex}) {
    return BookReadHistoriesCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      bookName: bookName ?? this.bookName,
      chapterName: chapterName ?? this.chapterName,
      chapterIndex: chapterIndex ?? this.chapterIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (chapterName.present) {
      map['chapter_name'] = Variable<String>(chapterName.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookReadHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterIndex: $chapterIndex')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bookUrlMeta =
      const VerificationMeta('bookUrl');
  @override
  late final GeneratedColumn<String> bookUrl = GeneratedColumn<String>(
      'book_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
      'cover', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _introMeta = const VerificationMeta('intro');
  @override
  late final GeneratedColumn<String> intro = GeneratedColumn<String>(
      'intro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wordCountMeta =
      const VerificationMeta('wordCount');
  @override
  late final GeneratedColumn<String> wordCount = GeneratedColumn<String>(
      'word_count', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastChapterMeta =
      const VerificationMeta('lastChapter');
  @override
  late final GeneratedColumn<String> lastChapter = GeneratedColumn<String>(
      'last_chapter', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalChapterNumMeta =
      const VerificationMeta('totalChapterNum');
  @override
  late final GeneratedColumn<int> totalChapterNum = GeneratedColumn<int>(
      'total_chapter_num', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _durChapterIndexMeta =
      const VerificationMeta('durChapterIndex');
  @override
  late final GeneratedColumn<int> durChapterIndex = GeneratedColumn<int>(
      'dur_chapter_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _durChapterPosMeta =
      const VerificationMeta('durChapterPos');
  @override
  late final GeneratedColumn<int> durChapterPos = GeneratedColumn<int>(
      'dur_chapter_pos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastReadTimeMeta =
      const VerificationMeta('lastReadTime');
  @override
  late final GeneratedColumn<DateTime> lastReadTime = GeneratedColumn<DateTime>(
      'last_read_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isAscendingMeta =
      const VerificationMeta('isAscending');
  @override
  late final GeneratedColumn<bool> isAscending = GeneratedColumn<bool>(
      'is_ascending', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_ascending" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _customOrderMeta =
      const VerificationMeta('customOrder');
  @override
  late final GeneratedColumn<int> customOrder = GeneratedColumn<int>(
      'custom_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bookGroupMeta =
      const VerificationMeta('bookGroup');
  @override
  late final GeneratedColumn<String> bookGroup = GeneratedColumn<String>(
      'book_group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        bookUrl,
        name,
        author,
        cover,
        intro,
        kind,
        wordCount,
        lastChapter,
        totalChapterNum,
        durChapterIndex,
        durChapterPos,
        lastReadTime,
        isAscending,
        customOrder,
        bookGroup
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(Insertable<Book> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('book_url')) {
      context.handle(_bookUrlMeta,
          bookUrl.isAcceptableOrUnknown(data['book_url']!, _bookUrlMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    }
    if (data.containsKey('intro')) {
      context.handle(
          _introMeta, intro.isAcceptableOrUnknown(data['intro']!, _introMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('word_count')) {
      context.handle(_wordCountMeta,
          wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta));
    }
    if (data.containsKey('last_chapter')) {
      context.handle(
          _lastChapterMeta,
          lastChapter.isAcceptableOrUnknown(
              data['last_chapter']!, _lastChapterMeta));
    }
    if (data.containsKey('total_chapter_num')) {
      context.handle(
          _totalChapterNumMeta,
          totalChapterNum.isAcceptableOrUnknown(
              data['total_chapter_num']!, _totalChapterNumMeta));
    }
    if (data.containsKey('dur_chapter_index')) {
      context.handle(
          _durChapterIndexMeta,
          durChapterIndex.isAcceptableOrUnknown(
              data['dur_chapter_index']!, _durChapterIndexMeta));
    }
    if (data.containsKey('dur_chapter_pos')) {
      context.handle(
          _durChapterPosMeta,
          durChapterPos.isAcceptableOrUnknown(
              data['dur_chapter_pos']!, _durChapterPosMeta));
    }
    if (data.containsKey('last_read_time')) {
      context.handle(
          _lastReadTimeMeta,
          lastReadTime.isAcceptableOrUnknown(
              data['last_read_time']!, _lastReadTimeMeta));
    }
    if (data.containsKey('is_ascending')) {
      context.handle(
          _isAscendingMeta,
          isAscending.isAcceptableOrUnknown(
              data['is_ascending']!, _isAscendingMeta));
    }
    if (data.containsKey('custom_order')) {
      context.handle(
          _customOrderMeta,
          customOrder.isAcceptableOrUnknown(
              data['custom_order']!, _customOrderMeta));
    }
    if (data.containsKey('book_group')) {
      context.handle(_bookGroupMeta,
          bookGroup.isAcceptableOrUnknown(data['book_group']!, _bookGroupMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      bookUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_url']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      cover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover']),
      intro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intro']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind']),
      wordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word_count']),
      lastChapter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_chapter']),
      totalChapterNum: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_chapter_num'])!,
      durChapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dur_chapter_index'])!,
      durChapterPos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dur_chapter_pos'])!,
      lastReadTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_read_time']),
      isAscending: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_ascending'])!,
      customOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}custom_order'])!,
      bookGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_group']),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final int bookSourceId;
  final String? bookUrl;
  final String name;
  final String? author;
  final String? cover;
  final String? intro;
  final String? kind;
  final String? wordCount;
  final String? lastChapter;
  final int totalChapterNum;
  final int durChapterIndex;
  final int durChapterPos;
  final DateTime? lastReadTime;
  final bool isAscending;
  final int customOrder;
  final String? bookGroup;
  const Book(
      {required this.id,
      required this.bookSourceId,
      this.bookUrl,
      required this.name,
      this.author,
      this.cover,
      this.intro,
      this.kind,
      this.wordCount,
      this.lastChapter,
      required this.totalChapterNum,
      required this.durChapterIndex,
      required this.durChapterPos,
      this.lastReadTime,
      required this.isAscending,
      required this.customOrder,
      this.bookGroup});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    if (!nullToAbsent || bookUrl != null) {
      map['book_url'] = Variable<String>(bookUrl);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<String>(cover);
    }
    if (!nullToAbsent || intro != null) {
      map['intro'] = Variable<String>(intro);
    }
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(kind);
    }
    if (!nullToAbsent || wordCount != null) {
      map['word_count'] = Variable<String>(wordCount);
    }
    if (!nullToAbsent || lastChapter != null) {
      map['last_chapter'] = Variable<String>(lastChapter);
    }
    map['total_chapter_num'] = Variable<int>(totalChapterNum);
    map['dur_chapter_index'] = Variable<int>(durChapterIndex);
    map['dur_chapter_pos'] = Variable<int>(durChapterPos);
    if (!nullToAbsent || lastReadTime != null) {
      map['last_read_time'] = Variable<DateTime>(lastReadTime);
    }
    map['is_ascending'] = Variable<bool>(isAscending);
    map['custom_order'] = Variable<int>(customOrder);
    if (!nullToAbsent || bookGroup != null) {
      map['book_group'] = Variable<String>(bookGroup);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      bookUrl: bookUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(bookUrl),
      name: Value(name),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      cover:
          cover == null && nullToAbsent ? const Value.absent() : Value(cover),
      intro:
          intro == null && nullToAbsent ? const Value.absent() : Value(intro),
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
      wordCount: wordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordCount),
      lastChapter: lastChapter == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChapter),
      totalChapterNum: Value(totalChapterNum),
      durChapterIndex: Value(durChapterIndex),
      durChapterPos: Value(durChapterPos),
      lastReadTime: lastReadTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadTime),
      isAscending: Value(isAscending),
      customOrder: Value(customOrder),
      bookGroup: bookGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(bookGroup),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      bookUrl: serializer.fromJson<String?>(json['bookUrl']),
      name: serializer.fromJson<String>(json['name']),
      author: serializer.fromJson<String?>(json['author']),
      cover: serializer.fromJson<String?>(json['cover']),
      intro: serializer.fromJson<String?>(json['intro']),
      kind: serializer.fromJson<String?>(json['kind']),
      wordCount: serializer.fromJson<String?>(json['wordCount']),
      lastChapter: serializer.fromJson<String?>(json['lastChapter']),
      totalChapterNum: serializer.fromJson<int>(json['totalChapterNum']),
      durChapterIndex: serializer.fromJson<int>(json['durChapterIndex']),
      durChapterPos: serializer.fromJson<int>(json['durChapterPos']),
      lastReadTime: serializer.fromJson<DateTime?>(json['lastReadTime']),
      isAscending: serializer.fromJson<bool>(json['isAscending']),
      customOrder: serializer.fromJson<int>(json['customOrder']),
      bookGroup: serializer.fromJson<String?>(json['bookGroup']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'bookUrl': serializer.toJson<String?>(bookUrl),
      'name': serializer.toJson<String>(name),
      'author': serializer.toJson<String?>(author),
      'cover': serializer.toJson<String?>(cover),
      'intro': serializer.toJson<String?>(intro),
      'kind': serializer.toJson<String?>(kind),
      'wordCount': serializer.toJson<String?>(wordCount),
      'lastChapter': serializer.toJson<String?>(lastChapter),
      'totalChapterNum': serializer.toJson<int>(totalChapterNum),
      'durChapterIndex': serializer.toJson<int>(durChapterIndex),
      'durChapterPos': serializer.toJson<int>(durChapterPos),
      'lastReadTime': serializer.toJson<DateTime?>(lastReadTime),
      'isAscending': serializer.toJson<bool>(isAscending),
      'customOrder': serializer.toJson<int>(customOrder),
      'bookGroup': serializer.toJson<String?>(bookGroup),
    };
  }

  Book copyWith(
          {int? id,
          int? bookSourceId,
          Value<String?> bookUrl = const Value.absent(),
          String? name,
          Value<String?> author = const Value.absent(),
          Value<String?> cover = const Value.absent(),
          Value<String?> intro = const Value.absent(),
          Value<String?> kind = const Value.absent(),
          Value<String?> wordCount = const Value.absent(),
          Value<String?> lastChapter = const Value.absent(),
          int? totalChapterNum,
          int? durChapterIndex,
          int? durChapterPos,
          Value<DateTime?> lastReadTime = const Value.absent(),
          bool? isAscending,
          int? customOrder,
          Value<String?> bookGroup = const Value.absent()}) =>
      Book(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        bookUrl: bookUrl.present ? bookUrl.value : this.bookUrl,
        name: name ?? this.name,
        author: author.present ? author.value : this.author,
        cover: cover.present ? cover.value : this.cover,
        intro: intro.present ? intro.value : this.intro,
        kind: kind.present ? kind.value : this.kind,
        wordCount: wordCount.present ? wordCount.value : this.wordCount,
        lastChapter: lastChapter.present ? lastChapter.value : this.lastChapter,
        totalChapterNum: totalChapterNum ?? this.totalChapterNum,
        durChapterIndex: durChapterIndex ?? this.durChapterIndex,
        durChapterPos: durChapterPos ?? this.durChapterPos,
        lastReadTime:
            lastReadTime.present ? lastReadTime.value : this.lastReadTime,
        isAscending: isAscending ?? this.isAscending,
        customOrder: customOrder ?? this.customOrder,
        bookGroup: bookGroup.present ? bookGroup.value : this.bookGroup,
      );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      bookUrl: data.bookUrl.present ? data.bookUrl.value : this.bookUrl,
      name: data.name.present ? data.name.value : this.name,
      author: data.author.present ? data.author.value : this.author,
      cover: data.cover.present ? data.cover.value : this.cover,
      intro: data.intro.present ? data.intro.value : this.intro,
      kind: data.kind.present ? data.kind.value : this.kind,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      lastChapter:
          data.lastChapter.present ? data.lastChapter.value : this.lastChapter,
      totalChapterNum: data.totalChapterNum.present
          ? data.totalChapterNum.value
          : this.totalChapterNum,
      durChapterIndex: data.durChapterIndex.present
          ? data.durChapterIndex.value
          : this.durChapterIndex,
      durChapterPos: data.durChapterPos.present
          ? data.durChapterPos.value
          : this.durChapterPos,
      lastReadTime: data.lastReadTime.present
          ? data.lastReadTime.value
          : this.lastReadTime,
      isAscending:
          data.isAscending.present ? data.isAscending.value : this.isAscending,
      customOrder:
          data.customOrder.present ? data.customOrder.value : this.customOrder,
      bookGroup: data.bookGroup.present ? data.bookGroup.value : this.bookGroup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookUrl: $bookUrl, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('cover: $cover, ')
          ..write('intro: $intro, ')
          ..write('kind: $kind, ')
          ..write('wordCount: $wordCount, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('totalChapterNum: $totalChapterNum, ')
          ..write('durChapterIndex: $durChapterIndex, ')
          ..write('durChapterPos: $durChapterPos, ')
          ..write('lastReadTime: $lastReadTime, ')
          ..write('isAscending: $isAscending, ')
          ..write('customOrder: $customOrder, ')
          ..write('bookGroup: $bookGroup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookSourceId,
      bookUrl,
      name,
      author,
      cover,
      intro,
      kind,
      wordCount,
      lastChapter,
      totalChapterNum,
      durChapterIndex,
      durChapterPos,
      lastReadTime,
      isAscending,
      customOrder,
      bookGroup);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.bookUrl == this.bookUrl &&
          other.name == this.name &&
          other.author == this.author &&
          other.cover == this.cover &&
          other.intro == this.intro &&
          other.kind == this.kind &&
          other.wordCount == this.wordCount &&
          other.lastChapter == this.lastChapter &&
          other.totalChapterNum == this.totalChapterNum &&
          other.durChapterIndex == this.durChapterIndex &&
          other.durChapterPos == this.durChapterPos &&
          other.lastReadTime == this.lastReadTime &&
          other.isAscending == this.isAscending &&
          other.customOrder == this.customOrder &&
          other.bookGroup == this.bookGroup);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String?> bookUrl;
  final Value<String> name;
  final Value<String?> author;
  final Value<String?> cover;
  final Value<String?> intro;
  final Value<String?> kind;
  final Value<String?> wordCount;
  final Value<String?> lastChapter;
  final Value<int> totalChapterNum;
  final Value<int> durChapterIndex;
  final Value<int> durChapterPos;
  final Value<DateTime?> lastReadTime;
  final Value<bool> isAscending;
  final Value<int> customOrder;
  final Value<String?> bookGroup;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.bookUrl = const Value.absent(),
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.cover = const Value.absent(),
    this.intro = const Value.absent(),
    this.kind = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.totalChapterNum = const Value.absent(),
    this.durChapterIndex = const Value.absent(),
    this.durChapterPos = const Value.absent(),
    this.lastReadTime = const Value.absent(),
    this.isAscending = const Value.absent(),
    this.customOrder = const Value.absent(),
    this.bookGroup = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    this.bookUrl = const Value.absent(),
    required String name,
    this.author = const Value.absent(),
    this.cover = const Value.absent(),
    this.intro = const Value.absent(),
    this.kind = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.totalChapterNum = const Value.absent(),
    this.durChapterIndex = const Value.absent(),
    this.durChapterPos = const Value.absent(),
    this.lastReadTime = const Value.absent(),
    this.isAscending = const Value.absent(),
    this.customOrder = const Value.absent(),
    this.bookGroup = const Value.absent(),
  })  : bookSourceId = Value(bookSourceId),
        name = Value(name);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? bookUrl,
    Expression<String>? name,
    Expression<String>? author,
    Expression<String>? cover,
    Expression<String>? intro,
    Expression<String>? kind,
    Expression<String>? wordCount,
    Expression<String>? lastChapter,
    Expression<int>? totalChapterNum,
    Expression<int>? durChapterIndex,
    Expression<int>? durChapterPos,
    Expression<DateTime>? lastReadTime,
    Expression<bool>? isAscending,
    Expression<int>? customOrder,
    Expression<String>? bookGroup,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (bookUrl != null) 'book_url': bookUrl,
      if (name != null) 'name': name,
      if (author != null) 'author': author,
      if (cover != null) 'cover': cover,
      if (intro != null) 'intro': intro,
      if (kind != null) 'kind': kind,
      if (wordCount != null) 'word_count': wordCount,
      if (lastChapter != null) 'last_chapter': lastChapter,
      if (totalChapterNum != null) 'total_chapter_num': totalChapterNum,
      if (durChapterIndex != null) 'dur_chapter_index': durChapterIndex,
      if (durChapterPos != null) 'dur_chapter_pos': durChapterPos,
      if (lastReadTime != null) 'last_read_time': lastReadTime,
      if (isAscending != null) 'is_ascending': isAscending,
      if (customOrder != null) 'custom_order': customOrder,
      if (bookGroup != null) 'book_group': bookGroup,
    });
  }

  BooksCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String?>? bookUrl,
      Value<String>? name,
      Value<String?>? author,
      Value<String?>? cover,
      Value<String?>? intro,
      Value<String?>? kind,
      Value<String?>? wordCount,
      Value<String?>? lastChapter,
      Value<int>? totalChapterNum,
      Value<int>? durChapterIndex,
      Value<int>? durChapterPos,
      Value<DateTime?>? lastReadTime,
      Value<bool>? isAscending,
      Value<int>? customOrder,
      Value<String?>? bookGroup}) {
    return BooksCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      bookUrl: bookUrl ?? this.bookUrl,
      name: name ?? this.name,
      author: author ?? this.author,
      cover: cover ?? this.cover,
      intro: intro ?? this.intro,
      kind: kind ?? this.kind,
      wordCount: wordCount ?? this.wordCount,
      lastChapter: lastChapter ?? this.lastChapter,
      totalChapterNum: totalChapterNum ?? this.totalChapterNum,
      durChapterIndex: durChapterIndex ?? this.durChapterIndex,
      durChapterPos: durChapterPos ?? this.durChapterPos,
      lastReadTime: lastReadTime ?? this.lastReadTime,
      isAscending: isAscending ?? this.isAscending,
      customOrder: customOrder ?? this.customOrder,
      bookGroup: bookGroup ?? this.bookGroup,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (bookUrl.present) {
      map['book_url'] = Variable<String>(bookUrl.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (intro.present) {
      map['intro'] = Variable<String>(intro.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<String>(wordCount.value);
    }
    if (lastChapter.present) {
      map['last_chapter'] = Variable<String>(lastChapter.value);
    }
    if (totalChapterNum.present) {
      map['total_chapter_num'] = Variable<int>(totalChapterNum.value);
    }
    if (durChapterIndex.present) {
      map['dur_chapter_index'] = Variable<int>(durChapterIndex.value);
    }
    if (durChapterPos.present) {
      map['dur_chapter_pos'] = Variable<int>(durChapterPos.value);
    }
    if (lastReadTime.present) {
      map['last_read_time'] = Variable<DateTime>(lastReadTime.value);
    }
    if (isAscending.present) {
      map['is_ascending'] = Variable<bool>(isAscending.value);
    }
    if (customOrder.present) {
      map['custom_order'] = Variable<int>(customOrder.value);
    }
    if (bookGroup.present) {
      map['book_group'] = Variable<String>(bookGroup.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookUrl: $bookUrl, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('cover: $cover, ')
          ..write('intro: $intro, ')
          ..write('kind: $kind, ')
          ..write('wordCount: $wordCount, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('totalChapterNum: $totalChapterNum, ')
          ..write('durChapterIndex: $durChapterIndex, ')
          ..write('durChapterPos: $durChapterPos, ')
          ..write('lastReadTime: $lastReadTime, ')
          ..write('isAscending: $isAscending, ')
          ..write('customOrder: $customOrder, ')
          ..write('bookGroup: $bookGroup')
          ..write(')'))
        .toString();
  }
}

class $BookChaptersTable extends BookChapters
    with TableInfo<$BookChaptersTable, BookChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chapterNameMeta =
      const VerificationMeta('chapterName');
  @override
  late final GeneratedColumn<String> chapterName = GeneratedColumn<String>(
      'chapter_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterUrlMeta =
      const VerificationMeta('chapterUrl');
  @override
  late final GeneratedColumn<String> chapterUrl = GeneratedColumn<String>(
      'chapter_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isVipMeta = const VerificationMeta('isVip');
  @override
  late final GeneratedColumn<bool> isVip = GeneratedColumn<bool>(
      'is_vip', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_vip" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wordCountMeta =
      const VerificationMeta('wordCount');
  @override
  late final GeneratedColumn<String> wordCount = GeneratedColumn<String>(
      'word_count', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        bookSourceId,
        chapterIndex,
        chapterName,
        chapterUrl,
        isVip,
        wordCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_chapters';
  @override
  VerificationContext validateIntegrity(Insertable<BookChapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('chapter_name')) {
      context.handle(
          _chapterNameMeta,
          chapterName.isAcceptableOrUnknown(
              data['chapter_name']!, _chapterNameMeta));
    } else if (isInserting) {
      context.missing(_chapterNameMeta);
    }
    if (data.containsKey('chapter_url')) {
      context.handle(
          _chapterUrlMeta,
          chapterUrl.isAcceptableOrUnknown(
              data['chapter_url']!, _chapterUrlMeta));
    } else if (isInserting) {
      context.missing(_chapterUrlMeta);
    }
    if (data.containsKey('is_vip')) {
      context.handle(
          _isVipMeta, isVip.isAcceptableOrUnknown(data['is_vip']!, _isVipMeta));
    }
    if (data.containsKey('word_count')) {
      context.handle(_wordCountMeta,
          wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookChapter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index'])!,
      chapterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_name'])!,
      chapterUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_url'])!,
      isVip: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_vip'])!,
      wordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word_count']),
    );
  }

  @override
  $BookChaptersTable createAlias(String alias) {
    return $BookChaptersTable(attachedDatabase, alias);
  }
}

class BookChapter extends DataClass implements Insertable<BookChapter> {
  final int id;
  final int bookId;
  final int bookSourceId;
  final int chapterIndex;
  final String chapterName;
  final String chapterUrl;
  final bool isVip;
  final String? wordCount;
  const BookChapter(
      {required this.id,
      required this.bookId,
      required this.bookSourceId,
      required this.chapterIndex,
      required this.chapterName,
      required this.chapterUrl,
      required this.isVip,
      this.wordCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['book_source_id'] = Variable<int>(bookSourceId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['chapter_name'] = Variable<String>(chapterName);
    map['chapter_url'] = Variable<String>(chapterUrl);
    map['is_vip'] = Variable<bool>(isVip);
    if (!nullToAbsent || wordCount != null) {
      map['word_count'] = Variable<String>(wordCount);
    }
    return map;
  }

  BookChaptersCompanion toCompanion(bool nullToAbsent) {
    return BookChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      bookSourceId: Value(bookSourceId),
      chapterIndex: Value(chapterIndex),
      chapterName: Value(chapterName),
      chapterUrl: Value(chapterUrl),
      isVip: Value(isVip),
      wordCount: wordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordCount),
    );
  }

  factory BookChapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookChapter(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      chapterName: serializer.fromJson<String>(json['chapterName']),
      chapterUrl: serializer.fromJson<String>(json['chapterUrl']),
      isVip: serializer.fromJson<bool>(json['isVip']),
      wordCount: serializer.fromJson<String?>(json['wordCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'chapterName': serializer.toJson<String>(chapterName),
      'chapterUrl': serializer.toJson<String>(chapterUrl),
      'isVip': serializer.toJson<bool>(isVip),
      'wordCount': serializer.toJson<String?>(wordCount),
    };
  }

  BookChapter copyWith(
          {int? id,
          int? bookId,
          int? bookSourceId,
          int? chapterIndex,
          String? chapterName,
          String? chapterUrl,
          bool? isVip,
          Value<String?> wordCount = const Value.absent()}) =>
      BookChapter(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        chapterName: chapterName ?? this.chapterName,
        chapterUrl: chapterUrl ?? this.chapterUrl,
        isVip: isVip ?? this.isVip,
        wordCount: wordCount.present ? wordCount.value : this.wordCount,
      );
  BookChapter copyWithCompanion(BookChaptersCompanion data) {
    return BookChapter(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      chapterName:
          data.chapterName.present ? data.chapterName.value : this.chapterName,
      chapterUrl:
          data.chapterUrl.present ? data.chapterUrl.value : this.chapterUrl,
      isVip: data.isVip.present ? data.isVip.value : this.isVip,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookChapter(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('isVip: $isVip, ')
          ..write('wordCount: $wordCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, bookSourceId, chapterIndex,
      chapterName, chapterUrl, isVip, wordCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookChapter &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.bookSourceId == this.bookSourceId &&
          other.chapterIndex == this.chapterIndex &&
          other.chapterName == this.chapterName &&
          other.chapterUrl == this.chapterUrl &&
          other.isVip == this.isVip &&
          other.wordCount == this.wordCount);
}

class BookChaptersCompanion extends UpdateCompanion<BookChapter> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> bookSourceId;
  final Value<int> chapterIndex;
  final Value<String> chapterName;
  final Value<String> chapterUrl;
  final Value<bool> isVip;
  final Value<String?> wordCount;
  const BookChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.chapterUrl = const Value.absent(),
    this.isVip = const Value.absent(),
    this.wordCount = const Value.absent(),
  });
  BookChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int bookSourceId,
    required int chapterIndex,
    required String chapterName,
    required String chapterUrl,
    this.isVip = const Value.absent(),
    this.wordCount = const Value.absent(),
  })  : bookId = Value(bookId),
        bookSourceId = Value(bookSourceId),
        chapterIndex = Value(chapterIndex),
        chapterName = Value(chapterName),
        chapterUrl = Value(chapterUrl);
  static Insertable<BookChapter> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? bookSourceId,
    Expression<int>? chapterIndex,
    Expression<String>? chapterName,
    Expression<String>? chapterUrl,
    Expression<bool>? isVip,
    Expression<String>? wordCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (chapterName != null) 'chapter_name': chapterName,
      if (chapterUrl != null) 'chapter_url': chapterUrl,
      if (isVip != null) 'is_vip': isVip,
      if (wordCount != null) 'word_count': wordCount,
    });
  }

  BookChaptersCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookId,
      Value<int>? bookSourceId,
      Value<int>? chapterIndex,
      Value<String>? chapterName,
      Value<String>? chapterUrl,
      Value<bool>? isVip,
      Value<String?>? wordCount}) {
    return BookChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      chapterName: chapterName ?? this.chapterName,
      chapterUrl: chapterUrl ?? this.chapterUrl,
      isVip: isVip ?? this.isVip,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (chapterName.present) {
      map['chapter_name'] = Variable<String>(chapterName.value);
    }
    if (chapterUrl.present) {
      map['chapter_url'] = Variable<String>(chapterUrl.value);
    }
    if (isVip.present) {
      map['is_vip'] = Variable<bool>(isVip.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<String>(wordCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('isVip: $isVip, ')
          ..write('wordCount: $wordCount')
          ..write(')'))
        .toString();
  }
}

class $LocalBookFilesTable extends LocalBookFiles
    with TableInfo<$LocalBookFilesTable, LocalBookFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBookFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originalFileNameMeta =
      const VerificationMeta('originalFileName');
  @override
  late final GeneratedColumn<String> originalFileName = GeneratedColumn<String>(
      'original_file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storedFilePathMeta =
      const VerificationMeta('storedFilePath');
  @override
  late final GeneratedColumn<String> storedFilePath = GeneratedColumn<String>(
      'stored_file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _charsetMeta =
      const VerificationMeta('charset');
  @override
  late final GeneratedColumn<String> charset = GeneratedColumn<String>(
      'charset', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fileHashMeta =
      const VerificationMeta('fileHash');
  @override
  late final GeneratedColumn<String> fileHash = GeneratedColumn<String>(
      'file_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _importTimeMeta =
      const VerificationMeta('importTime');
  @override
  late final GeneratedColumn<DateTime> importTime = GeneratedColumn<DateTime>(
      'import_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sourceModifiedTimeMeta =
      const VerificationMeta('sourceModifiedTime');
  @override
  late final GeneratedColumn<DateTime> sourceModifiedTime =
      GeneratedColumn<DateTime>('source_modified_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        bookId,
        originalFileName,
        storedFilePath,
        format,
        charset,
        fileSize,
        fileHash,
        importTime,
        sourceModifiedTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_book_files';
  @override
  VerificationContext validateIntegrity(Insertable<LocalBookFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    }
    if (data.containsKey('original_file_name')) {
      context.handle(
          _originalFileNameMeta,
          originalFileName.isAcceptableOrUnknown(
              data['original_file_name']!, _originalFileNameMeta));
    } else if (isInserting) {
      context.missing(_originalFileNameMeta);
    }
    if (data.containsKey('stored_file_path')) {
      context.handle(
          _storedFilePathMeta,
          storedFilePath.isAcceptableOrUnknown(
              data['stored_file_path']!, _storedFilePathMeta));
    } else if (isInserting) {
      context.missing(_storedFilePathMeta);
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('charset')) {
      context.handle(_charsetMeta,
          charset.isAcceptableOrUnknown(data['charset']!, _charsetMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('file_hash')) {
      context.handle(_fileHashMeta,
          fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta));
    }
    if (data.containsKey('import_time')) {
      context.handle(
          _importTimeMeta,
          importTime.isAcceptableOrUnknown(
              data['import_time']!, _importTimeMeta));
    } else if (isInserting) {
      context.missing(_importTimeMeta);
    }
    if (data.containsKey('source_modified_time')) {
      context.handle(
          _sourceModifiedTimeMeta,
          sourceModifiedTime.isAcceptableOrUnknown(
              data['source_modified_time']!, _sourceModifiedTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  LocalBookFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBookFile(
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      originalFileName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_file_name'])!,
      storedFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}stored_file_path'])!,
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
      charset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}charset']),
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
      fileHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_hash']),
      importTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}import_time'])!,
      sourceModifiedTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}source_modified_time']),
    );
  }

  @override
  $LocalBookFilesTable createAlias(String alias) {
    return $LocalBookFilesTable(attachedDatabase, alias);
  }
}

class LocalBookFile extends DataClass implements Insertable<LocalBookFile> {
  final int bookId;
  final String originalFileName;
  final String storedFilePath;
  final String format;
  final String? charset;
  final int fileSize;
  final String? fileHash;
  final DateTime importTime;
  final DateTime? sourceModifiedTime;
  const LocalBookFile(
      {required this.bookId,
      required this.originalFileName,
      required this.storedFilePath,
      required this.format,
      this.charset,
      required this.fileSize,
      this.fileHash,
      required this.importTime,
      this.sourceModifiedTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['original_file_name'] = Variable<String>(originalFileName);
    map['stored_file_path'] = Variable<String>(storedFilePath);
    map['format'] = Variable<String>(format);
    if (!nullToAbsent || charset != null) {
      map['charset'] = Variable<String>(charset);
    }
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || fileHash != null) {
      map['file_hash'] = Variable<String>(fileHash);
    }
    map['import_time'] = Variable<DateTime>(importTime);
    if (!nullToAbsent || sourceModifiedTime != null) {
      map['source_modified_time'] = Variable<DateTime>(sourceModifiedTime);
    }
    return map;
  }

  LocalBookFilesCompanion toCompanion(bool nullToAbsent) {
    return LocalBookFilesCompanion(
      bookId: Value(bookId),
      originalFileName: Value(originalFileName),
      storedFilePath: Value(storedFilePath),
      format: Value(format),
      charset: charset == null && nullToAbsent
          ? const Value.absent()
          : Value(charset),
      fileSize: Value(fileSize),
      fileHash: fileHash == null && nullToAbsent
          ? const Value.absent()
          : Value(fileHash),
      importTime: Value(importTime),
      sourceModifiedTime: sourceModifiedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceModifiedTime),
    );
  }

  factory LocalBookFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBookFile(
      bookId: serializer.fromJson<int>(json['bookId']),
      originalFileName: serializer.fromJson<String>(json['originalFileName']),
      storedFilePath: serializer.fromJson<String>(json['storedFilePath']),
      format: serializer.fromJson<String>(json['format']),
      charset: serializer.fromJson<String?>(json['charset']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      fileHash: serializer.fromJson<String?>(json['fileHash']),
      importTime: serializer.fromJson<DateTime>(json['importTime']),
      sourceModifiedTime:
          serializer.fromJson<DateTime?>(json['sourceModifiedTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'originalFileName': serializer.toJson<String>(originalFileName),
      'storedFilePath': serializer.toJson<String>(storedFilePath),
      'format': serializer.toJson<String>(format),
      'charset': serializer.toJson<String?>(charset),
      'fileSize': serializer.toJson<int>(fileSize),
      'fileHash': serializer.toJson<String?>(fileHash),
      'importTime': serializer.toJson<DateTime>(importTime),
      'sourceModifiedTime': serializer.toJson<DateTime?>(sourceModifiedTime),
    };
  }

  LocalBookFile copyWith(
          {int? bookId,
          String? originalFileName,
          String? storedFilePath,
          String? format,
          Value<String?> charset = const Value.absent(),
          int? fileSize,
          Value<String?> fileHash = const Value.absent(),
          DateTime? importTime,
          Value<DateTime?> sourceModifiedTime = const Value.absent()}) =>
      LocalBookFile(
        bookId: bookId ?? this.bookId,
        originalFileName: originalFileName ?? this.originalFileName,
        storedFilePath: storedFilePath ?? this.storedFilePath,
        format: format ?? this.format,
        charset: charset.present ? charset.value : this.charset,
        fileSize: fileSize ?? this.fileSize,
        fileHash: fileHash.present ? fileHash.value : this.fileHash,
        importTime: importTime ?? this.importTime,
        sourceModifiedTime: sourceModifiedTime.present
            ? sourceModifiedTime.value
            : this.sourceModifiedTime,
      );
  LocalBookFile copyWithCompanion(LocalBookFilesCompanion data) {
    return LocalBookFile(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      originalFileName: data.originalFileName.present
          ? data.originalFileName.value
          : this.originalFileName,
      storedFilePath: data.storedFilePath.present
          ? data.storedFilePath.value
          : this.storedFilePath,
      format: data.format.present ? data.format.value : this.format,
      charset: data.charset.present ? data.charset.value : this.charset,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,
      importTime:
          data.importTime.present ? data.importTime.value : this.importTime,
      sourceModifiedTime: data.sourceModifiedTime.present
          ? data.sourceModifiedTime.value
          : this.sourceModifiedTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBookFile(')
          ..write('bookId: $bookId, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('storedFilePath: $storedFilePath, ')
          ..write('format: $format, ')
          ..write('charset: $charset, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileHash: $fileHash, ')
          ..write('importTime: $importTime, ')
          ..write('sourceModifiedTime: $sourceModifiedTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, originalFileName, storedFilePath,
      format, charset, fileSize, fileHash, importTime, sourceModifiedTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBookFile &&
          other.bookId == this.bookId &&
          other.originalFileName == this.originalFileName &&
          other.storedFilePath == this.storedFilePath &&
          other.format == this.format &&
          other.charset == this.charset &&
          other.fileSize == this.fileSize &&
          other.fileHash == this.fileHash &&
          other.importTime == this.importTime &&
          other.sourceModifiedTime == this.sourceModifiedTime);
}

class LocalBookFilesCompanion extends UpdateCompanion<LocalBookFile> {
  final Value<int> bookId;
  final Value<String> originalFileName;
  final Value<String> storedFilePath;
  final Value<String> format;
  final Value<String?> charset;
  final Value<int> fileSize;
  final Value<String?> fileHash;
  final Value<DateTime> importTime;
  final Value<DateTime?> sourceModifiedTime;
  const LocalBookFilesCompanion({
    this.bookId = const Value.absent(),
    this.originalFileName = const Value.absent(),
    this.storedFilePath = const Value.absent(),
    this.format = const Value.absent(),
    this.charset = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.importTime = const Value.absent(),
    this.sourceModifiedTime = const Value.absent(),
  });
  LocalBookFilesCompanion.insert({
    this.bookId = const Value.absent(),
    required String originalFileName,
    required String storedFilePath,
    required String format,
    this.charset = const Value.absent(),
    required int fileSize,
    this.fileHash = const Value.absent(),
    required DateTime importTime,
    this.sourceModifiedTime = const Value.absent(),
  })  : originalFileName = Value(originalFileName),
        storedFilePath = Value(storedFilePath),
        format = Value(format),
        fileSize = Value(fileSize),
        importTime = Value(importTime);
  static Insertable<LocalBookFile> custom({
    Expression<int>? bookId,
    Expression<String>? originalFileName,
    Expression<String>? storedFilePath,
    Expression<String>? format,
    Expression<String>? charset,
    Expression<int>? fileSize,
    Expression<String>? fileHash,
    Expression<DateTime>? importTime,
    Expression<DateTime>? sourceModifiedTime,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (originalFileName != null) 'original_file_name': originalFileName,
      if (storedFilePath != null) 'stored_file_path': storedFilePath,
      if (format != null) 'format': format,
      if (charset != null) 'charset': charset,
      if (fileSize != null) 'file_size': fileSize,
      if (fileHash != null) 'file_hash': fileHash,
      if (importTime != null) 'import_time': importTime,
      if (sourceModifiedTime != null)
        'source_modified_time': sourceModifiedTime,
    });
  }

  LocalBookFilesCompanion copyWith(
      {Value<int>? bookId,
      Value<String>? originalFileName,
      Value<String>? storedFilePath,
      Value<String>? format,
      Value<String?>? charset,
      Value<int>? fileSize,
      Value<String?>? fileHash,
      Value<DateTime>? importTime,
      Value<DateTime?>? sourceModifiedTime}) {
    return LocalBookFilesCompanion(
      bookId: bookId ?? this.bookId,
      originalFileName: originalFileName ?? this.originalFileName,
      storedFilePath: storedFilePath ?? this.storedFilePath,
      format: format ?? this.format,
      charset: charset ?? this.charset,
      fileSize: fileSize ?? this.fileSize,
      fileHash: fileHash ?? this.fileHash,
      importTime: importTime ?? this.importTime,
      sourceModifiedTime: sourceModifiedTime ?? this.sourceModifiedTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (originalFileName.present) {
      map['original_file_name'] = Variable<String>(originalFileName.value);
    }
    if (storedFilePath.present) {
      map['stored_file_path'] = Variable<String>(storedFilePath.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (charset.present) {
      map['charset'] = Variable<String>(charset.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (fileHash.present) {
      map['file_hash'] = Variable<String>(fileHash.value);
    }
    if (importTime.present) {
      map['import_time'] = Variable<DateTime>(importTime.value);
    }
    if (sourceModifiedTime.present) {
      map['source_modified_time'] =
          Variable<DateTime>(sourceModifiedTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBookFilesCompanion(')
          ..write('bookId: $bookId, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('storedFilePath: $storedFilePath, ')
          ..write('format: $format, ')
          ..write('charset: $charset, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileHash: $fileHash, ')
          ..write('importTime: $importTime, ')
          ..write('sourceModifiedTime: $sourceModifiedTime')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bookNameMeta =
      const VerificationMeta('bookName');
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
      'book_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locatorJsonMeta =
      const VerificationMeta('locatorJson');
  @override
  late final GeneratedColumn<String> locatorJson = GeneratedColumn<String>(
      'locator_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNameMeta =
      const VerificationMeta('chapterName');
  @override
  late final GeneratedColumn<String> chapterName = GeneratedColumn<String>(
      'chapter_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _bookTextMeta =
      const VerificationMeta('bookText');
  @override
  late final GeneratedColumn<String> bookText = GeneratedColumn<String>(
      'book_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createTimeMeta =
      const VerificationMeta('createTime');
  @override
  late final GeneratedColumn<DateTime> createTime = GeneratedColumn<DateTime>(
      'create_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        bookName,
        locatorJson,
        chapterName,
        bookText,
        content,
        createTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<Bookmark> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(_bookNameMeta,
          bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta));
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('locator_json')) {
      context.handle(
          _locatorJsonMeta,
          locatorJson.isAcceptableOrUnknown(
              data['locator_json']!, _locatorJsonMeta));
    } else if (isInserting) {
      context.missing(_locatorJsonMeta);
    }
    if (data.containsKey('chapter_name')) {
      context.handle(
          _chapterNameMeta,
          chapterName.isAcceptableOrUnknown(
              data['chapter_name']!, _chapterNameMeta));
    }
    if (data.containsKey('book_text')) {
      context.handle(_bookTextMeta,
          bookText.isAcceptableOrUnknown(data['book_text']!, _bookTextMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('create_time')) {
      context.handle(
          _createTimeMeta,
          createTime.isAcceptableOrUnknown(
              data['create_time']!, _createTimeMeta));
    } else if (isInserting) {
      context.missing(_createTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      bookName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_name'])!,
      locatorJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locator_json'])!,
      chapterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_name'])!,
      bookText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_text'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}create_time'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final int bookSourceId;
  final String bookName;
  final String locatorJson;
  final String chapterName;
  final String bookText;
  final String content;
  final DateTime createTime;
  const Bookmark(
      {required this.id,
      required this.bookSourceId,
      required this.bookName,
      required this.locatorJson,
      required this.chapterName,
      required this.bookText,
      required this.content,
      required this.createTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    map['book_name'] = Variable<String>(bookName);
    map['locator_json'] = Variable<String>(locatorJson);
    map['chapter_name'] = Variable<String>(chapterName);
    map['book_text'] = Variable<String>(bookText);
    map['content'] = Variable<String>(content);
    map['create_time'] = Variable<DateTime>(createTime);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      bookName: Value(bookName),
      locatorJson: Value(locatorJson),
      chapterName: Value(chapterName),
      bookText: Value(bookText),
      content: Value(content),
      createTime: Value(createTime),
    );
  }

  factory Bookmark.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      bookName: serializer.fromJson<String>(json['bookName']),
      locatorJson: serializer.fromJson<String>(json['locatorJson']),
      chapterName: serializer.fromJson<String>(json['chapterName']),
      bookText: serializer.fromJson<String>(json['bookText']),
      content: serializer.fromJson<String>(json['content']),
      createTime: serializer.fromJson<DateTime>(json['createTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'bookName': serializer.toJson<String>(bookName),
      'locatorJson': serializer.toJson<String>(locatorJson),
      'chapterName': serializer.toJson<String>(chapterName),
      'bookText': serializer.toJson<String>(bookText),
      'content': serializer.toJson<String>(content),
      'createTime': serializer.toJson<DateTime>(createTime),
    };
  }

  Bookmark copyWith(
          {int? id,
          int? bookSourceId,
          String? bookName,
          String? locatorJson,
          String? chapterName,
          String? bookText,
          String? content,
          DateTime? createTime}) =>
      Bookmark(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        bookName: bookName ?? this.bookName,
        locatorJson: locatorJson ?? this.locatorJson,
        chapterName: chapterName ?? this.chapterName,
        bookText: bookText ?? this.bookText,
        content: content ?? this.content,
        createTime: createTime ?? this.createTime,
      );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      locatorJson:
          data.locatorJson.present ? data.locatorJson.value : this.locatorJson,
      chapterName:
          data.chapterName.present ? data.chapterName.value : this.chapterName,
      bookText: data.bookText.present ? data.bookText.value : this.bookText,
      content: data.content.present ? data.content.value : this.content,
      createTime:
          data.createTime.present ? data.createTime.value : this.createTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('chapterName: $chapterName, ')
          ..write('bookText: $bookText, ')
          ..write('content: $content, ')
          ..write('createTime: $createTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookSourceId, bookName, locatorJson,
      chapterName, bookText, content, createTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.bookName == this.bookName &&
          other.locatorJson == this.locatorJson &&
          other.chapterName == this.chapterName &&
          other.bookText == this.bookText &&
          other.content == this.content &&
          other.createTime == this.createTime);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String> bookName;
  final Value<String> locatorJson;
  final Value<String> chapterName;
  final Value<String> bookText;
  final Value<String> content;
  final Value<DateTime> createTime;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.bookName = const Value.absent(),
    this.locatorJson = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.bookText = const Value.absent(),
    this.content = const Value.absent(),
    this.createTime = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    required String bookName,
    required String locatorJson,
    this.chapterName = const Value.absent(),
    this.bookText = const Value.absent(),
    this.content = const Value.absent(),
    required DateTime createTime,
  })  : bookSourceId = Value(bookSourceId),
        bookName = Value(bookName),
        locatorJson = Value(locatorJson),
        createTime = Value(createTime);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? bookName,
    Expression<String>? locatorJson,
    Expression<String>? chapterName,
    Expression<String>? bookText,
    Expression<String>? content,
    Expression<DateTime>? createTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (bookName != null) 'book_name': bookName,
      if (locatorJson != null) 'locator_json': locatorJson,
      if (chapterName != null) 'chapter_name': chapterName,
      if (bookText != null) 'book_text': bookText,
      if (content != null) 'content': content,
      if (createTime != null) 'create_time': createTime,
    });
  }

  BookmarksCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String>? bookName,
      Value<String>? locatorJson,
      Value<String>? chapterName,
      Value<String>? bookText,
      Value<String>? content,
      Value<DateTime>? createTime}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      bookName: bookName ?? this.bookName,
      locatorJson: locatorJson ?? this.locatorJson,
      chapterName: chapterName ?? this.chapterName,
      bookText: bookText ?? this.bookText,
      content: content ?? this.content,
      createTime: createTime ?? this.createTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (locatorJson.present) {
      map['locator_json'] = Variable<String>(locatorJson.value);
    }
    if (chapterName.present) {
      map['chapter_name'] = Variable<String>(chapterName.value);
    }
    if (bookText.present) {
      map['book_text'] = Variable<String>(bookText.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createTime.present) {
      map['create_time'] = Variable<DateTime>(createTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('chapterName: $chapterName, ')
          ..write('bookText: $bookText, ')
          ..write('content: $content, ')
          ..write('createTime: $createTime')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bookNameMeta =
      const VerificationMeta('bookName');
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
      'book_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNameMeta =
      const VerificationMeta('chapterName');
  @override
  late final GeneratedColumn<String> chapterName = GeneratedColumn<String>(
      'chapter_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startLocatorJsonMeta =
      const VerificationMeta('startLocatorJson');
  @override
  late final GeneratedColumn<String> startLocatorJson = GeneratedColumn<String>(
      'start_locator_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endLocatorJsonMeta =
      const VerificationMeta('endLocatorJson');
  @override
  late final GeneratedColumn<String> endLocatorJson = GeneratedColumn<String>(
      'end_locator_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        bookName,
        chapterName,
        chapterIndex,
        startLocatorJson,
        endLocatorJson,
        startedAt,
        endedAt,
        durationSeconds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(_bookNameMeta,
          bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta));
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('chapter_name')) {
      context.handle(
          _chapterNameMeta,
          chapterName.isAcceptableOrUnknown(
              data['chapter_name']!, _chapterNameMeta));
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('start_locator_json')) {
      context.handle(
          _startLocatorJsonMeta,
          startLocatorJson.isAcceptableOrUnknown(
              data['start_locator_json']!, _startLocatorJsonMeta));
    } else if (isInserting) {
      context.missing(_startLocatorJsonMeta);
    }
    if (data.containsKey('end_locator_json')) {
      context.handle(
          _endLocatorJsonMeta,
          endLocatorJson.isAcceptableOrUnknown(
              data['end_locator_json']!, _endLocatorJsonMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      bookName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_name'])!,
      chapterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_name']),
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index'])!,
      startLocatorJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}start_locator_json'])!,
      endLocatorJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}end_locator_json']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSession extends DataClass implements Insertable<ReadingSession> {
  final int id;
  final int bookSourceId;
  final String bookName;
  final String? chapterName;
  final int chapterIndex;
  final String startLocatorJson;
  final String? endLocatorJson;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  const ReadingSession(
      {required this.id,
      required this.bookSourceId,
      required this.bookName,
      this.chapterName,
      required this.chapterIndex,
      required this.startLocatorJson,
      this.endLocatorJson,
      required this.startedAt,
      this.endedAt,
      required this.durationSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    map['book_name'] = Variable<String>(bookName);
    if (!nullToAbsent || chapterName != null) {
      map['chapter_name'] = Variable<String>(chapterName);
    }
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['start_locator_json'] = Variable<String>(startLocatorJson);
    if (!nullToAbsent || endLocatorJson != null) {
      map['end_locator_json'] = Variable<String>(endLocatorJson);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      bookName: Value(bookName),
      chapterName: chapterName == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterName),
      chapterIndex: Value(chapterIndex),
      startLocatorJson: Value(startLocatorJson),
      endLocatorJson: endLocatorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(endLocatorJson),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationSeconds: Value(durationSeconds),
    );
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSession(
      id: serializer.fromJson<int>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      bookName: serializer.fromJson<String>(json['bookName']),
      chapterName: serializer.fromJson<String?>(json['chapterName']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      startLocatorJson: serializer.fromJson<String>(json['startLocatorJson']),
      endLocatorJson: serializer.fromJson<String?>(json['endLocatorJson']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'bookName': serializer.toJson<String>(bookName),
      'chapterName': serializer.toJson<String?>(chapterName),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'startLocatorJson': serializer.toJson<String>(startLocatorJson),
      'endLocatorJson': serializer.toJson<String?>(endLocatorJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
    };
  }

  ReadingSession copyWith(
          {int? id,
          int? bookSourceId,
          String? bookName,
          Value<String?> chapterName = const Value.absent(),
          int? chapterIndex,
          String? startLocatorJson,
          Value<String?> endLocatorJson = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          int? durationSeconds}) =>
      ReadingSession(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        bookName: bookName ?? this.bookName,
        chapterName: chapterName.present ? chapterName.value : this.chapterName,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        startLocatorJson: startLocatorJson ?? this.startLocatorJson,
        endLocatorJson:
            endLocatorJson.present ? endLocatorJson.value : this.endLocatorJson,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
      );
  ReadingSession copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSession(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      chapterName:
          data.chapterName.present ? data.chapterName.value : this.chapterName,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      startLocatorJson: data.startLocatorJson.present
          ? data.startLocatorJson.value
          : this.startLocatorJson,
      endLocatorJson: data.endLocatorJson.present
          ? data.endLocatorJson.value
          : this.endLocatorJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSession(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('startLocatorJson: $startLocatorJson, ')
          ..write('endLocatorJson: $endLocatorJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookSourceId,
      bookName,
      chapterName,
      chapterIndex,
      startLocatorJson,
      endLocatorJson,
      startedAt,
      endedAt,
      durationSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSession &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.bookName == this.bookName &&
          other.chapterName == this.chapterName &&
          other.chapterIndex == this.chapterIndex &&
          other.startLocatorJson == this.startLocatorJson &&
          other.endLocatorJson == this.endLocatorJson &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSession> {
  final Value<int> id;
  final Value<int> bookSourceId;
  final Value<String> bookName;
  final Value<String?> chapterName;
  final Value<int> chapterIndex;
  final Value<String> startLocatorJson;
  final Value<String?> endLocatorJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationSeconds;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.bookName = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.startLocatorJson = const Value.absent(),
    this.endLocatorJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int bookSourceId,
    required String bookName,
    this.chapterName = const Value.absent(),
    required int chapterIndex,
    required String startLocatorJson,
    this.endLocatorJson = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
  })  : bookSourceId = Value(bookSourceId),
        bookName = Value(bookName),
        chapterIndex = Value(chapterIndex),
        startLocatorJson = Value(startLocatorJson),
        startedAt = Value(startedAt);
  static Insertable<ReadingSession> custom({
    Expression<int>? id,
    Expression<int>? bookSourceId,
    Expression<String>? bookName,
    Expression<String>? chapterName,
    Expression<int>? chapterIndex,
    Expression<String>? startLocatorJson,
    Expression<String>? endLocatorJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (bookName != null) 'book_name': bookName,
      if (chapterName != null) 'chapter_name': chapterName,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (startLocatorJson != null) 'start_locator_json': startLocatorJson,
      if (endLocatorJson != null) 'end_locator_json': endLocatorJson,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
    });
  }

  ReadingSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookSourceId,
      Value<String>? bookName,
      Value<String?>? chapterName,
      Value<int>? chapterIndex,
      Value<String>? startLocatorJson,
      Value<String?>? endLocatorJson,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<int>? durationSeconds}) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      bookName: bookName ?? this.bookName,
      chapterName: chapterName ?? this.chapterName,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      startLocatorJson: startLocatorJson ?? this.startLocatorJson,
      endLocatorJson: endLocatorJson ?? this.endLocatorJson,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (chapterName.present) {
      map['chapter_name'] = Variable<String>(chapterName.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (startLocatorJson.present) {
      map['start_locator_json'] = Variable<String>(startLocatorJson.value);
    }
    if (endLocatorJson.present) {
      map['end_locator_json'] = Variable<String>(endLocatorJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterName: $chapterName, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('startLocatorJson: $startLocatorJson, ')
          ..write('endLocatorJson: $endLocatorJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }
}

class $BookAnnotationsTable extends BookAnnotations
    with TableInfo<$BookAnnotationsTable, BookAnnotation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookAnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookSourceIdMeta =
      const VerificationMeta('bookSourceId');
  @override
  late final GeneratedColumn<int> bookSourceId = GeneratedColumn<int>(
      'book_source_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bookNameMeta =
      const VerificationMeta('bookName');
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
      'book_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chapterNameMeta =
      const VerificationMeta('chapterName');
  @override
  late final GeneratedColumn<String> chapterName = GeneratedColumn<String>(
      'chapter_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _locatorJsonMeta =
      const VerificationMeta('locatorJson');
  @override
  late final GeneratedColumn<String> locatorJson = GeneratedColumn<String>(
      'locator_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _excerptMeta =
      const VerificationMeta('excerpt');
  @override
  late final GeneratedColumn<String> excerpt = GeneratedColumn<String>(
      'excerpt', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookSourceId,
        bookName,
        chapterIndex,
        chapterName,
        locatorJson,
        type,
        excerpt,
        note,
        colorValue,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_annotations';
  @override
  VerificationContext validateIntegrity(Insertable<BookAnnotation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_source_id')) {
      context.handle(
          _bookSourceIdMeta,
          bookSourceId.isAcceptableOrUnknown(
              data['book_source_id']!, _bookSourceIdMeta));
    } else if (isInserting) {
      context.missing(_bookSourceIdMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(_bookNameMeta,
          bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta));
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('chapter_name')) {
      context.handle(
          _chapterNameMeta,
          chapterName.isAcceptableOrUnknown(
              data['chapter_name']!, _chapterNameMeta));
    }
    if (data.containsKey('locator_json')) {
      context.handle(
          _locatorJsonMeta,
          locatorJson.isAcceptableOrUnknown(
              data['locator_json']!, _locatorJsonMeta));
    } else if (isInserting) {
      context.missing(_locatorJsonMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('excerpt')) {
      context.handle(_excerptMeta,
          excerpt.isAcceptableOrUnknown(data['excerpt']!, _excerptMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {bookSourceId, bookName, chapterIndex, locatorJson, type},
      ];
  @override
  BookAnnotation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookAnnotation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_source_id'])!,
      bookName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_name'])!,
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index'])!,
      chapterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_name'])!,
      locatorJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locator_json'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      excerpt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}excerpt'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BookAnnotationsTable createAlias(String alias) {
    return $BookAnnotationsTable(attachedDatabase, alias);
  }
}

class BookAnnotation extends DataClass implements Insertable<BookAnnotation> {
  final String id;
  final int bookSourceId;
  final String bookName;
  final int chapterIndex;
  final String chapterName;
  final String locatorJson;
  final String type;
  final String excerpt;
  final String note;
  final int? colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BookAnnotation(
      {required this.id,
      required this.bookSourceId,
      required this.bookName,
      required this.chapterIndex,
      required this.chapterName,
      required this.locatorJson,
      required this.type,
      required this.excerpt,
      required this.note,
      this.colorValue,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_source_id'] = Variable<int>(bookSourceId);
    map['book_name'] = Variable<String>(bookName);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['chapter_name'] = Variable<String>(chapterName);
    map['locator_json'] = Variable<String>(locatorJson);
    map['type'] = Variable<String>(type);
    map['excerpt'] = Variable<String>(excerpt);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BookAnnotationsCompanion toCompanion(bool nullToAbsent) {
    return BookAnnotationsCompanion(
      id: Value(id),
      bookSourceId: Value(bookSourceId),
      bookName: Value(bookName),
      chapterIndex: Value(chapterIndex),
      chapterName: Value(chapterName),
      locatorJson: Value(locatorJson),
      type: Value(type),
      excerpt: Value(excerpt),
      note: Value(note),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BookAnnotation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookAnnotation(
      id: serializer.fromJson<String>(json['id']),
      bookSourceId: serializer.fromJson<int>(json['bookSourceId']),
      bookName: serializer.fromJson<String>(json['bookName']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      chapterName: serializer.fromJson<String>(json['chapterName']),
      locatorJson: serializer.fromJson<String>(json['locatorJson']),
      type: serializer.fromJson<String>(json['type']),
      excerpt: serializer.fromJson<String>(json['excerpt']),
      note: serializer.fromJson<String>(json['note']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookSourceId': serializer.toJson<int>(bookSourceId),
      'bookName': serializer.toJson<String>(bookName),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'chapterName': serializer.toJson<String>(chapterName),
      'locatorJson': serializer.toJson<String>(locatorJson),
      'type': serializer.toJson<String>(type),
      'excerpt': serializer.toJson<String>(excerpt),
      'note': serializer.toJson<String>(note),
      'colorValue': serializer.toJson<int?>(colorValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BookAnnotation copyWith(
          {String? id,
          int? bookSourceId,
          String? bookName,
          int? chapterIndex,
          String? chapterName,
          String? locatorJson,
          String? type,
          String? excerpt,
          String? note,
          Value<int?> colorValue = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      BookAnnotation(
        id: id ?? this.id,
        bookSourceId: bookSourceId ?? this.bookSourceId,
        bookName: bookName ?? this.bookName,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        chapterName: chapterName ?? this.chapterName,
        locatorJson: locatorJson ?? this.locatorJson,
        type: type ?? this.type,
        excerpt: excerpt ?? this.excerpt,
        note: note ?? this.note,
        colorValue: colorValue.present ? colorValue.value : this.colorValue,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  BookAnnotation copyWithCompanion(BookAnnotationsCompanion data) {
    return BookAnnotation(
      id: data.id.present ? data.id.value : this.id,
      bookSourceId: data.bookSourceId.present
          ? data.bookSourceId.value
          : this.bookSourceId,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      chapterName:
          data.chapterName.present ? data.chapterName.value : this.chapterName,
      locatorJson:
          data.locatorJson.present ? data.locatorJson.value : this.locatorJson,
      type: data.type.present ? data.type.value : this.type,
      excerpt: data.excerpt.present ? data.excerpt.value : this.excerpt,
      note: data.note.present ? data.note.value : this.note,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookAnnotation(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterName: $chapterName, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('type: $type, ')
          ..write('excerpt: $excerpt, ')
          ..write('note: $note, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookSourceId,
      bookName,
      chapterIndex,
      chapterName,
      locatorJson,
      type,
      excerpt,
      note,
      colorValue,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookAnnotation &&
          other.id == this.id &&
          other.bookSourceId == this.bookSourceId &&
          other.bookName == this.bookName &&
          other.chapterIndex == this.chapterIndex &&
          other.chapterName == this.chapterName &&
          other.locatorJson == this.locatorJson &&
          other.type == this.type &&
          other.excerpt == this.excerpt &&
          other.note == this.note &&
          other.colorValue == this.colorValue &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BookAnnotationsCompanion extends UpdateCompanion<BookAnnotation> {
  final Value<String> id;
  final Value<int> bookSourceId;
  final Value<String> bookName;
  final Value<int> chapterIndex;
  final Value<String> chapterName;
  final Value<String> locatorJson;
  final Value<String> type;
  final Value<String> excerpt;
  final Value<String> note;
  final Value<int?> colorValue;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BookAnnotationsCompanion({
    this.id = const Value.absent(),
    this.bookSourceId = const Value.absent(),
    this.bookName = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.chapterName = const Value.absent(),
    this.locatorJson = const Value.absent(),
    this.type = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.note = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookAnnotationsCompanion.insert({
    required String id,
    required int bookSourceId,
    required String bookName,
    required int chapterIndex,
    this.chapterName = const Value.absent(),
    required String locatorJson,
    required String type,
    this.excerpt = const Value.absent(),
    this.note = const Value.absent(),
    this.colorValue = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookSourceId = Value(bookSourceId),
        bookName = Value(bookName),
        chapterIndex = Value(chapterIndex),
        locatorJson = Value(locatorJson),
        type = Value(type),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<BookAnnotation> custom({
    Expression<String>? id,
    Expression<int>? bookSourceId,
    Expression<String>? bookName,
    Expression<int>? chapterIndex,
    Expression<String>? chapterName,
    Expression<String>? locatorJson,
    Expression<String>? type,
    Expression<String>? excerpt,
    Expression<String>? note,
    Expression<int>? colorValue,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookSourceId != null) 'book_source_id': bookSourceId,
      if (bookName != null) 'book_name': bookName,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (chapterName != null) 'chapter_name': chapterName,
      if (locatorJson != null) 'locator_json': locatorJson,
      if (type != null) 'type': type,
      if (excerpt != null) 'excerpt': excerpt,
      if (note != null) 'note': note,
      if (colorValue != null) 'color_value': colorValue,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookAnnotationsCompanion copyWith(
      {Value<String>? id,
      Value<int>? bookSourceId,
      Value<String>? bookName,
      Value<int>? chapterIndex,
      Value<String>? chapterName,
      Value<String>? locatorJson,
      Value<String>? type,
      Value<String>? excerpt,
      Value<String>? note,
      Value<int?>? colorValue,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return BookAnnotationsCompanion(
      id: id ?? this.id,
      bookSourceId: bookSourceId ?? this.bookSourceId,
      bookName: bookName ?? this.bookName,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      chapterName: chapterName ?? this.chapterName,
      locatorJson: locatorJson ?? this.locatorJson,
      type: type ?? this.type,
      excerpt: excerpt ?? this.excerpt,
      note: note ?? this.note,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookSourceId.present) {
      map['book_source_id'] = Variable<int>(bookSourceId.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (chapterName.present) {
      map['chapter_name'] = Variable<String>(chapterName.value);
    }
    if (locatorJson.present) {
      map['locator_json'] = Variable<String>(locatorJson.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (excerpt.present) {
      map['excerpt'] = Variable<String>(excerpt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookAnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('bookSourceId: $bookSourceId, ')
          ..write('bookName: $bookName, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterName: $chapterName, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('type: $type, ')
          ..write('excerpt: $excerpt, ')
          ..write('note: $note, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookSourcesTable bookSources = $BookSourcesTable(this);
  late final $RuleBookInfosTable ruleBookInfos = $RuleBookInfosTable(this);
  late final $RuleContentsTable ruleContents = $RuleContentsTable(this);
  late final $RuleSearchsTable ruleSearchs = $RuleSearchsTable(this);
  late final $RuleTocsTable ruleTocs = $RuleTocsTable(this);
  late final $RuleExploresTable ruleExplores = $RuleExploresTable(this);
  late final $BookReadSettingsTable bookReadSettings =
      $BookReadSettingsTable(this);
  late final $BookContentInfosTable bookContentInfos =
      $BookContentInfosTable(this);
  late final $BookSearchInfosTable bookSearchInfos =
      $BookSearchInfosTable(this);
  late final $BookReadProgressesTable bookReadProgresses =
      $BookReadProgressesTable(this);
  late final $SearchHistoriesTable searchHistories =
      $SearchHistoriesTable(this);
  late final $BookReadHistoriesTable bookReadHistories =
      $BookReadHistoriesTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookChaptersTable bookChapters = $BookChaptersTable(this);
  late final $LocalBookFilesTable localBookFiles = $LocalBookFilesTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $ReadingSessionsTable readingSessions =
      $ReadingSessionsTable(this);
  late final $BookAnnotationsTable bookAnnotations =
      $BookAnnotationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        bookSources,
        ruleBookInfos,
        ruleContents,
        ruleSearchs,
        ruleTocs,
        ruleExplores,
        bookReadSettings,
        bookContentInfos,
        bookSearchInfos,
        bookReadProgresses,
        searchHistories,
        bookReadHistories,
        books,
        bookChapters,
        localBookFiles,
        bookmarks,
        readingSessions,
        bookAnnotations
      ];
}

typedef $$BookSourcesTableCreateCompanionBuilder = BookSourcesCompanion
    Function({
  Value<int> id,
  required String bookSourceName,
  Value<String?> bookSourceGroup,
  Value<String?> bookSourceComment,
  Value<String?> jsLib,
  required String bookSourceUrl,
  Value<int?> customOrder,
  Value<String?> bookUrlPattern,
  Value<int?> bookSourceType,
  Value<bool> enabled,
  Value<bool?> enabledCookieJar,
  Value<bool?> enabledExplore,
  Value<String?> header,
  Value<String?> loginUrl,
  Value<String?> lastUpdateTime,
  Value<String?> exploreUrl,
  Value<String?> searchUrl,
  Value<int?> weight,
  Value<bool?> isEnabled,
  Value<String?> concurrentRate,
  Value<int?> respondTime,
  Value<String?> loginUi,
  Value<String?> loginCheckJs,
  Value<String?> coverDecodeJs,
  Value<String?> variableComment,
  Value<String?> exploreScreen,
});
typedef $$BookSourcesTableUpdateCompanionBuilder = BookSourcesCompanion
    Function({
  Value<int> id,
  Value<String> bookSourceName,
  Value<String?> bookSourceGroup,
  Value<String?> bookSourceComment,
  Value<String?> jsLib,
  Value<String> bookSourceUrl,
  Value<int?> customOrder,
  Value<String?> bookUrlPattern,
  Value<int?> bookSourceType,
  Value<bool> enabled,
  Value<bool?> enabledCookieJar,
  Value<bool?> enabledExplore,
  Value<String?> header,
  Value<String?> loginUrl,
  Value<String?> lastUpdateTime,
  Value<String?> exploreUrl,
  Value<String?> searchUrl,
  Value<int?> weight,
  Value<bool?> isEnabled,
  Value<String?> concurrentRate,
  Value<int?> respondTime,
  Value<String?> loginUi,
  Value<String?> loginCheckJs,
  Value<String?> coverDecodeJs,
  Value<String?> variableComment,
  Value<String?> exploreScreen,
});

class $$BookSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $BookSourcesTable> {
  $$BookSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookSourceName => $composableBuilder(
      column: $table.bookSourceName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookSourceGroup => $composableBuilder(
      column: $table.bookSourceGroup,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookSourceComment => $composableBuilder(
      column: $table.bookSourceComment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jsLib => $composableBuilder(
      column: $table.jsLib, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookSourceUrl => $composableBuilder(
      column: $table.bookSourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get customOrder => $composableBuilder(
      column: $table.customOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookUrlPattern => $composableBuilder(
      column: $table.bookUrlPattern,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceType => $composableBuilder(
      column: $table.bookSourceType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabledCookieJar => $composableBuilder(
      column: $table.enabledCookieJar,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabledExplore => $composableBuilder(
      column: $table.enabledExplore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get header => $composableBuilder(
      column: $table.header, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loginUrl => $composableBuilder(
      column: $table.loginUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastUpdateTime => $composableBuilder(
      column: $table.lastUpdateTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exploreUrl => $composableBuilder(
      column: $table.exploreUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get searchUrl => $composableBuilder(
      column: $table.searchUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get concurrentRate => $composableBuilder(
      column: $table.concurrentRate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get respondTime => $composableBuilder(
      column: $table.respondTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loginUi => $composableBuilder(
      column: $table.loginUi, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loginCheckJs => $composableBuilder(
      column: $table.loginCheckJs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverDecodeJs => $composableBuilder(
      column: $table.coverDecodeJs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variableComment => $composableBuilder(
      column: $table.variableComment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exploreScreen => $composableBuilder(
      column: $table.exploreScreen, builder: (column) => ColumnFilters(column));
}

class $$BookSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookSourcesTable> {
  $$BookSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookSourceName => $composableBuilder(
      column: $table.bookSourceName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookSourceGroup => $composableBuilder(
      column: $table.bookSourceGroup,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookSourceComment => $composableBuilder(
      column: $table.bookSourceComment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jsLib => $composableBuilder(
      column: $table.jsLib, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookSourceUrl => $composableBuilder(
      column: $table.bookSourceUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get customOrder => $composableBuilder(
      column: $table.customOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookUrlPattern => $composableBuilder(
      column: $table.bookUrlPattern,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceType => $composableBuilder(
      column: $table.bookSourceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabledCookieJar => $composableBuilder(
      column: $table.enabledCookieJar,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabledExplore => $composableBuilder(
      column: $table.enabledExplore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get header => $composableBuilder(
      column: $table.header, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loginUrl => $composableBuilder(
      column: $table.loginUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastUpdateTime => $composableBuilder(
      column: $table.lastUpdateTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exploreUrl => $composableBuilder(
      column: $table.exploreUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get searchUrl => $composableBuilder(
      column: $table.searchUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get concurrentRate => $composableBuilder(
      column: $table.concurrentRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get respondTime => $composableBuilder(
      column: $table.respondTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loginUi => $composableBuilder(
      column: $table.loginUi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loginCheckJs => $composableBuilder(
      column: $table.loginCheckJs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverDecodeJs => $composableBuilder(
      column: $table.coverDecodeJs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variableComment => $composableBuilder(
      column: $table.variableComment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exploreScreen => $composableBuilder(
      column: $table.exploreScreen,
      builder: (column) => ColumnOrderings(column));
}

class $$BookSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookSourcesTable> {
  $$BookSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookSourceName => $composableBuilder(
      column: $table.bookSourceName, builder: (column) => column);

  GeneratedColumn<String> get bookSourceGroup => $composableBuilder(
      column: $table.bookSourceGroup, builder: (column) => column);

  GeneratedColumn<String> get bookSourceComment => $composableBuilder(
      column: $table.bookSourceComment, builder: (column) => column);

  GeneratedColumn<String> get jsLib =>
      $composableBuilder(column: $table.jsLib, builder: (column) => column);

  GeneratedColumn<String> get bookSourceUrl => $composableBuilder(
      column: $table.bookSourceUrl, builder: (column) => column);

  GeneratedColumn<int> get customOrder => $composableBuilder(
      column: $table.customOrder, builder: (column) => column);

  GeneratedColumn<String> get bookUrlPattern => $composableBuilder(
      column: $table.bookUrlPattern, builder: (column) => column);

  GeneratedColumn<int> get bookSourceType => $composableBuilder(
      column: $table.bookSourceType, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get enabledCookieJar => $composableBuilder(
      column: $table.enabledCookieJar, builder: (column) => column);

  GeneratedColumn<bool> get enabledExplore => $composableBuilder(
      column: $table.enabledExplore, builder: (column) => column);

  GeneratedColumn<String> get header =>
      $composableBuilder(column: $table.header, builder: (column) => column);

  GeneratedColumn<String> get loginUrl =>
      $composableBuilder(column: $table.loginUrl, builder: (column) => column);

  GeneratedColumn<String> get lastUpdateTime => $composableBuilder(
      column: $table.lastUpdateTime, builder: (column) => column);

  GeneratedColumn<String> get exploreUrl => $composableBuilder(
      column: $table.exploreUrl, builder: (column) => column);

  GeneratedColumn<String> get searchUrl =>
      $composableBuilder(column: $table.searchUrl, builder: (column) => column);

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get concurrentRate => $composableBuilder(
      column: $table.concurrentRate, builder: (column) => column);

  GeneratedColumn<int> get respondTime => $composableBuilder(
      column: $table.respondTime, builder: (column) => column);

  GeneratedColumn<String> get loginUi =>
      $composableBuilder(column: $table.loginUi, builder: (column) => column);

  GeneratedColumn<String> get loginCheckJs => $composableBuilder(
      column: $table.loginCheckJs, builder: (column) => column);

  GeneratedColumn<String> get coverDecodeJs => $composableBuilder(
      column: $table.coverDecodeJs, builder: (column) => column);

  GeneratedColumn<String> get variableComment => $composableBuilder(
      column: $table.variableComment, builder: (column) => column);

  GeneratedColumn<String> get exploreScreen => $composableBuilder(
      column: $table.exploreScreen, builder: (column) => column);
}

class $$BookSourcesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookSourcesTable,
    BookSource,
    $$BookSourcesTableFilterComposer,
    $$BookSourcesTableOrderingComposer,
    $$BookSourcesTableAnnotationComposer,
    $$BookSourcesTableCreateCompanionBuilder,
    $$BookSourcesTableUpdateCompanionBuilder,
    (BookSource, BaseReferences<_$AppDatabase, $BookSourcesTable, BookSource>),
    BookSource,
    PrefetchHooks Function()> {
  $$BookSourcesTableTableManager(_$AppDatabase db, $BookSourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> bookSourceName = const Value.absent(),
            Value<String?> bookSourceGroup = const Value.absent(),
            Value<String?> bookSourceComment = const Value.absent(),
            Value<String?> jsLib = const Value.absent(),
            Value<String> bookSourceUrl = const Value.absent(),
            Value<int?> customOrder = const Value.absent(),
            Value<String?> bookUrlPattern = const Value.absent(),
            Value<int?> bookSourceType = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<bool?> enabledCookieJar = const Value.absent(),
            Value<bool?> enabledExplore = const Value.absent(),
            Value<String?> header = const Value.absent(),
            Value<String?> loginUrl = const Value.absent(),
            Value<String?> lastUpdateTime = const Value.absent(),
            Value<String?> exploreUrl = const Value.absent(),
            Value<String?> searchUrl = const Value.absent(),
            Value<int?> weight = const Value.absent(),
            Value<bool?> isEnabled = const Value.absent(),
            Value<String?> concurrentRate = const Value.absent(),
            Value<int?> respondTime = const Value.absent(),
            Value<String?> loginUi = const Value.absent(),
            Value<String?> loginCheckJs = const Value.absent(),
            Value<String?> coverDecodeJs = const Value.absent(),
            Value<String?> variableComment = const Value.absent(),
            Value<String?> exploreScreen = const Value.absent(),
          }) =>
              BookSourcesCompanion(
            id: id,
            bookSourceName: bookSourceName,
            bookSourceGroup: bookSourceGroup,
            bookSourceComment: bookSourceComment,
            jsLib: jsLib,
            bookSourceUrl: bookSourceUrl,
            customOrder: customOrder,
            bookUrlPattern: bookUrlPattern,
            bookSourceType: bookSourceType,
            enabled: enabled,
            enabledCookieJar: enabledCookieJar,
            enabledExplore: enabledExplore,
            header: header,
            loginUrl: loginUrl,
            lastUpdateTime: lastUpdateTime,
            exploreUrl: exploreUrl,
            searchUrl: searchUrl,
            weight: weight,
            isEnabled: isEnabled,
            concurrentRate: concurrentRate,
            respondTime: respondTime,
            loginUi: loginUi,
            loginCheckJs: loginCheckJs,
            coverDecodeJs: coverDecodeJs,
            variableComment: variableComment,
            exploreScreen: exploreScreen,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String bookSourceName,
            Value<String?> bookSourceGroup = const Value.absent(),
            Value<String?> bookSourceComment = const Value.absent(),
            Value<String?> jsLib = const Value.absent(),
            required String bookSourceUrl,
            Value<int?> customOrder = const Value.absent(),
            Value<String?> bookUrlPattern = const Value.absent(),
            Value<int?> bookSourceType = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<bool?> enabledCookieJar = const Value.absent(),
            Value<bool?> enabledExplore = const Value.absent(),
            Value<String?> header = const Value.absent(),
            Value<String?> loginUrl = const Value.absent(),
            Value<String?> lastUpdateTime = const Value.absent(),
            Value<String?> exploreUrl = const Value.absent(),
            Value<String?> searchUrl = const Value.absent(),
            Value<int?> weight = const Value.absent(),
            Value<bool?> isEnabled = const Value.absent(),
            Value<String?> concurrentRate = const Value.absent(),
            Value<int?> respondTime = const Value.absent(),
            Value<String?> loginUi = const Value.absent(),
            Value<String?> loginCheckJs = const Value.absent(),
            Value<String?> coverDecodeJs = const Value.absent(),
            Value<String?> variableComment = const Value.absent(),
            Value<String?> exploreScreen = const Value.absent(),
          }) =>
              BookSourcesCompanion.insert(
            id: id,
            bookSourceName: bookSourceName,
            bookSourceGroup: bookSourceGroup,
            bookSourceComment: bookSourceComment,
            jsLib: jsLib,
            bookSourceUrl: bookSourceUrl,
            customOrder: customOrder,
            bookUrlPattern: bookUrlPattern,
            bookSourceType: bookSourceType,
            enabled: enabled,
            enabledCookieJar: enabledCookieJar,
            enabledExplore: enabledExplore,
            header: header,
            loginUrl: loginUrl,
            lastUpdateTime: lastUpdateTime,
            exploreUrl: exploreUrl,
            searchUrl: searchUrl,
            weight: weight,
            isEnabled: isEnabled,
            concurrentRate: concurrentRate,
            respondTime: respondTime,
            loginUi: loginUi,
            loginCheckJs: loginCheckJs,
            coverDecodeJs: coverDecodeJs,
            variableComment: variableComment,
            exploreScreen: exploreScreen,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookSourcesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookSourcesTable,
    BookSource,
    $$BookSourcesTableFilterComposer,
    $$BookSourcesTableOrderingComposer,
    $$BookSourcesTableAnnotationComposer,
    $$BookSourcesTableCreateCompanionBuilder,
    $$BookSourcesTableUpdateCompanionBuilder,
    (BookSource, BaseReferences<_$AppDatabase, $BookSourcesTable, BookSource>),
    BookSource,
    PrefetchHooks Function()>;
typedef $$RuleBookInfosTableCreateCompanionBuilder = RuleBookInfosCompanion
    Function({
  Value<int> id,
  required int bookSourceId,
  Value<String?> author,
  Value<String?> coverUrl,
  Value<String?> init,
  Value<String?> intro,
  Value<String?> kind,
  Value<String?> lastChapter,
  Value<String?> name,
  Value<String?> tocUrl,
  Value<String?> wordCount,
  Value<String?> lastReadChapter,
  Value<String?> canReName,
  Value<String?> downloadUrls,
  Value<String?> updateTime,
});
typedef $$RuleBookInfosTableUpdateCompanionBuilder = RuleBookInfosCompanion
    Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String?> author,
  Value<String?> coverUrl,
  Value<String?> init,
  Value<String?> intro,
  Value<String?> kind,
  Value<String?> lastChapter,
  Value<String?> name,
  Value<String?> tocUrl,
  Value<String?> wordCount,
  Value<String?> lastReadChapter,
  Value<String?> canReName,
  Value<String?> downloadUrls,
  Value<String?> updateTime,
});

class $$RuleBookInfosTableFilterComposer
    extends Composer<_$AppDatabase, $RuleBookInfosTable> {
  $$RuleBookInfosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get init => $composableBuilder(
      column: $table.init, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tocUrl => $composableBuilder(
      column: $table.tocUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastReadChapter => $composableBuilder(
      column: $table.lastReadChapter,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canReName => $composableBuilder(
      column: $table.canReName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get downloadUrls => $composableBuilder(
      column: $table.downloadUrls, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnFilters(column));
}

class $$RuleBookInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $RuleBookInfosTable> {
  $$RuleBookInfosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get init => $composableBuilder(
      column: $table.init, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tocUrl => $composableBuilder(
      column: $table.tocUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastReadChapter => $composableBuilder(
      column: $table.lastReadChapter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canReName => $composableBuilder(
      column: $table.canReName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get downloadUrls => $composableBuilder(
      column: $table.downloadUrls,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnOrderings(column));
}

class $$RuleBookInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RuleBookInfosTable> {
  $$RuleBookInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get init =>
      $composableBuilder(column: $table.init, builder: (column) => column);

  GeneratedColumn<String> get intro =>
      $composableBuilder(column: $table.intro, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get tocUrl =>
      $composableBuilder(column: $table.tocUrl, builder: (column) => column);

  GeneratedColumn<String> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<String> get lastReadChapter => $composableBuilder(
      column: $table.lastReadChapter, builder: (column) => column);

  GeneratedColumn<String> get canReName =>
      $composableBuilder(column: $table.canReName, builder: (column) => column);

  GeneratedColumn<String> get downloadUrls => $composableBuilder(
      column: $table.downloadUrls, builder: (column) => column);

  GeneratedColumn<String> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => column);
}

class $$RuleBookInfosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RuleBookInfosTable,
    RuleBookInfo,
    $$RuleBookInfosTableFilterComposer,
    $$RuleBookInfosTableOrderingComposer,
    $$RuleBookInfosTableAnnotationComposer,
    $$RuleBookInfosTableCreateCompanionBuilder,
    $$RuleBookInfosTableUpdateCompanionBuilder,
    (
      RuleBookInfo,
      BaseReferences<_$AppDatabase, $RuleBookInfosTable, RuleBookInfo>
    ),
    RuleBookInfo,
    PrefetchHooks Function()> {
  $$RuleBookInfosTableTableManager(_$AppDatabase db, $RuleBookInfosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RuleBookInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RuleBookInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RuleBookInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> init = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> kind = const Value.absent(),
            Value<String?> lastChapter = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> tocUrl = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
            Value<String?> lastReadChapter = const Value.absent(),
            Value<String?> canReName = const Value.absent(),
            Value<String?> downloadUrls = const Value.absent(),
            Value<String?> updateTime = const Value.absent(),
          }) =>
              RuleBookInfosCompanion(
            id: id,
            bookSourceId: bookSourceId,
            author: author,
            coverUrl: coverUrl,
            init: init,
            intro: intro,
            kind: kind,
            lastChapter: lastChapter,
            name: name,
            tocUrl: tocUrl,
            wordCount: wordCount,
            lastReadChapter: lastReadChapter,
            canReName: canReName,
            downloadUrls: downloadUrls,
            updateTime: updateTime,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            Value<String?> author = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> init = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> kind = const Value.absent(),
            Value<String?> lastChapter = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> tocUrl = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
            Value<String?> lastReadChapter = const Value.absent(),
            Value<String?> canReName = const Value.absent(),
            Value<String?> downloadUrls = const Value.absent(),
            Value<String?> updateTime = const Value.absent(),
          }) =>
              RuleBookInfosCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            author: author,
            coverUrl: coverUrl,
            init: init,
            intro: intro,
            kind: kind,
            lastChapter: lastChapter,
            name: name,
            tocUrl: tocUrl,
            wordCount: wordCount,
            lastReadChapter: lastReadChapter,
            canReName: canReName,
            downloadUrls: downloadUrls,
            updateTime: updateTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RuleBookInfosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RuleBookInfosTable,
    RuleBookInfo,
    $$RuleBookInfosTableFilterComposer,
    $$RuleBookInfosTableOrderingComposer,
    $$RuleBookInfosTableAnnotationComposer,
    $$RuleBookInfosTableCreateCompanionBuilder,
    $$RuleBookInfosTableUpdateCompanionBuilder,
    (
      RuleBookInfo,
      BaseReferences<_$AppDatabase, $RuleBookInfosTable, RuleBookInfo>
    ),
    RuleBookInfo,
    PrefetchHooks Function()>;
typedef $$RuleContentsTableCreateCompanionBuilder = RuleContentsCompanion
    Function({
  Value<int> id,
  required int bookSourceId,
  Value<String?> content,
  Value<String?> nextContentUrl,
  Value<String?> replaceRegex,
  Value<String?> title,
  Value<String?> webJs,
  Value<String?> sourceRegex,
  Value<String?> imageStyle,
  Value<String?> imageDecode,
  Value<String?> payAction,
});
typedef $$RuleContentsTableUpdateCompanionBuilder = RuleContentsCompanion
    Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String?> content,
  Value<String?> nextContentUrl,
  Value<String?> replaceRegex,
  Value<String?> title,
  Value<String?> webJs,
  Value<String?> sourceRegex,
  Value<String?> imageStyle,
  Value<String?> imageDecode,
  Value<String?> payAction,
});

class $$RuleContentsTableFilterComposer
    extends Composer<_$AppDatabase, $RuleContentsTable> {
  $$RuleContentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nextContentUrl => $composableBuilder(
      column: $table.nextContentUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replaceRegex => $composableBuilder(
      column: $table.replaceRegex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get webJs => $composableBuilder(
      column: $table.webJs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceRegex => $composableBuilder(
      column: $table.sourceRegex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageStyle => $composableBuilder(
      column: $table.imageStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageDecode => $composableBuilder(
      column: $table.imageDecode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payAction => $composableBuilder(
      column: $table.payAction, builder: (column) => ColumnFilters(column));
}

class $$RuleContentsTableOrderingComposer
    extends Composer<_$AppDatabase, $RuleContentsTable> {
  $$RuleContentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nextContentUrl => $composableBuilder(
      column: $table.nextContentUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replaceRegex => $composableBuilder(
      column: $table.replaceRegex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get webJs => $composableBuilder(
      column: $table.webJs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceRegex => $composableBuilder(
      column: $table.sourceRegex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageStyle => $composableBuilder(
      column: $table.imageStyle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageDecode => $composableBuilder(
      column: $table.imageDecode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payAction => $composableBuilder(
      column: $table.payAction, builder: (column) => ColumnOrderings(column));
}

class $$RuleContentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RuleContentsTable> {
  $$RuleContentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get nextContentUrl => $composableBuilder(
      column: $table.nextContentUrl, builder: (column) => column);

  GeneratedColumn<String> get replaceRegex => $composableBuilder(
      column: $table.replaceRegex, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get webJs =>
      $composableBuilder(column: $table.webJs, builder: (column) => column);

  GeneratedColumn<String> get sourceRegex => $composableBuilder(
      column: $table.sourceRegex, builder: (column) => column);

  GeneratedColumn<String> get imageStyle => $composableBuilder(
      column: $table.imageStyle, builder: (column) => column);

  GeneratedColumn<String> get imageDecode => $composableBuilder(
      column: $table.imageDecode, builder: (column) => column);

  GeneratedColumn<String> get payAction =>
      $composableBuilder(column: $table.payAction, builder: (column) => column);
}

class $$RuleContentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RuleContentsTable,
    RuleContent,
    $$RuleContentsTableFilterComposer,
    $$RuleContentsTableOrderingComposer,
    $$RuleContentsTableAnnotationComposer,
    $$RuleContentsTableCreateCompanionBuilder,
    $$RuleContentsTableUpdateCompanionBuilder,
    (
      RuleContent,
      BaseReferences<_$AppDatabase, $RuleContentsTable, RuleContent>
    ),
    RuleContent,
    PrefetchHooks Function()> {
  $$RuleContentsTableTableManager(_$AppDatabase db, $RuleContentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RuleContentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RuleContentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RuleContentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> nextContentUrl = const Value.absent(),
            Value<String?> replaceRegex = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> webJs = const Value.absent(),
            Value<String?> sourceRegex = const Value.absent(),
            Value<String?> imageStyle = const Value.absent(),
            Value<String?> imageDecode = const Value.absent(),
            Value<String?> payAction = const Value.absent(),
          }) =>
              RuleContentsCompanion(
            id: id,
            bookSourceId: bookSourceId,
            content: content,
            nextContentUrl: nextContentUrl,
            replaceRegex: replaceRegex,
            title: title,
            webJs: webJs,
            sourceRegex: sourceRegex,
            imageStyle: imageStyle,
            imageDecode: imageDecode,
            payAction: payAction,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            Value<String?> content = const Value.absent(),
            Value<String?> nextContentUrl = const Value.absent(),
            Value<String?> replaceRegex = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> webJs = const Value.absent(),
            Value<String?> sourceRegex = const Value.absent(),
            Value<String?> imageStyle = const Value.absent(),
            Value<String?> imageDecode = const Value.absent(),
            Value<String?> payAction = const Value.absent(),
          }) =>
              RuleContentsCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            content: content,
            nextContentUrl: nextContentUrl,
            replaceRegex: replaceRegex,
            title: title,
            webJs: webJs,
            sourceRegex: sourceRegex,
            imageStyle: imageStyle,
            imageDecode: imageDecode,
            payAction: payAction,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RuleContentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RuleContentsTable,
    RuleContent,
    $$RuleContentsTableFilterComposer,
    $$RuleContentsTableOrderingComposer,
    $$RuleContentsTableAnnotationComposer,
    $$RuleContentsTableCreateCompanionBuilder,
    $$RuleContentsTableUpdateCompanionBuilder,
    (
      RuleContent,
      BaseReferences<_$AppDatabase, $RuleContentsTable, RuleContent>
    ),
    RuleContent,
    PrefetchHooks Function()>;
typedef $$RuleSearchsTableCreateCompanionBuilder = RuleSearchsCompanion
    Function({
  Value<int> id,
  required int bookSourceId,
  Value<String?> name,
  Value<String?> author,
  Value<String?> bookList,
  Value<String?> bookUrl,
  Value<String?> coverUrl,
  Value<String?> intro,
  Value<String?> kind,
  Value<String?> lastChapter,
  Value<String?> wordCount,
  Value<String?> tocUrl,
  Value<String?> checkKeyWord,
  Value<String?> updateTime,
});
typedef $$RuleSearchsTableUpdateCompanionBuilder = RuleSearchsCompanion
    Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String?> name,
  Value<String?> author,
  Value<String?> bookList,
  Value<String?> bookUrl,
  Value<String?> coverUrl,
  Value<String?> intro,
  Value<String?> kind,
  Value<String?> lastChapter,
  Value<String?> wordCount,
  Value<String?> tocUrl,
  Value<String?> checkKeyWord,
  Value<String?> updateTime,
});

class $$RuleSearchsTableFilterComposer
    extends Composer<_$AppDatabase, $RuleSearchsTable> {
  $$RuleSearchsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookList => $composableBuilder(
      column: $table.bookList, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookUrl => $composableBuilder(
      column: $table.bookUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tocUrl => $composableBuilder(
      column: $table.tocUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checkKeyWord => $composableBuilder(
      column: $table.checkKeyWord, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnFilters(column));
}

class $$RuleSearchsTableOrderingComposer
    extends Composer<_$AppDatabase, $RuleSearchsTable> {
  $$RuleSearchsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookList => $composableBuilder(
      column: $table.bookList, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookUrl => $composableBuilder(
      column: $table.bookUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tocUrl => $composableBuilder(
      column: $table.tocUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checkKeyWord => $composableBuilder(
      column: $table.checkKeyWord,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnOrderings(column));
}

class $$RuleSearchsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RuleSearchsTable> {
  $$RuleSearchsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get bookList =>
      $composableBuilder(column: $table.bookList, builder: (column) => column);

  GeneratedColumn<String> get bookUrl =>
      $composableBuilder(column: $table.bookUrl, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get intro =>
      $composableBuilder(column: $table.intro, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => column);

  GeneratedColumn<String> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<String> get tocUrl =>
      $composableBuilder(column: $table.tocUrl, builder: (column) => column);

  GeneratedColumn<String> get checkKeyWord => $composableBuilder(
      column: $table.checkKeyWord, builder: (column) => column);

  GeneratedColumn<String> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => column);
}

class $$RuleSearchsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RuleSearchsTable,
    RuleSearch,
    $$RuleSearchsTableFilterComposer,
    $$RuleSearchsTableOrderingComposer,
    $$RuleSearchsTableAnnotationComposer,
    $$RuleSearchsTableCreateCompanionBuilder,
    $$RuleSearchsTableUpdateCompanionBuilder,
    (RuleSearch, BaseReferences<_$AppDatabase, $RuleSearchsTable, RuleSearch>),
    RuleSearch,
    PrefetchHooks Function()> {
  $$RuleSearchsTableTableManager(_$AppDatabase db, $RuleSearchsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RuleSearchsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RuleSearchsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RuleSearchsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> bookList = const Value.absent(),
            Value<String?> bookUrl = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> kind = const Value.absent(),
            Value<String?> lastChapter = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
            Value<String?> tocUrl = const Value.absent(),
            Value<String?> checkKeyWord = const Value.absent(),
            Value<String?> updateTime = const Value.absent(),
          }) =>
              RuleSearchsCompanion(
            id: id,
            bookSourceId: bookSourceId,
            name: name,
            author: author,
            bookList: bookList,
            bookUrl: bookUrl,
            coverUrl: coverUrl,
            intro: intro,
            kind: kind,
            lastChapter: lastChapter,
            wordCount: wordCount,
            tocUrl: tocUrl,
            checkKeyWord: checkKeyWord,
            updateTime: updateTime,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            Value<String?> name = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> bookList = const Value.absent(),
            Value<String?> bookUrl = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> kind = const Value.absent(),
            Value<String?> lastChapter = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
            Value<String?> tocUrl = const Value.absent(),
            Value<String?> checkKeyWord = const Value.absent(),
            Value<String?> updateTime = const Value.absent(),
          }) =>
              RuleSearchsCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            name: name,
            author: author,
            bookList: bookList,
            bookUrl: bookUrl,
            coverUrl: coverUrl,
            intro: intro,
            kind: kind,
            lastChapter: lastChapter,
            wordCount: wordCount,
            tocUrl: tocUrl,
            checkKeyWord: checkKeyWord,
            updateTime: updateTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RuleSearchsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RuleSearchsTable,
    RuleSearch,
    $$RuleSearchsTableFilterComposer,
    $$RuleSearchsTableOrderingComposer,
    $$RuleSearchsTableAnnotationComposer,
    $$RuleSearchsTableCreateCompanionBuilder,
    $$RuleSearchsTableUpdateCompanionBuilder,
    (RuleSearch, BaseReferences<_$AppDatabase, $RuleSearchsTable, RuleSearch>),
    RuleSearch,
    PrefetchHooks Function()>;
typedef $$RuleTocsTableCreateCompanionBuilder = RuleTocsCompanion Function({
  Value<int> id,
  required int bookSourceId,
  Value<String?> chapterList,
  Value<String?> chapterName,
  Value<String?> chapterUrl,
  Value<String?> nextTocUrl,
  Value<String?> preUpdateJs,
  Value<String?> formatJs,
  Value<String?> isVolume,
  Value<String?> isVip,
  Value<String?> isPay,
  Value<String?> updateTime,
});
typedef $$RuleTocsTableUpdateCompanionBuilder = RuleTocsCompanion Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String?> chapterList,
  Value<String?> chapterName,
  Value<String?> chapterUrl,
  Value<String?> nextTocUrl,
  Value<String?> preUpdateJs,
  Value<String?> formatJs,
  Value<String?> isVolume,
  Value<String?> isVip,
  Value<String?> isPay,
  Value<String?> updateTime,
});

class $$RuleTocsTableFilterComposer
    extends Composer<_$AppDatabase, $RuleTocsTable> {
  $$RuleTocsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterList => $composableBuilder(
      column: $table.chapterList, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterUrl => $composableBuilder(
      column: $table.chapterUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nextTocUrl => $composableBuilder(
      column: $table.nextTocUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preUpdateJs => $composableBuilder(
      column: $table.preUpdateJs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatJs => $composableBuilder(
      column: $table.formatJs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get isVolume => $composableBuilder(
      column: $table.isVolume, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get isVip => $composableBuilder(
      column: $table.isVip, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get isPay => $composableBuilder(
      column: $table.isPay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnFilters(column));
}

class $$RuleTocsTableOrderingComposer
    extends Composer<_$AppDatabase, $RuleTocsTable> {
  $$RuleTocsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterList => $composableBuilder(
      column: $table.chapterList, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterUrl => $composableBuilder(
      column: $table.chapterUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nextTocUrl => $composableBuilder(
      column: $table.nextTocUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preUpdateJs => $composableBuilder(
      column: $table.preUpdateJs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatJs => $composableBuilder(
      column: $table.formatJs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get isVolume => $composableBuilder(
      column: $table.isVolume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get isVip => $composableBuilder(
      column: $table.isVip, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get isPay => $composableBuilder(
      column: $table.isPay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnOrderings(column));
}

class $$RuleTocsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RuleTocsTable> {
  $$RuleTocsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get chapterList => $composableBuilder(
      column: $table.chapterList, builder: (column) => column);

  GeneratedColumn<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => column);

  GeneratedColumn<String> get chapterUrl => $composableBuilder(
      column: $table.chapterUrl, builder: (column) => column);

  GeneratedColumn<String> get nextTocUrl => $composableBuilder(
      column: $table.nextTocUrl, builder: (column) => column);

  GeneratedColumn<String> get preUpdateJs => $composableBuilder(
      column: $table.preUpdateJs, builder: (column) => column);

  GeneratedColumn<String> get formatJs =>
      $composableBuilder(column: $table.formatJs, builder: (column) => column);

  GeneratedColumn<String> get isVolume =>
      $composableBuilder(column: $table.isVolume, builder: (column) => column);

  GeneratedColumn<String> get isVip =>
      $composableBuilder(column: $table.isVip, builder: (column) => column);

  GeneratedColumn<String> get isPay =>
      $composableBuilder(column: $table.isPay, builder: (column) => column);

  GeneratedColumn<String> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => column);
}

class $$RuleTocsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RuleTocsTable,
    RuleToc,
    $$RuleTocsTableFilterComposer,
    $$RuleTocsTableOrderingComposer,
    $$RuleTocsTableAnnotationComposer,
    $$RuleTocsTableCreateCompanionBuilder,
    $$RuleTocsTableUpdateCompanionBuilder,
    (RuleToc, BaseReferences<_$AppDatabase, $RuleTocsTable, RuleToc>),
    RuleToc,
    PrefetchHooks Function()> {
  $$RuleTocsTableTableManager(_$AppDatabase db, $RuleTocsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RuleTocsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RuleTocsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RuleTocsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String?> chapterList = const Value.absent(),
            Value<String?> chapterName = const Value.absent(),
            Value<String?> chapterUrl = const Value.absent(),
            Value<String?> nextTocUrl = const Value.absent(),
            Value<String?> preUpdateJs = const Value.absent(),
            Value<String?> formatJs = const Value.absent(),
            Value<String?> isVolume = const Value.absent(),
            Value<String?> isVip = const Value.absent(),
            Value<String?> isPay = const Value.absent(),
            Value<String?> updateTime = const Value.absent(),
          }) =>
              RuleTocsCompanion(
            id: id,
            bookSourceId: bookSourceId,
            chapterList: chapterList,
            chapterName: chapterName,
            chapterUrl: chapterUrl,
            nextTocUrl: nextTocUrl,
            preUpdateJs: preUpdateJs,
            formatJs: formatJs,
            isVolume: isVolume,
            isVip: isVip,
            isPay: isPay,
            updateTime: updateTime,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            Value<String?> chapterList = const Value.absent(),
            Value<String?> chapterName = const Value.absent(),
            Value<String?> chapterUrl = const Value.absent(),
            Value<String?> nextTocUrl = const Value.absent(),
            Value<String?> preUpdateJs = const Value.absent(),
            Value<String?> formatJs = const Value.absent(),
            Value<String?> isVolume = const Value.absent(),
            Value<String?> isVip = const Value.absent(),
            Value<String?> isPay = const Value.absent(),
            Value<String?> updateTime = const Value.absent(),
          }) =>
              RuleTocsCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            chapterList: chapterList,
            chapterName: chapterName,
            chapterUrl: chapterUrl,
            nextTocUrl: nextTocUrl,
            preUpdateJs: preUpdateJs,
            formatJs: formatJs,
            isVolume: isVolume,
            isVip: isVip,
            isPay: isPay,
            updateTime: updateTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RuleTocsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RuleTocsTable,
    RuleToc,
    $$RuleTocsTableFilterComposer,
    $$RuleTocsTableOrderingComposer,
    $$RuleTocsTableAnnotationComposer,
    $$RuleTocsTableCreateCompanionBuilder,
    $$RuleTocsTableUpdateCompanionBuilder,
    (RuleToc, BaseReferences<_$AppDatabase, $RuleTocsTable, RuleToc>),
    RuleToc,
    PrefetchHooks Function()>;
typedef $$RuleExploresTableCreateCompanionBuilder = RuleExploresCompanion
    Function({
  Value<int> id,
  required int bookSourceId,
  Value<String?> bookList,
  Value<String?> name,
  Value<String?> author,
  Value<String?> bookUrl,
  Value<String?> coverUrl,
  Value<String?> intro,
  Value<String?> kind,
  Value<String?> lastChapter,
  Value<String?> wordCount,
});
typedef $$RuleExploresTableUpdateCompanionBuilder = RuleExploresCompanion
    Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String?> bookList,
  Value<String?> name,
  Value<String?> author,
  Value<String?> bookUrl,
  Value<String?> coverUrl,
  Value<String?> intro,
  Value<String?> kind,
  Value<String?> lastChapter,
  Value<String?> wordCount,
});

class $$RuleExploresTableFilterComposer
    extends Composer<_$AppDatabase, $RuleExploresTable> {
  $$RuleExploresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookList => $composableBuilder(
      column: $table.bookList, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookUrl => $composableBuilder(
      column: $table.bookUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnFilters(column));
}

class $$RuleExploresTableOrderingComposer
    extends Composer<_$AppDatabase, $RuleExploresTable> {
  $$RuleExploresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookList => $composableBuilder(
      column: $table.bookList, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookUrl => $composableBuilder(
      column: $table.bookUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnOrderings(column));
}

class $$RuleExploresTableAnnotationComposer
    extends Composer<_$AppDatabase, $RuleExploresTable> {
  $$RuleExploresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get bookList =>
      $composableBuilder(column: $table.bookList, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get bookUrl =>
      $composableBuilder(column: $table.bookUrl, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get intro =>
      $composableBuilder(column: $table.intro, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => column);

  GeneratedColumn<String> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);
}

class $$RuleExploresTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RuleExploresTable,
    RuleExplore,
    $$RuleExploresTableFilterComposer,
    $$RuleExploresTableOrderingComposer,
    $$RuleExploresTableAnnotationComposer,
    $$RuleExploresTableCreateCompanionBuilder,
    $$RuleExploresTableUpdateCompanionBuilder,
    (
      RuleExplore,
      BaseReferences<_$AppDatabase, $RuleExploresTable, RuleExplore>
    ),
    RuleExplore,
    PrefetchHooks Function()> {
  $$RuleExploresTableTableManager(_$AppDatabase db, $RuleExploresTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RuleExploresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RuleExploresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RuleExploresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String?> bookList = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> bookUrl = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> kind = const Value.absent(),
            Value<String?> lastChapter = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
          }) =>
              RuleExploresCompanion(
            id: id,
            bookSourceId: bookSourceId,
            bookList: bookList,
            name: name,
            author: author,
            bookUrl: bookUrl,
            coverUrl: coverUrl,
            intro: intro,
            kind: kind,
            lastChapter: lastChapter,
            wordCount: wordCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            Value<String?> bookList = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> bookUrl = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> kind = const Value.absent(),
            Value<String?> lastChapter = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
          }) =>
              RuleExploresCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            bookList: bookList,
            name: name,
            author: author,
            bookUrl: bookUrl,
            coverUrl: coverUrl,
            intro: intro,
            kind: kind,
            lastChapter: lastChapter,
            wordCount: wordCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RuleExploresTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RuleExploresTable,
    RuleExplore,
    $$RuleExploresTableFilterComposer,
    $$RuleExploresTableOrderingComposer,
    $$RuleExploresTableAnnotationComposer,
    $$RuleExploresTableCreateCompanionBuilder,
    $$RuleExploresTableUpdateCompanionBuilder,
    (
      RuleExplore,
      BaseReferences<_$AppDatabase, $RuleExploresTable, RuleExplore>
    ),
    RuleExplore,
    PrefetchHooks Function()>;
typedef $$BookReadSettingsTableCreateCompanionBuilder
    = BookReadSettingsCompanion Function({
  Value<int> id,
  required DateTime updateTime,
  Value<double?> fontSize,
  Value<double?> fontHeight,
  Value<double?> wordSpacing,
  Value<double?> letterSpacing,
  Value<String?> fontFamily,
  Value<double?> brightness,
  Value<int?> backgroundColor,
  Value<String?> pageTurnType,
  Value<bool?> isEyeProtectionMode,
  Value<double?> ttsRate,
  Value<double?> ttsPitch,
  Value<double?> ttsVolume,
  Value<String?> ttsVoiceName,
  Value<bool?> ttsAutoNextPage,
  Value<bool?> ttsAutoNextChapter,
  Value<bool?> ttsResumeAfterInterrupt,
  Value<String?> themeMode,
  Value<String?> bookshelfLayout,
});
typedef $$BookReadSettingsTableUpdateCompanionBuilder
    = BookReadSettingsCompanion Function({
  Value<int> id,
  Value<DateTime> updateTime,
  Value<double?> fontSize,
  Value<double?> fontHeight,
  Value<double?> wordSpacing,
  Value<double?> letterSpacing,
  Value<String?> fontFamily,
  Value<double?> brightness,
  Value<int?> backgroundColor,
  Value<String?> pageTurnType,
  Value<bool?> isEyeProtectionMode,
  Value<double?> ttsRate,
  Value<double?> ttsPitch,
  Value<double?> ttsVolume,
  Value<String?> ttsVoiceName,
  Value<bool?> ttsAutoNextPage,
  Value<bool?> ttsAutoNextChapter,
  Value<bool?> ttsResumeAfterInterrupt,
  Value<String?> themeMode,
  Value<String?> bookshelfLayout,
});

class $$BookReadSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $BookReadSettingsTable> {
  $$BookReadSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fontHeight => $composableBuilder(
      column: $table.fontHeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get wordSpacing => $composableBuilder(
      column: $table.wordSpacing, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get letterSpacing => $composableBuilder(
      column: $table.letterSpacing, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get brightness => $composableBuilder(
      column: $table.brightness, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get backgroundColor => $composableBuilder(
      column: $table.backgroundColor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pageTurnType => $composableBuilder(
      column: $table.pageTurnType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEyeProtectionMode => $composableBuilder(
      column: $table.isEyeProtectionMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ttsRate => $composableBuilder(
      column: $table.ttsRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ttsPitch => $composableBuilder(
      column: $table.ttsPitch, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ttsVolume => $composableBuilder(
      column: $table.ttsVolume, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ttsVoiceName => $composableBuilder(
      column: $table.ttsVoiceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ttsAutoNextPage => $composableBuilder(
      column: $table.ttsAutoNextPage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ttsAutoNextChapter => $composableBuilder(
      column: $table.ttsAutoNextChapter,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ttsResumeAfterInterrupt => $composableBuilder(
      column: $table.ttsResumeAfterInterrupt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookshelfLayout => $composableBuilder(
      column: $table.bookshelfLayout,
      builder: (column) => ColumnFilters(column));
}

class $$BookReadSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookReadSettingsTable> {
  $$BookReadSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fontHeight => $composableBuilder(
      column: $table.fontHeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get wordSpacing => $composableBuilder(
      column: $table.wordSpacing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get letterSpacing => $composableBuilder(
      column: $table.letterSpacing,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get brightness => $composableBuilder(
      column: $table.brightness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get backgroundColor => $composableBuilder(
      column: $table.backgroundColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pageTurnType => $composableBuilder(
      column: $table.pageTurnType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEyeProtectionMode => $composableBuilder(
      column: $table.isEyeProtectionMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ttsRate => $composableBuilder(
      column: $table.ttsRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ttsPitch => $composableBuilder(
      column: $table.ttsPitch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ttsVolume => $composableBuilder(
      column: $table.ttsVolume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ttsVoiceName => $composableBuilder(
      column: $table.ttsVoiceName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ttsAutoNextPage => $composableBuilder(
      column: $table.ttsAutoNextPage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ttsAutoNextChapter => $composableBuilder(
      column: $table.ttsAutoNextChapter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ttsResumeAfterInterrupt => $composableBuilder(
      column: $table.ttsResumeAfterInterrupt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookshelfLayout => $composableBuilder(
      column: $table.bookshelfLayout,
      builder: (column) => ColumnOrderings(column));
}

class $$BookReadSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookReadSettingsTable> {
  $$BookReadSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => column);

  GeneratedColumn<double> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<double> get fontHeight => $composableBuilder(
      column: $table.fontHeight, builder: (column) => column);

  GeneratedColumn<double> get wordSpacing => $composableBuilder(
      column: $table.wordSpacing, builder: (column) => column);

  GeneratedColumn<double> get letterSpacing => $composableBuilder(
      column: $table.letterSpacing, builder: (column) => column);

  GeneratedColumn<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => column);

  GeneratedColumn<double> get brightness => $composableBuilder(
      column: $table.brightness, builder: (column) => column);

  GeneratedColumn<int> get backgroundColor => $composableBuilder(
      column: $table.backgroundColor, builder: (column) => column);

  GeneratedColumn<String> get pageTurnType => $composableBuilder(
      column: $table.pageTurnType, builder: (column) => column);

  GeneratedColumn<bool> get isEyeProtectionMode => $composableBuilder(
      column: $table.isEyeProtectionMode, builder: (column) => column);

  GeneratedColumn<double> get ttsRate =>
      $composableBuilder(column: $table.ttsRate, builder: (column) => column);

  GeneratedColumn<double> get ttsPitch =>
      $composableBuilder(column: $table.ttsPitch, builder: (column) => column);

  GeneratedColumn<double> get ttsVolume =>
      $composableBuilder(column: $table.ttsVolume, builder: (column) => column);

  GeneratedColumn<String> get ttsVoiceName => $composableBuilder(
      column: $table.ttsVoiceName, builder: (column) => column);

  GeneratedColumn<bool> get ttsAutoNextPage => $composableBuilder(
      column: $table.ttsAutoNextPage, builder: (column) => column);

  GeneratedColumn<bool> get ttsAutoNextChapter => $composableBuilder(
      column: $table.ttsAutoNextChapter, builder: (column) => column);

  GeneratedColumn<bool> get ttsResumeAfterInterrupt => $composableBuilder(
      column: $table.ttsResumeAfterInterrupt, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get bookshelfLayout => $composableBuilder(
      column: $table.bookshelfLayout, builder: (column) => column);
}

class $$BookReadSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookReadSettingsTable,
    BookReadSetting,
    $$BookReadSettingsTableFilterComposer,
    $$BookReadSettingsTableOrderingComposer,
    $$BookReadSettingsTableAnnotationComposer,
    $$BookReadSettingsTableCreateCompanionBuilder,
    $$BookReadSettingsTableUpdateCompanionBuilder,
    (
      BookReadSetting,
      BaseReferences<_$AppDatabase, $BookReadSettingsTable, BookReadSetting>
    ),
    BookReadSetting,
    PrefetchHooks Function()> {
  $$BookReadSettingsTableTableManager(
      _$AppDatabase db, $BookReadSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookReadSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookReadSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookReadSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> updateTime = const Value.absent(),
            Value<double?> fontSize = const Value.absent(),
            Value<double?> fontHeight = const Value.absent(),
            Value<double?> wordSpacing = const Value.absent(),
            Value<double?> letterSpacing = const Value.absent(),
            Value<String?> fontFamily = const Value.absent(),
            Value<double?> brightness = const Value.absent(),
            Value<int?> backgroundColor = const Value.absent(),
            Value<String?> pageTurnType = const Value.absent(),
            Value<bool?> isEyeProtectionMode = const Value.absent(),
            Value<double?> ttsRate = const Value.absent(),
            Value<double?> ttsPitch = const Value.absent(),
            Value<double?> ttsVolume = const Value.absent(),
            Value<String?> ttsVoiceName = const Value.absent(),
            Value<bool?> ttsAutoNextPage = const Value.absent(),
            Value<bool?> ttsAutoNextChapter = const Value.absent(),
            Value<bool?> ttsResumeAfterInterrupt = const Value.absent(),
            Value<String?> themeMode = const Value.absent(),
            Value<String?> bookshelfLayout = const Value.absent(),
          }) =>
              BookReadSettingsCompanion(
            id: id,
            updateTime: updateTime,
            fontSize: fontSize,
            fontHeight: fontHeight,
            wordSpacing: wordSpacing,
            letterSpacing: letterSpacing,
            fontFamily: fontFamily,
            brightness: brightness,
            backgroundColor: backgroundColor,
            pageTurnType: pageTurnType,
            isEyeProtectionMode: isEyeProtectionMode,
            ttsRate: ttsRate,
            ttsPitch: ttsPitch,
            ttsVolume: ttsVolume,
            ttsVoiceName: ttsVoiceName,
            ttsAutoNextPage: ttsAutoNextPage,
            ttsAutoNextChapter: ttsAutoNextChapter,
            ttsResumeAfterInterrupt: ttsResumeAfterInterrupt,
            themeMode: themeMode,
            bookshelfLayout: bookshelfLayout,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime updateTime,
            Value<double?> fontSize = const Value.absent(),
            Value<double?> fontHeight = const Value.absent(),
            Value<double?> wordSpacing = const Value.absent(),
            Value<double?> letterSpacing = const Value.absent(),
            Value<String?> fontFamily = const Value.absent(),
            Value<double?> brightness = const Value.absent(),
            Value<int?> backgroundColor = const Value.absent(),
            Value<String?> pageTurnType = const Value.absent(),
            Value<bool?> isEyeProtectionMode = const Value.absent(),
            Value<double?> ttsRate = const Value.absent(),
            Value<double?> ttsPitch = const Value.absent(),
            Value<double?> ttsVolume = const Value.absent(),
            Value<String?> ttsVoiceName = const Value.absent(),
            Value<bool?> ttsAutoNextPage = const Value.absent(),
            Value<bool?> ttsAutoNextChapter = const Value.absent(),
            Value<bool?> ttsResumeAfterInterrupt = const Value.absent(),
            Value<String?> themeMode = const Value.absent(),
            Value<String?> bookshelfLayout = const Value.absent(),
          }) =>
              BookReadSettingsCompanion.insert(
            id: id,
            updateTime: updateTime,
            fontSize: fontSize,
            fontHeight: fontHeight,
            wordSpacing: wordSpacing,
            letterSpacing: letterSpacing,
            fontFamily: fontFamily,
            brightness: brightness,
            backgroundColor: backgroundColor,
            pageTurnType: pageTurnType,
            isEyeProtectionMode: isEyeProtectionMode,
            ttsRate: ttsRate,
            ttsPitch: ttsPitch,
            ttsVolume: ttsVolume,
            ttsVoiceName: ttsVoiceName,
            ttsAutoNextPage: ttsAutoNextPage,
            ttsAutoNextChapter: ttsAutoNextChapter,
            ttsResumeAfterInterrupt: ttsResumeAfterInterrupt,
            themeMode: themeMode,
            bookshelfLayout: bookshelfLayout,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookReadSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookReadSettingsTable,
    BookReadSetting,
    $$BookReadSettingsTableFilterComposer,
    $$BookReadSettingsTableOrderingComposer,
    $$BookReadSettingsTableAnnotationComposer,
    $$BookReadSettingsTableCreateCompanionBuilder,
    $$BookReadSettingsTableUpdateCompanionBuilder,
    (
      BookReadSetting,
      BaseReferences<_$AppDatabase, $BookReadSettingsTable, BookReadSetting>
    ),
    BookReadSetting,
    PrefetchHooks Function()>;
typedef $$BookContentInfosTableCreateCompanionBuilder
    = BookContentInfosCompanion Function({
  Value<int> id,
  required int bookSourceId,
  Value<String?> name,
  Value<String?> chapterName,
  Value<int?> chapterIndex,
  Value<String?> bookContent,
});
typedef $$BookContentInfosTableUpdateCompanionBuilder
    = BookContentInfosCompanion Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String?> name,
  Value<String?> chapterName,
  Value<int?> chapterIndex,
  Value<String?> bookContent,
});

class $$BookContentInfosTableFilterComposer
    extends Composer<_$AppDatabase, $BookContentInfosTable> {
  $$BookContentInfosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookContent => $composableBuilder(
      column: $table.bookContent, builder: (column) => ColumnFilters(column));
}

class $$BookContentInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $BookContentInfosTable> {
  $$BookContentInfosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookContent => $composableBuilder(
      column: $table.bookContent, builder: (column) => ColumnOrderings(column));
}

class $$BookContentInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookContentInfosTable> {
  $$BookContentInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);

  GeneratedColumn<String> get bookContent => $composableBuilder(
      column: $table.bookContent, builder: (column) => column);
}

class $$BookContentInfosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookContentInfosTable,
    BookContentInfo,
    $$BookContentInfosTableFilterComposer,
    $$BookContentInfosTableOrderingComposer,
    $$BookContentInfosTableAnnotationComposer,
    $$BookContentInfosTableCreateCompanionBuilder,
    $$BookContentInfosTableUpdateCompanionBuilder,
    (
      BookContentInfo,
      BaseReferences<_$AppDatabase, $BookContentInfosTable, BookContentInfo>
    ),
    BookContentInfo,
    PrefetchHooks Function()> {
  $$BookContentInfosTableTableManager(
      _$AppDatabase db, $BookContentInfosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookContentInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookContentInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookContentInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> chapterName = const Value.absent(),
            Value<int?> chapterIndex = const Value.absent(),
            Value<String?> bookContent = const Value.absent(),
          }) =>
              BookContentInfosCompanion(
            id: id,
            bookSourceId: bookSourceId,
            name: name,
            chapterName: chapterName,
            chapterIndex: chapterIndex,
            bookContent: bookContent,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            Value<String?> name = const Value.absent(),
            Value<String?> chapterName = const Value.absent(),
            Value<int?> chapterIndex = const Value.absent(),
            Value<String?> bookContent = const Value.absent(),
          }) =>
              BookContentInfosCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            name: name,
            chapterName: chapterName,
            chapterIndex: chapterIndex,
            bookContent: bookContent,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookContentInfosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookContentInfosTable,
    BookContentInfo,
    $$BookContentInfosTableFilterComposer,
    $$BookContentInfosTableOrderingComposer,
    $$BookContentInfosTableAnnotationComposer,
    $$BookContentInfosTableCreateCompanionBuilder,
    $$BookContentInfosTableUpdateCompanionBuilder,
    (
      BookContentInfo,
      BaseReferences<_$AppDatabase, $BookContentInfosTable, BookContentInfo>
    ),
    BookContentInfo,
    PrefetchHooks Function()>;
typedef $$BookSearchInfosTableCreateCompanionBuilder = BookSearchInfosCompanion
    Function({
  Value<int> id,
  required int bookSourceId,
  required String searchUrl,
  required String method,
  required String charset,
  Value<String?> headers,
  Value<String?> body,
});
typedef $$BookSearchInfosTableUpdateCompanionBuilder = BookSearchInfosCompanion
    Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String> searchUrl,
  Value<String> method,
  Value<String> charset,
  Value<String?> headers,
  Value<String?> body,
});

class $$BookSearchInfosTableFilterComposer
    extends Composer<_$AppDatabase, $BookSearchInfosTable> {
  $$BookSearchInfosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get searchUrl => $composableBuilder(
      column: $table.searchUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get charset => $composableBuilder(
      column: $table.charset, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get headers => $composableBuilder(
      column: $table.headers, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));
}

class $$BookSearchInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $BookSearchInfosTable> {
  $$BookSearchInfosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get searchUrl => $composableBuilder(
      column: $table.searchUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get charset => $composableBuilder(
      column: $table.charset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get headers => $composableBuilder(
      column: $table.headers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));
}

class $$BookSearchInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookSearchInfosTable> {
  $$BookSearchInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get searchUrl =>
      $composableBuilder(column: $table.searchUrl, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get charset =>
      $composableBuilder(column: $table.charset, builder: (column) => column);

  GeneratedColumn<String> get headers =>
      $composableBuilder(column: $table.headers, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$BookSearchInfosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookSearchInfosTable,
    BookSearchInfo,
    $$BookSearchInfosTableFilterComposer,
    $$BookSearchInfosTableOrderingComposer,
    $$BookSearchInfosTableAnnotationComposer,
    $$BookSearchInfosTableCreateCompanionBuilder,
    $$BookSearchInfosTableUpdateCompanionBuilder,
    (
      BookSearchInfo,
      BaseReferences<_$AppDatabase, $BookSearchInfosTable, BookSearchInfo>
    ),
    BookSearchInfo,
    PrefetchHooks Function()> {
  $$BookSearchInfosTableTableManager(
      _$AppDatabase db, $BookSearchInfosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookSearchInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookSearchInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookSearchInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String> searchUrl = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String> charset = const Value.absent(),
            Value<String?> headers = const Value.absent(),
            Value<String?> body = const Value.absent(),
          }) =>
              BookSearchInfosCompanion(
            id: id,
            bookSourceId: bookSourceId,
            searchUrl: searchUrl,
            method: method,
            charset: charset,
            headers: headers,
            body: body,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            required String searchUrl,
            required String method,
            required String charset,
            Value<String?> headers = const Value.absent(),
            Value<String?> body = const Value.absent(),
          }) =>
              BookSearchInfosCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            searchUrl: searchUrl,
            method: method,
            charset: charset,
            headers: headers,
            body: body,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookSearchInfosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookSearchInfosTable,
    BookSearchInfo,
    $$BookSearchInfosTableFilterComposer,
    $$BookSearchInfosTableOrderingComposer,
    $$BookSearchInfosTableAnnotationComposer,
    $$BookSearchInfosTableCreateCompanionBuilder,
    $$BookSearchInfosTableUpdateCompanionBuilder,
    (
      BookSearchInfo,
      BaseReferences<_$AppDatabase, $BookSearchInfosTable, BookSearchInfo>
    ),
    BookSearchInfo,
    PrefetchHooks Function()>;
typedef $$BookReadProgressesTableCreateCompanionBuilder
    = BookReadProgressesCompanion Function({
  Value<int> id,
  required int bookSourceId,
  required String bookName,
  Value<String?> chapterName,
  required int chapterIndex,
  required String locatorJson,
  required DateTime updateTime,
});
typedef $$BookReadProgressesTableUpdateCompanionBuilder
    = BookReadProgressesCompanion Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String> bookName,
  Value<String?> chapterName,
  Value<int> chapterIndex,
  Value<String> locatorJson,
  Value<DateTime> updateTime,
});

class $$BookReadProgressesTableFilterComposer
    extends Composer<_$AppDatabase, $BookReadProgressesTable> {
  $$BookReadProgressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locatorJson => $composableBuilder(
      column: $table.locatorJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnFilters(column));
}

class $$BookReadProgressesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookReadProgressesTable> {
  $$BookReadProgressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locatorJson => $composableBuilder(
      column: $table.locatorJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => ColumnOrderings(column));
}

class $$BookReadProgressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookReadProgressesTable> {
  $$BookReadProgressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);

  GeneratedColumn<String> get locatorJson => $composableBuilder(
      column: $table.locatorJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updateTime => $composableBuilder(
      column: $table.updateTime, builder: (column) => column);
}

class $$BookReadProgressesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookReadProgressesTable,
    BookReadProgressesData,
    $$BookReadProgressesTableFilterComposer,
    $$BookReadProgressesTableOrderingComposer,
    $$BookReadProgressesTableAnnotationComposer,
    $$BookReadProgressesTableCreateCompanionBuilder,
    $$BookReadProgressesTableUpdateCompanionBuilder,
    (
      BookReadProgressesData,
      BaseReferences<_$AppDatabase, $BookReadProgressesTable,
          BookReadProgressesData>
    ),
    BookReadProgressesData,
    PrefetchHooks Function()> {
  $$BookReadProgressesTableTableManager(
      _$AppDatabase db, $BookReadProgressesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookReadProgressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookReadProgressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookReadProgressesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String> bookName = const Value.absent(),
            Value<String?> chapterName = const Value.absent(),
            Value<int> chapterIndex = const Value.absent(),
            Value<String> locatorJson = const Value.absent(),
            Value<DateTime> updateTime = const Value.absent(),
          }) =>
              BookReadProgressesCompanion(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            chapterName: chapterName,
            chapterIndex: chapterIndex,
            locatorJson: locatorJson,
            updateTime: updateTime,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            required String bookName,
            Value<String?> chapterName = const Value.absent(),
            required int chapterIndex,
            required String locatorJson,
            required DateTime updateTime,
          }) =>
              BookReadProgressesCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            chapterName: chapterName,
            chapterIndex: chapterIndex,
            locatorJson: locatorJson,
            updateTime: updateTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookReadProgressesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookReadProgressesTable,
    BookReadProgressesData,
    $$BookReadProgressesTableFilterComposer,
    $$BookReadProgressesTableOrderingComposer,
    $$BookReadProgressesTableAnnotationComposer,
    $$BookReadProgressesTableCreateCompanionBuilder,
    $$BookReadProgressesTableUpdateCompanionBuilder,
    (
      BookReadProgressesData,
      BaseReferences<_$AppDatabase, $BookReadProgressesTable,
          BookReadProgressesData>
    ),
    BookReadProgressesData,
    PrefetchHooks Function()>;
typedef $$SearchHistoriesTableCreateCompanionBuilder = SearchHistoriesCompanion
    Function({
  Value<int> id,
  required String keyword,
  required DateTime searchTime,
});
typedef $$SearchHistoriesTableUpdateCompanionBuilder = SearchHistoriesCompanion
    Function({
  Value<int> id,
  Value<String> keyword,
  Value<DateTime> searchTime,
});

class $$SearchHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoriesTable> {
  $$SearchHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keyword => $composableBuilder(
      column: $table.keyword, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get searchTime => $composableBuilder(
      column: $table.searchTime, builder: (column) => ColumnFilters(column));
}

class $$SearchHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoriesTable> {
  $$SearchHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyword => $composableBuilder(
      column: $table.keyword, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get searchTime => $composableBuilder(
      column: $table.searchTime, builder: (column) => ColumnOrderings(column));
}

class $$SearchHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoriesTable> {
  $$SearchHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

  GeneratedColumn<DateTime> get searchTime => $composableBuilder(
      column: $table.searchTime, builder: (column) => column);
}

class $$SearchHistoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SearchHistoriesTable,
    SearchHistory,
    $$SearchHistoriesTableFilterComposer,
    $$SearchHistoriesTableOrderingComposer,
    $$SearchHistoriesTableAnnotationComposer,
    $$SearchHistoriesTableCreateCompanionBuilder,
    $$SearchHistoriesTableUpdateCompanionBuilder,
    (
      SearchHistory,
      BaseReferences<_$AppDatabase, $SearchHistoriesTable, SearchHistory>
    ),
    SearchHistory,
    PrefetchHooks Function()> {
  $$SearchHistoriesTableTableManager(
      _$AppDatabase db, $SearchHistoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> keyword = const Value.absent(),
            Value<DateTime> searchTime = const Value.absent(),
          }) =>
              SearchHistoriesCompanion(
            id: id,
            keyword: keyword,
            searchTime: searchTime,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String keyword,
            required DateTime searchTime,
          }) =>
              SearchHistoriesCompanion.insert(
            id: id,
            keyword: keyword,
            searchTime: searchTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SearchHistoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SearchHistoriesTable,
    SearchHistory,
    $$SearchHistoriesTableFilterComposer,
    $$SearchHistoriesTableOrderingComposer,
    $$SearchHistoriesTableAnnotationComposer,
    $$SearchHistoriesTableCreateCompanionBuilder,
    $$SearchHistoriesTableUpdateCompanionBuilder,
    (
      SearchHistory,
      BaseReferences<_$AppDatabase, $SearchHistoriesTable, SearchHistory>
    ),
    SearchHistory,
    PrefetchHooks Function()>;
typedef $$BookReadHistoriesTableCreateCompanionBuilder
    = BookReadHistoriesCompanion Function({
  Value<int> id,
  required int bookSourceId,
  required String bookName,
  Value<String?> chapterName,
  required int chapterIndex,
});
typedef $$BookReadHistoriesTableUpdateCompanionBuilder
    = BookReadHistoriesCompanion Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String> bookName,
  Value<String?> chapterName,
  Value<int> chapterIndex,
});

class $$BookReadHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $BookReadHistoriesTable> {
  $$BookReadHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));
}

class $$BookReadHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookReadHistoriesTable> {
  $$BookReadHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));
}

class $$BookReadHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookReadHistoriesTable> {
  $$BookReadHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);
}

class $$BookReadHistoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookReadHistoriesTable,
    BookReadHistory,
    $$BookReadHistoriesTableFilterComposer,
    $$BookReadHistoriesTableOrderingComposer,
    $$BookReadHistoriesTableAnnotationComposer,
    $$BookReadHistoriesTableCreateCompanionBuilder,
    $$BookReadHistoriesTableUpdateCompanionBuilder,
    (
      BookReadHistory,
      BaseReferences<_$AppDatabase, $BookReadHistoriesTable, BookReadHistory>
    ),
    BookReadHistory,
    PrefetchHooks Function()> {
  $$BookReadHistoriesTableTableManager(
      _$AppDatabase db, $BookReadHistoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookReadHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookReadHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookReadHistoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String> bookName = const Value.absent(),
            Value<String?> chapterName = const Value.absent(),
            Value<int> chapterIndex = const Value.absent(),
          }) =>
              BookReadHistoriesCompanion(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            chapterName: chapterName,
            chapterIndex: chapterIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            required String bookName,
            Value<String?> chapterName = const Value.absent(),
            required int chapterIndex,
          }) =>
              BookReadHistoriesCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            chapterName: chapterName,
            chapterIndex: chapterIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookReadHistoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookReadHistoriesTable,
    BookReadHistory,
    $$BookReadHistoriesTableFilterComposer,
    $$BookReadHistoriesTableOrderingComposer,
    $$BookReadHistoriesTableAnnotationComposer,
    $$BookReadHistoriesTableCreateCompanionBuilder,
    $$BookReadHistoriesTableUpdateCompanionBuilder,
    (
      BookReadHistory,
      BaseReferences<_$AppDatabase, $BookReadHistoriesTable, BookReadHistory>
    ),
    BookReadHistory,
    PrefetchHooks Function()>;
typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required int bookSourceId,
  Value<String?> bookUrl,
  required String name,
  Value<String?> author,
  Value<String?> cover,
  Value<String?> intro,
  Value<String?> kind,
  Value<String?> wordCount,
  Value<String?> lastChapter,
  Value<int> totalChapterNum,
  Value<int> durChapterIndex,
  Value<int> durChapterPos,
  Value<DateTime?> lastReadTime,
  Value<bool> isAscending,
  Value<int> customOrder,
  Value<String?> bookGroup,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String?> bookUrl,
  Value<String> name,
  Value<String?> author,
  Value<String?> cover,
  Value<String?> intro,
  Value<String?> kind,
  Value<String?> wordCount,
  Value<String?> lastChapter,
  Value<int> totalChapterNum,
  Value<int> durChapterIndex,
  Value<int> durChapterPos,
  Value<DateTime?> lastReadTime,
  Value<bool> isAscending,
  Value<int> customOrder,
  Value<String?> bookGroup,
});

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookUrl => $composableBuilder(
      column: $table.bookUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalChapterNum => $composableBuilder(
      column: $table.totalChapterNum,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durChapterIndex => $composableBuilder(
      column: $table.durChapterIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durChapterPos => $composableBuilder(
      column: $table.durChapterPos, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReadTime => $composableBuilder(
      column: $table.lastReadTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAscending => $composableBuilder(
      column: $table.isAscending, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get customOrder => $composableBuilder(
      column: $table.customOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookGroup => $composableBuilder(
      column: $table.bookGroup, builder: (column) => ColumnFilters(column));
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookUrl => $composableBuilder(
      column: $table.bookUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalChapterNum => $composableBuilder(
      column: $table.totalChapterNum,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durChapterIndex => $composableBuilder(
      column: $table.durChapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durChapterPos => $composableBuilder(
      column: $table.durChapterPos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReadTime => $composableBuilder(
      column: $table.lastReadTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAscending => $composableBuilder(
      column: $table.isAscending, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get customOrder => $composableBuilder(
      column: $table.customOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookGroup => $composableBuilder(
      column: $table.bookGroup, builder: (column) => ColumnOrderings(column));
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get bookUrl =>
      $composableBuilder(column: $table.bookUrl, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get intro =>
      $composableBuilder(column: $table.intro, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<String> get lastChapter => $composableBuilder(
      column: $table.lastChapter, builder: (column) => column);

  GeneratedColumn<int> get totalChapterNum => $composableBuilder(
      column: $table.totalChapterNum, builder: (column) => column);

  GeneratedColumn<int> get durChapterIndex => $composableBuilder(
      column: $table.durChapterIndex, builder: (column) => column);

  GeneratedColumn<int> get durChapterPos => $composableBuilder(
      column: $table.durChapterPos, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadTime => $composableBuilder(
      column: $table.lastReadTime, builder: (column) => column);

  GeneratedColumn<bool> get isAscending => $composableBuilder(
      column: $table.isAscending, builder: (column) => column);

  GeneratedColumn<int> get customOrder => $composableBuilder(
      column: $table.customOrder, builder: (column) => column);

  GeneratedColumn<String> get bookGroup =>
      $composableBuilder(column: $table.bookGroup, builder: (column) => column);
}

class $$BooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
    Book,
    PrefetchHooks Function()> {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String?> bookUrl = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> cover = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> kind = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
            Value<String?> lastChapter = const Value.absent(),
            Value<int> totalChapterNum = const Value.absent(),
            Value<int> durChapterIndex = const Value.absent(),
            Value<int> durChapterPos = const Value.absent(),
            Value<DateTime?> lastReadTime = const Value.absent(),
            Value<bool> isAscending = const Value.absent(),
            Value<int> customOrder = const Value.absent(),
            Value<String?> bookGroup = const Value.absent(),
          }) =>
              BooksCompanion(
            id: id,
            bookSourceId: bookSourceId,
            bookUrl: bookUrl,
            name: name,
            author: author,
            cover: cover,
            intro: intro,
            kind: kind,
            wordCount: wordCount,
            lastChapter: lastChapter,
            totalChapterNum: totalChapterNum,
            durChapterIndex: durChapterIndex,
            durChapterPos: durChapterPos,
            lastReadTime: lastReadTime,
            isAscending: isAscending,
            customOrder: customOrder,
            bookGroup: bookGroup,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            Value<String?> bookUrl = const Value.absent(),
            required String name,
            Value<String?> author = const Value.absent(),
            Value<String?> cover = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> kind = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
            Value<String?> lastChapter = const Value.absent(),
            Value<int> totalChapterNum = const Value.absent(),
            Value<int> durChapterIndex = const Value.absent(),
            Value<int> durChapterPos = const Value.absent(),
            Value<DateTime?> lastReadTime = const Value.absent(),
            Value<bool> isAscending = const Value.absent(),
            Value<int> customOrder = const Value.absent(),
            Value<String?> bookGroup = const Value.absent(),
          }) =>
              BooksCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            bookUrl: bookUrl,
            name: name,
            author: author,
            cover: cover,
            intro: intro,
            kind: kind,
            wordCount: wordCount,
            lastChapter: lastChapter,
            totalChapterNum: totalChapterNum,
            durChapterIndex: durChapterIndex,
            durChapterPos: durChapterPos,
            lastReadTime: lastReadTime,
            isAscending: isAscending,
            customOrder: customOrder,
            bookGroup: bookGroup,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
    Book,
    PrefetchHooks Function()>;
typedef $$BookChaptersTableCreateCompanionBuilder = BookChaptersCompanion
    Function({
  Value<int> id,
  required int bookId,
  required int bookSourceId,
  required int chapterIndex,
  required String chapterName,
  required String chapterUrl,
  Value<bool> isVip,
  Value<String?> wordCount,
});
typedef $$BookChaptersTableUpdateCompanionBuilder = BookChaptersCompanion
    Function({
  Value<int> id,
  Value<int> bookId,
  Value<int> bookSourceId,
  Value<int> chapterIndex,
  Value<String> chapterName,
  Value<String> chapterUrl,
  Value<bool> isVip,
  Value<String?> wordCount,
});

class $$BookChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterUrl => $composableBuilder(
      column: $table.chapterUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVip => $composableBuilder(
      column: $table.isVip, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnFilters(column));
}

class $$BookChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterUrl => $composableBuilder(
      column: $table.chapterUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVip => $composableBuilder(
      column: $table.isVip, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnOrderings(column));
}

class $$BookChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookChaptersTable> {
  $$BookChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);

  GeneratedColumn<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => column);

  GeneratedColumn<String> get chapterUrl => $composableBuilder(
      column: $table.chapterUrl, builder: (column) => column);

  GeneratedColumn<bool> get isVip =>
      $composableBuilder(column: $table.isVip, builder: (column) => column);

  GeneratedColumn<String> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);
}

class $$BookChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookChaptersTable,
    BookChapter,
    $$BookChaptersTableFilterComposer,
    $$BookChaptersTableOrderingComposer,
    $$BookChaptersTableAnnotationComposer,
    $$BookChaptersTableCreateCompanionBuilder,
    $$BookChaptersTableUpdateCompanionBuilder,
    (
      BookChapter,
      BaseReferences<_$AppDatabase, $BookChaptersTable, BookChapter>
    ),
    BookChapter,
    PrefetchHooks Function()> {
  $$BookChaptersTableTableManager(_$AppDatabase db, $BookChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookId = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<int> chapterIndex = const Value.absent(),
            Value<String> chapterName = const Value.absent(),
            Value<String> chapterUrl = const Value.absent(),
            Value<bool> isVip = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
          }) =>
              BookChaptersCompanion(
            id: id,
            bookId: bookId,
            bookSourceId: bookSourceId,
            chapterIndex: chapterIndex,
            chapterName: chapterName,
            chapterUrl: chapterUrl,
            isVip: isVip,
            wordCount: wordCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookId,
            required int bookSourceId,
            required int chapterIndex,
            required String chapterName,
            required String chapterUrl,
            Value<bool> isVip = const Value.absent(),
            Value<String?> wordCount = const Value.absent(),
          }) =>
              BookChaptersCompanion.insert(
            id: id,
            bookId: bookId,
            bookSourceId: bookSourceId,
            chapterIndex: chapterIndex,
            chapterName: chapterName,
            chapterUrl: chapterUrl,
            isVip: isVip,
            wordCount: wordCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookChaptersTable,
    BookChapter,
    $$BookChaptersTableFilterComposer,
    $$BookChaptersTableOrderingComposer,
    $$BookChaptersTableAnnotationComposer,
    $$BookChaptersTableCreateCompanionBuilder,
    $$BookChaptersTableUpdateCompanionBuilder,
    (
      BookChapter,
      BaseReferences<_$AppDatabase, $BookChaptersTable, BookChapter>
    ),
    BookChapter,
    PrefetchHooks Function()>;
typedef $$LocalBookFilesTableCreateCompanionBuilder = LocalBookFilesCompanion
    Function({
  Value<int> bookId,
  required String originalFileName,
  required String storedFilePath,
  required String format,
  Value<String?> charset,
  required int fileSize,
  Value<String?> fileHash,
  required DateTime importTime,
  Value<DateTime?> sourceModifiedTime,
});
typedef $$LocalBookFilesTableUpdateCompanionBuilder = LocalBookFilesCompanion
    Function({
  Value<int> bookId,
  Value<String> originalFileName,
  Value<String> storedFilePath,
  Value<String> format,
  Value<String?> charset,
  Value<int> fileSize,
  Value<String?> fileHash,
  Value<DateTime> importTime,
  Value<DateTime?> sourceModifiedTime,
});

class $$LocalBookFilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBookFilesTable> {
  $$LocalBookFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalFileName => $composableBuilder(
      column: $table.originalFileName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storedFilePath => $composableBuilder(
      column: $table.storedFilePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get charset => $composableBuilder(
      column: $table.charset, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileHash => $composableBuilder(
      column: $table.fileHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get importTime => $composableBuilder(
      column: $table.importTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sourceModifiedTime => $composableBuilder(
      column: $table.sourceModifiedTime,
      builder: (column) => ColumnFilters(column));
}

class $$LocalBookFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBookFilesTable> {
  $$LocalBookFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalFileName => $composableBuilder(
      column: $table.originalFileName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storedFilePath => $composableBuilder(
      column: $table.storedFilePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get charset => $composableBuilder(
      column: $table.charset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileHash => $composableBuilder(
      column: $table.fileHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get importTime => $composableBuilder(
      column: $table.importTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sourceModifiedTime => $composableBuilder(
      column: $table.sourceModifiedTime,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalBookFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBookFilesTable> {
  $$LocalBookFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get originalFileName => $composableBuilder(
      column: $table.originalFileName, builder: (column) => column);

  GeneratedColumn<String> get storedFilePath => $composableBuilder(
      column: $table.storedFilePath, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get charset =>
      $composableBuilder(column: $table.charset, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get fileHash =>
      $composableBuilder(column: $table.fileHash, builder: (column) => column);

  GeneratedColumn<DateTime> get importTime => $composableBuilder(
      column: $table.importTime, builder: (column) => column);

  GeneratedColumn<DateTime> get sourceModifiedTime => $composableBuilder(
      column: $table.sourceModifiedTime, builder: (column) => column);
}

class $$LocalBookFilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalBookFilesTable,
    LocalBookFile,
    $$LocalBookFilesTableFilterComposer,
    $$LocalBookFilesTableOrderingComposer,
    $$LocalBookFilesTableAnnotationComposer,
    $$LocalBookFilesTableCreateCompanionBuilder,
    $$LocalBookFilesTableUpdateCompanionBuilder,
    (
      LocalBookFile,
      BaseReferences<_$AppDatabase, $LocalBookFilesTable, LocalBookFile>
    ),
    LocalBookFile,
    PrefetchHooks Function()> {
  $$LocalBookFilesTableTableManager(
      _$AppDatabase db, $LocalBookFilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBookFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBookFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBookFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> bookId = const Value.absent(),
            Value<String> originalFileName = const Value.absent(),
            Value<String> storedFilePath = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<String?> charset = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            Value<String?> fileHash = const Value.absent(),
            Value<DateTime> importTime = const Value.absent(),
            Value<DateTime?> sourceModifiedTime = const Value.absent(),
          }) =>
              LocalBookFilesCompanion(
            bookId: bookId,
            originalFileName: originalFileName,
            storedFilePath: storedFilePath,
            format: format,
            charset: charset,
            fileSize: fileSize,
            fileHash: fileHash,
            importTime: importTime,
            sourceModifiedTime: sourceModifiedTime,
          ),
          createCompanionCallback: ({
            Value<int> bookId = const Value.absent(),
            required String originalFileName,
            required String storedFilePath,
            required String format,
            Value<String?> charset = const Value.absent(),
            required int fileSize,
            Value<String?> fileHash = const Value.absent(),
            required DateTime importTime,
            Value<DateTime?> sourceModifiedTime = const Value.absent(),
          }) =>
              LocalBookFilesCompanion.insert(
            bookId: bookId,
            originalFileName: originalFileName,
            storedFilePath: storedFilePath,
            format: format,
            charset: charset,
            fileSize: fileSize,
            fileHash: fileHash,
            importTime: importTime,
            sourceModifiedTime: sourceModifiedTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalBookFilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalBookFilesTable,
    LocalBookFile,
    $$LocalBookFilesTableFilterComposer,
    $$LocalBookFilesTableOrderingComposer,
    $$LocalBookFilesTableAnnotationComposer,
    $$LocalBookFilesTableCreateCompanionBuilder,
    $$LocalBookFilesTableUpdateCompanionBuilder,
    (
      LocalBookFile,
      BaseReferences<_$AppDatabase, $LocalBookFilesTable, LocalBookFile>
    ),
    LocalBookFile,
    PrefetchHooks Function()>;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  required int bookSourceId,
  required String bookName,
  required String locatorJson,
  Value<String> chapterName,
  Value<String> bookText,
  Value<String> content,
  required DateTime createTime,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String> bookName,
  Value<String> locatorJson,
  Value<String> chapterName,
  Value<String> bookText,
  Value<String> content,
  Value<DateTime> createTime,
});

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locatorJson => $composableBuilder(
      column: $table.locatorJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookText => $composableBuilder(
      column: $table.bookText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createTime => $composableBuilder(
      column: $table.createTime, builder: (column) => ColumnFilters(column));
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locatorJson => $composableBuilder(
      column: $table.locatorJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookText => $composableBuilder(
      column: $table.bookText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createTime => $composableBuilder(
      column: $table.createTime, builder: (column) => ColumnOrderings(column));
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<String> get locatorJson => $composableBuilder(
      column: $table.locatorJson, builder: (column) => column);

  GeneratedColumn<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => column);

  GeneratedColumn<String> get bookText =>
      $composableBuilder(column: $table.bookText, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createTime => $composableBuilder(
      column: $table.createTime, builder: (column) => column);
}

class $$BookmarksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
    Bookmark,
    PrefetchHooks Function()> {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String> bookName = const Value.absent(),
            Value<String> locatorJson = const Value.absent(),
            Value<String> chapterName = const Value.absent(),
            Value<String> bookText = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> createTime = const Value.absent(),
          }) =>
              BookmarksCompanion(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            locatorJson: locatorJson,
            chapterName: chapterName,
            bookText: bookText,
            content: content,
            createTime: createTime,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            required String bookName,
            required String locatorJson,
            Value<String> chapterName = const Value.absent(),
            Value<String> bookText = const Value.absent(),
            Value<String> content = const Value.absent(),
            required DateTime createTime,
          }) =>
              BookmarksCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            locatorJson: locatorJson,
            chapterName: chapterName,
            bookText: bookText,
            content: content,
            createTime: createTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
    Bookmark,
    PrefetchHooks Function()>;
typedef $$ReadingSessionsTableCreateCompanionBuilder = ReadingSessionsCompanion
    Function({
  Value<int> id,
  required int bookSourceId,
  required String bookName,
  Value<String?> chapterName,
  required int chapterIndex,
  required String startLocatorJson,
  Value<String?> endLocatorJson,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<int> durationSeconds,
});
typedef $$ReadingSessionsTableUpdateCompanionBuilder = ReadingSessionsCompanion
    Function({
  Value<int> id,
  Value<int> bookSourceId,
  Value<String> bookName,
  Value<String?> chapterName,
  Value<int> chapterIndex,
  Value<String> startLocatorJson,
  Value<String?> endLocatorJson,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> durationSeconds,
});

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startLocatorJson => $composableBuilder(
      column: $table.startLocatorJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endLocatorJson => $composableBuilder(
      column: $table.endLocatorJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startLocatorJson => $composableBuilder(
      column: $table.startLocatorJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endLocatorJson => $composableBuilder(
      column: $table.endLocatorJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);

  GeneratedColumn<String> get startLocatorJson => $composableBuilder(
      column: $table.startLocatorJson, builder: (column) => column);

  GeneratedColumn<String> get endLocatorJson => $composableBuilder(
      column: $table.endLocatorJson, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);
}

class $$ReadingSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingSessionsTable,
    ReadingSession,
    $$ReadingSessionsTableFilterComposer,
    $$ReadingSessionsTableOrderingComposer,
    $$ReadingSessionsTableAnnotationComposer,
    $$ReadingSessionsTableCreateCompanionBuilder,
    $$ReadingSessionsTableUpdateCompanionBuilder,
    (
      ReadingSession,
      BaseReferences<_$AppDatabase, $ReadingSessionsTable, ReadingSession>
    ),
    ReadingSession,
    PrefetchHooks Function()> {
  $$ReadingSessionsTableTableManager(
      _$AppDatabase db, $ReadingSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String> bookName = const Value.absent(),
            Value<String?> chapterName = const Value.absent(),
            Value<int> chapterIndex = const Value.absent(),
            Value<String> startLocatorJson = const Value.absent(),
            Value<String?> endLocatorJson = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
          }) =>
              ReadingSessionsCompanion(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            chapterName: chapterName,
            chapterIndex: chapterIndex,
            startLocatorJson: startLocatorJson,
            endLocatorJson: endLocatorJson,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: durationSeconds,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookSourceId,
            required String bookName,
            Value<String?> chapterName = const Value.absent(),
            required int chapterIndex,
            required String startLocatorJson,
            Value<String?> endLocatorJson = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
          }) =>
              ReadingSessionsCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            chapterName: chapterName,
            chapterIndex: chapterIndex,
            startLocatorJson: startLocatorJson,
            endLocatorJson: endLocatorJson,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: durationSeconds,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadingSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingSessionsTable,
    ReadingSession,
    $$ReadingSessionsTableFilterComposer,
    $$ReadingSessionsTableOrderingComposer,
    $$ReadingSessionsTableAnnotationComposer,
    $$ReadingSessionsTableCreateCompanionBuilder,
    $$ReadingSessionsTableUpdateCompanionBuilder,
    (
      ReadingSession,
      BaseReferences<_$AppDatabase, $ReadingSessionsTable, ReadingSession>
    ),
    ReadingSession,
    PrefetchHooks Function()>;
typedef $$BookAnnotationsTableCreateCompanionBuilder = BookAnnotationsCompanion
    Function({
  required String id,
  required int bookSourceId,
  required String bookName,
  required int chapterIndex,
  Value<String> chapterName,
  required String locatorJson,
  required String type,
  Value<String> excerpt,
  Value<String> note,
  Value<int?> colorValue,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$BookAnnotationsTableUpdateCompanionBuilder = BookAnnotationsCompanion
    Function({
  Value<String> id,
  Value<int> bookSourceId,
  Value<String> bookName,
  Value<int> chapterIndex,
  Value<String> chapterName,
  Value<String> locatorJson,
  Value<String> type,
  Value<String> excerpt,
  Value<String> note,
  Value<int?> colorValue,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$BookAnnotationsTableFilterComposer
    extends Composer<_$AppDatabase, $BookAnnotationsTable> {
  $$BookAnnotationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locatorJson => $composableBuilder(
      column: $table.locatorJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get excerpt => $composableBuilder(
      column: $table.excerpt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$BookAnnotationsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookAnnotationsTable> {
  $$BookAnnotationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookName => $composableBuilder(
      column: $table.bookName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locatorJson => $composableBuilder(
      column: $table.locatorJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get excerpt => $composableBuilder(
      column: $table.excerpt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$BookAnnotationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookAnnotationsTable> {
  $$BookAnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookSourceId => $composableBuilder(
      column: $table.bookSourceId, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);

  GeneratedColumn<String> get chapterName => $composableBuilder(
      column: $table.chapterName, builder: (column) => column);

  GeneratedColumn<String> get locatorJson => $composableBuilder(
      column: $table.locatorJson, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get excerpt =>
      $composableBuilder(column: $table.excerpt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BookAnnotationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookAnnotationsTable,
    BookAnnotation,
    $$BookAnnotationsTableFilterComposer,
    $$BookAnnotationsTableOrderingComposer,
    $$BookAnnotationsTableAnnotationComposer,
    $$BookAnnotationsTableCreateCompanionBuilder,
    $$BookAnnotationsTableUpdateCompanionBuilder,
    (
      BookAnnotation,
      BaseReferences<_$AppDatabase, $BookAnnotationsTable, BookAnnotation>
    ),
    BookAnnotation,
    PrefetchHooks Function()> {
  $$BookAnnotationsTableTableManager(
      _$AppDatabase db, $BookAnnotationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookAnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookAnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookAnnotationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> bookSourceId = const Value.absent(),
            Value<String> bookName = const Value.absent(),
            Value<int> chapterIndex = const Value.absent(),
            Value<String> chapterName = const Value.absent(),
            Value<String> locatorJson = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> excerpt = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<int?> colorValue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookAnnotationsCompanion(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            chapterIndex: chapterIndex,
            chapterName: chapterName,
            locatorJson: locatorJson,
            type: type,
            excerpt: excerpt,
            note: note,
            colorValue: colorValue,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int bookSourceId,
            required String bookName,
            required int chapterIndex,
            Value<String> chapterName = const Value.absent(),
            required String locatorJson,
            required String type,
            Value<String> excerpt = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<int?> colorValue = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BookAnnotationsCompanion.insert(
            id: id,
            bookSourceId: bookSourceId,
            bookName: bookName,
            chapterIndex: chapterIndex,
            chapterName: chapterName,
            locatorJson: locatorJson,
            type: type,
            excerpt: excerpt,
            note: note,
            colorValue: colorValue,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookAnnotationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookAnnotationsTable,
    BookAnnotation,
    $$BookAnnotationsTableFilterComposer,
    $$BookAnnotationsTableOrderingComposer,
    $$BookAnnotationsTableAnnotationComposer,
    $$BookAnnotationsTableCreateCompanionBuilder,
    $$BookAnnotationsTableUpdateCompanionBuilder,
    (
      BookAnnotation,
      BaseReferences<_$AppDatabase, $BookAnnotationsTable, BookAnnotation>
    ),
    BookAnnotation,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookSourcesTableTableManager get bookSources =>
      $$BookSourcesTableTableManager(_db, _db.bookSources);
  $$RuleBookInfosTableTableManager get ruleBookInfos =>
      $$RuleBookInfosTableTableManager(_db, _db.ruleBookInfos);
  $$RuleContentsTableTableManager get ruleContents =>
      $$RuleContentsTableTableManager(_db, _db.ruleContents);
  $$RuleSearchsTableTableManager get ruleSearchs =>
      $$RuleSearchsTableTableManager(_db, _db.ruleSearchs);
  $$RuleTocsTableTableManager get ruleTocs =>
      $$RuleTocsTableTableManager(_db, _db.ruleTocs);
  $$RuleExploresTableTableManager get ruleExplores =>
      $$RuleExploresTableTableManager(_db, _db.ruleExplores);
  $$BookReadSettingsTableTableManager get bookReadSettings =>
      $$BookReadSettingsTableTableManager(_db, _db.bookReadSettings);
  $$BookContentInfosTableTableManager get bookContentInfos =>
      $$BookContentInfosTableTableManager(_db, _db.bookContentInfos);
  $$BookSearchInfosTableTableManager get bookSearchInfos =>
      $$BookSearchInfosTableTableManager(_db, _db.bookSearchInfos);
  $$BookReadProgressesTableTableManager get bookReadProgresses =>
      $$BookReadProgressesTableTableManager(_db, _db.bookReadProgresses);
  $$SearchHistoriesTableTableManager get searchHistories =>
      $$SearchHistoriesTableTableManager(_db, _db.searchHistories);
  $$BookReadHistoriesTableTableManager get bookReadHistories =>
      $$BookReadHistoriesTableTableManager(_db, _db.bookReadHistories);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookChaptersTableTableManager get bookChapters =>
      $$BookChaptersTableTableManager(_db, _db.bookChapters);
  $$LocalBookFilesTableTableManager get localBookFiles =>
      $$LocalBookFilesTableTableManager(_db, _db.localBookFiles);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$BookAnnotationsTableTableManager get bookAnnotations =>
      $$BookAnnotationsTableTableManager(_db, _db.bookAnnotations);
}
