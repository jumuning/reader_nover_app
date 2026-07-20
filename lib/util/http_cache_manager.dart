import 'dart:collection';

import 'package:dio/dio.dart';

import 'log_utils.dart';

enum HttpCacheScene {
  generic,
  bookDetail,
  chapterList,
  chapterContent,
  search,
  explore,
}

extension HttpCacheSceneX on HttpCacheScene {
  String get label {
    switch (this) {
      case HttpCacheScene.generic:
        return 'generic';
      case HttpCacheScene.bookDetail:
        return 'book_detail';
      case HttpCacheScene.chapterList:
        return 'chapter_list';
      case HttpCacheScene.chapterContent:
        return 'chapter_content';
      case HttpCacheScene.search:
        return 'search';
      case HttpCacheScene.explore:
        return 'explore';
    }
  }
}

class HttpCachePolicy {
  const HttpCachePolicy({
    required this.scene,
    this.ttl,
    this.enableDeduplication = true,
  });

  final HttpCacheScene scene;
  final Duration? ttl;
  final bool enableDeduplication;

  String get label => scene.label;

  bool get isCacheEnabled => ttl != null && ttl!.compareTo(Duration.zero) > 0;
}

/// HTTP 缓存响应
class CachedResponse {
  CachedResponse._({
    required this.response,
    required this.policyLabel,
    required this.method,
    required this.url,
    required this.createdAt,
    required this.lastAccessTime,
    required this.expireTime,
  });

  factory CachedResponse({
    required Response response,
    required String policyLabel,
    required String method,
    required String url,
    required Duration duration,
  }) {
    final now = DateTime.now();
    return CachedResponse._(
      response: response,
      policyLabel: policyLabel,
      method: method,
      url: url,
      createdAt: now,
      lastAccessTime: now,
      expireTime: now.add(duration),
    );
  }

  final Response response;
  final String policyLabel;
  final String method;
  final String url;
  final DateTime createdAt;
  DateTime lastAccessTime;
  final DateTime expireTime;
  int hitCount = 0;

  bool get isExpired => DateTime.now().isAfter(expireTime);

  String get label => '[$policyLabel] $method $url';

  Duration get remainingTtl {
    final remaining = expireTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void recordHit() {
    hitCount += 1;
    lastAccessTime = DateTime.now();
  }
}

/// 缓存项快照，便于在调试页或日志里观察当前状态。
class HttpCacheEntrySnapshot {
  const HttpCacheEntrySnapshot({
    required this.policyLabel,
    required this.method,
    required this.url,
    required this.statusCode,
    required this.createdAt,
    required this.lastAccessTime,
    required this.expireTime,
    required this.hitCount,
  });

  final String policyLabel;
  final String method;
  final String url;
  final int? statusCode;
  final DateTime createdAt;
  final DateTime lastAccessTime;
  final DateTime expireTime;
  final int hitCount;

  String get label => '[$policyLabel] $method $url';

  bool get isExpired => DateTime.now().isAfter(expireTime);

  Duration get remainingTtl {
    final remaining = expireTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// HTTP 缓存统计快照
class HttpCacheStats {
  const HttpCacheStats({
    required this.totalRequests,
    required this.cacheableRequests,
    required this.cacheHits,
    required this.cacheMisses,
    required this.deduplicatedRequests,
    required this.networkRequests,
    required this.cacheWrites,
    required this.evictionCount,
    required this.expiredRemovalCount,
    required this.manualInvalidationCount,
    required this.errorCount,
    required this.cachedEntries,
    required this.pendingRequests,
    required this.entries,
  });

  final int totalRequests;
  final int cacheableRequests;
  final int cacheHits;
  final int cacheMisses;
  final int deduplicatedRequests;
  final int networkRequests;
  final int cacheWrites;
  final int evictionCount;
  final int expiredRemovalCount;
  final int manualInvalidationCount;
  final int errorCount;
  final int cachedEntries;
  final int pendingRequests;
  final List<HttpCacheEntrySnapshot> entries;

  double get hitRate {
    final cacheLookups = cacheHits + cacheMisses;
    if (cacheLookups == 0) return 0;
    return cacheHits / cacheLookups;
  }

  @override
  String toString() {
    final hitRatePercent = (hitRate * 100).toStringAsFixed(1);
    return 'requests=$totalRequests, cacheable=$cacheableRequests, '
        'hits=$cacheHits, misses=$cacheMisses, hitRate=$hitRatePercent%, '
        'dedup=$deduplicatedRequests, network=$networkRequests, '
        'writes=$cacheWrites, evictions=$evictionCount, '
        'expiredRemoved=$expiredRemovalCount, manualInvalidations='
        '$manualInvalidationCount, errors=$errorCount, cachedEntries='
        '$cachedEntries, pending=$pendingRequests';
  }
}

/// HTTP 缓存管理器
class HttpCacheManager {
  static const Map<HttpCacheScene, HttpCachePolicy> _defaultPolicies =
      <HttpCacheScene, HttpCachePolicy>{
    HttpCacheScene.generic: HttpCachePolicy(
      scene: HttpCacheScene.generic,
    ),
    HttpCacheScene.bookDetail: HttpCachePolicy(
      scene: HttpCacheScene.bookDetail,
      ttl: Duration(minutes: 10),
    ),
    HttpCacheScene.chapterList: HttpCachePolicy(
      scene: HttpCacheScene.chapterList,
      ttl: Duration(minutes: 5),
    ),
    HttpCacheScene.chapterContent: HttpCachePolicy(
      scene: HttpCacheScene.chapterContent,
      ttl: Duration(minutes: 30),
    ),
    HttpCacheScene.search: HttpCachePolicy(
      scene: HttpCacheScene.search,
      ttl: Duration(seconds: 30),
    ),
    HttpCacheScene.explore: HttpCachePolicy(
      scene: HttpCacheScene.explore,
      ttl: Duration(seconds: 30),
    ),
  };

  static final Map<HttpCacheScene, HttpCachePolicy> _policies =
      Map<HttpCacheScene, HttpCachePolicy>.from(_defaultPolicies);
  static final LinkedHashMap<String, CachedResponse> _cache =
      LinkedHashMap<String, CachedResponse>();
  static final Map<String, Future<Response>> _pendingRequests =
      <String, Future<Response>>{};

  static int _totalRequests = 0;
  static int _cacheableRequests = 0;
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _deduplicatedRequests = 0;
  static int _networkRequests = 0;
  static int _cacheWrites = 0;
  static int _evictionCount = 0;
  static int _expiredRemovalCount = 0;
  static int _manualInvalidationCount = 0;
  static int _errorCount = 0;

  /// 缓存最大条目数
  static const int _maxCacheSize = 100;

  /// 生成缓存键
  static String _generateKey(
    String url,
    Options? options, {
    required String policyLabel,
    Object? requestData,
  }) {
    final method = _displayMethod(options);
    final headers = options?.headers?.toString() ?? '';
    final data = requestData?.toString() ?? '';
    return '$policyLabel:$method:$url:$headers:$data';
  }

  static String _displayMethod(Options? options) {
    return (options?.method ?? 'GET').toUpperCase();
  }

  static HttpCachePolicy policyFor(HttpCacheScene scene) {
    return _policies[scene] ?? _defaultPolicies[scene]!;
  }

  static Map<HttpCacheScene, HttpCachePolicy> snapshotPolicies() {
    return Map<HttpCacheScene, HttpCachePolicy>.unmodifiable(_policies);
  }

  static void configurePolicy(HttpCachePolicy policy) {
    _policies[policy.scene] = policy;
    LogUtils.d(
      'HTTP缓存策略更新: scene=${policy.label}, '
      'ttl=${_formatDuration(policy.ttl)}, '
      'dedupe=${policy.enableDeduplication}',
    );
  }

  static void resetPolicies() {
    _policies
      ..clear()
      ..addAll(_defaultPolicies);
    LogUtils.d('HTTP缓存策略已重置为默认配置');
  }

  /// 获取当前缓存统计快照。
  static HttpCacheStats snapshotStats() {
    return HttpCacheStats(
      totalRequests: _totalRequests,
      cacheableRequests: _cacheableRequests,
      cacheHits: _cacheHits,
      cacheMisses: _cacheMisses,
      deduplicatedRequests: _deduplicatedRequests,
      networkRequests: _networkRequests,
      cacheWrites: _cacheWrites,
      evictionCount: _evictionCount,
      expiredRemovalCount: _expiredRemovalCount,
      manualInvalidationCount: _manualInvalidationCount,
      errorCount: _errorCount,
      cachedEntries: _cache.length,
      pendingRequests: _pendingRequests.length,
      entries: _cache.values
          .map(
            (entry) => HttpCacheEntrySnapshot(
              policyLabel: entry.policyLabel,
              method: entry.method,
              url: entry.url,
              statusCode: entry.response.statusCode,
              createdAt: entry.createdAt,
              lastAccessTime: entry.lastAccessTime,
              expireTime: entry.expireTime,
              hitCount: entry.hitCount,
            ),
          )
          .toList(growable: false),
    );
  }

  /// 主动输出缓存快照，便于在性能排查时观察命中率与缓存容量。
  static void logStats({String reason = 'manual'}) {
    LogUtils.d('HTTP缓存统计[$reason]: ${snapshotStats()}');
  }

  /// 发起请求（带缓存和去重）
  static Future<Response> request(
    Future<Response> Function() requestFn, {
    required String url,
    Options? options,
    Object? requestData,
    Duration? cacheDuration,
    HttpCacheScene? cacheScene,
    HttpCachePolicy? cachePolicy,
  }) async {
    final policy = _resolvePolicy(
      cacheDuration: cacheDuration,
      cacheScene: cacheScene,
      cachePolicy: cachePolicy,
    );
    final effectiveCacheDuration = policy.isCacheEnabled ? policy.ttl : null;
    final cacheKey = _generateKey(
      url,
      options,
      policyLabel: policy.label,
      requestData: requestData,
    );
    final requestLabel = '[${policy.label}] ${_displayMethod(options)} $url';
    _totalRequests += 1;

    // 1. 检查缓存
    if (effectiveCacheDuration != null) {
      _cacheableRequests += 1;
      final cached = _cache[cacheKey];
      if (cached != null) {
        if (!cached.isExpired) {
          _cacheHits += 1;
          cached.recordHit();
          LogUtils.d(
            'HTTP缓存命中: $requestLabel, ttl=${cached.remainingTtl.inSeconds}s, '
            'hits=${cached.hitCount}',
          );
          return cached.response;
        }

        _cacheMisses += 1;
        _removeCacheEntry(
          cacheKey,
          reason: '过期',
          countsAsExpiredRemoval: true,
          logMessage: 'HTTP缓存过期: $requestLabel, 已移除并回退到网络请求',
        );
      } else {
        _cacheMisses += 1;
      }
    }

    // 2. 检查是否有相同请求正在进行（请求去重）
    if (policy.enableDeduplication) {
      final pending = _pendingRequests[cacheKey];
      if (pending != null) {
        _deduplicatedRequests += 1;
        LogUtils.d(
          'HTTP请求去重命中: $requestLabel, pending=${_pendingRequests.length}',
        );
        return pending;
      }
    }

    // 3. 发起新请求
    _networkRequests += 1;
    final future = Future<Response>.sync(requestFn);
    if (policy.enableDeduplication) {
      _pendingRequests[cacheKey] = future;
    }

    try {
      final response = await future;
      final method = _displayMethod(options);
      final canCacheResponse = effectiveCacheDuration != null &&
          (method == 'GET' || method == 'HEAD') &&
          (response.statusCode ?? 0) >= 200 &&
          (response.statusCode ?? 0) < 300;
      if (canCacheResponse) {
        _ensureCacheSize();
        _cache[cacheKey] = CachedResponse(
          response: response,
          policyLabel: policy.label,
          method: method,
          url: url,
          duration: effectiveCacheDuration,
        );
        _cacheWrites += 1;
        LogUtils.d(
          'HTTP缓存写入: $requestLabel, ttl=${effectiveCacheDuration.inSeconds}s, '
          'size=${_cache.length}/$_maxCacheSize',
        );
      }
      return response;
    } catch (error, stackTrace) {
      _errorCount += 1;
      LogUtils.w(
        'HTTP缓存请求失败: $requestLabel',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      if (policy.enableDeduplication) {
        _pendingRequests.remove(cacheKey);
      }
    }
  }

  /// 确保缓存不超过最大限制
  static void _ensureCacheSize() {
    clearExpiredCache();

    while (_cache.length >= _maxCacheSize) {
      final oldestEntry = _cache.entries.first;
      _removeCacheEntry(
        oldestEntry.key,
        reason: '容量淘汰',
        countsAsEviction: true,
        logMessage:
            'HTTP缓存淘汰: ${oldestEntry.value.label}, hits=${oldestEntry.value.hitCount}, '
            'size=${_cache.length - 1}/$_maxCacheSize',
      );
    }
  }

  /// 清除指定 URL 的缓存
  static void clearCache(
    String url, {
    Options? options,
    Object? requestData,
    HttpCacheScene? cacheScene,
    HttpCachePolicy? cachePolicy,
  }) {
    final policy = _resolvePolicy(
      cacheScene: cacheScene,
      cachePolicy: cachePolicy,
    );
    final cacheKey = _generateKey(
      url,
      options,
      policyLabel: policy.label,
      requestData: requestData,
    );
    final requestLabel = '[${policy.label}] ${_displayMethod(options)} $url';
    final removed = _removeCacheEntry(
      cacheKey,
      reason: '手动清理',
      countsAsManualInvalidation: true,
      logMessage: 'HTTP缓存清理: $requestLabel',
    );
    if (removed == null) {
      LogUtils.d('HTTP缓存清理跳过: $requestLabel, entry=missing');
    }
  }

  /// 清除所有缓存
  static void clearAllCache() {
    final removed = _cache.length;
    if (removed == 0) return;
    _manualInvalidationCount += removed;
    _cache.clear();
    LogUtils.d('HTTP缓存全部清理: removed=$removed');
  }

  /// 清除过期缓存
  static void clearExpiredCache() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList(growable: false);
    if (expiredKeys.isEmpty) return;

    for (final cacheKey in expiredKeys) {
      _removeCacheEntry(
        cacheKey,
        reason: '批量过期清理',
        countsAsExpiredRemoval: true,
        shouldLog: false,
      );
    }
    LogUtils.d(
      'HTTP过期缓存清理: removed=${expiredKeys.length}, '
      'size=${_cache.length}/$_maxCacheSize',
    );
  }

  static HttpCachePolicy _resolvePolicy({
    Duration? cacheDuration,
    HttpCacheScene? cacheScene,
    HttpCachePolicy? cachePolicy,
  }) {
    if (cachePolicy != null) {
      return cachePolicy;
    }
    if (cacheDuration != null) {
      return HttpCachePolicy(
        scene: cacheScene ?? HttpCacheScene.generic,
        ttl: cacheDuration,
      );
    }
    if (cacheScene != null) {
      return policyFor(cacheScene);
    }
    return policyFor(HttpCacheScene.generic);
  }

  static String _formatDuration(Duration? duration) {
    if (duration == null) return 'disabled';
    return '${duration.inSeconds}s';
  }

  static CachedResponse? _removeCacheEntry(
    String cacheKey, {
    required String reason,
    bool countsAsEviction = false,
    bool countsAsExpiredRemoval = false,
    bool countsAsManualInvalidation = false,
    bool shouldLog = true,
    String? logMessage,
  }) {
    final removed = _cache.remove(cacheKey);
    if (removed == null) return null;

    if (countsAsEviction) _evictionCount += 1;
    if (countsAsExpiredRemoval) _expiredRemovalCount += 1;
    if (countsAsManualInvalidation) _manualInvalidationCount += 1;

    if (!shouldLog) {
      return removed;
    }

    if (logMessage != null) {
      LogUtils.d(logMessage);
    } else if (reason.isNotEmpty) {
      LogUtils.d('HTTP缓存移除: ${removed.label}, reason=$reason');
    }
    return removed;
  }
}
