import 'package:dio/dio.dart';

class LegadoBookSourceType {
  const LegadoBookSourceType._();

  static const int text = 0;
  static const int audio = 1;
  static const int image = 2;
  static const int file = 3;
}

class SourceCheckTags {
  const SourceCheckTags._();

  static const String timeout = '校验超时';
  static const String transientNetwork = '网络异常';
  static const String searchUrlEmpty = '搜索链接规则为空';
  static const String discoveryRuleEmpty = '发现规则为空';
}

class SourceCheckToggles {
  const SourceCheckToggles({
    required this.checkSearch,
    required this.checkDiscovery,
    required this.checkInfo,
    required this.checkCategory,
    required this.checkContent,
  });

  final bool checkSearch;
  final bool checkDiscovery;
  final bool checkInfo;
  final bool checkCategory;
  final bool checkContent;
}

class SourceCheckPolicy {
  const SourceCheckPolicy._();

  static const String defaultKeyword = '我的';
  static const int defaultTimeoutMs = 180000;
  static const int minRequestTimeoutMs = 5000;
  static const int maxRequestTimeoutMs = 600000;
  /// Cap for multi-source probe paths (e.g. 换源) so UI stays responsive.
  static const int maxProbeTimeoutMs = 30000;
  static const int defaultConcurrency = 9;
  static const int minConcurrency = 1;
  static const int maxConcurrency = 16;
  /// Align stage budgets with Legado default `respondTime` (180s).
  /// Previously 15s killed slow search/ajax before platform retry finished.
  static const Duration searchCheckTimeout =
      Duration(milliseconds: defaultTimeoutMs);
  static const Duration discoveryCheckTimeout =
      Duration(milliseconds: defaultTimeoutMs);
  static const Duration detailCheckTimeout =
      Duration(milliseconds: defaultTimeoutMs);
  static const Duration tocCheckTimeout =
      Duration(milliseconds: defaultTimeoutMs);
  static const Duration contentCheckTimeout =
      Duration(milliseconds: defaultTimeoutMs);
  static const int maxDiscoveryCandidates = 1;
  static const int transientNetworkRetryCount = 1;
  static const Duration transientNetworkRetryDelay =
      Duration(milliseconds: 350);

  static String normalizeKeyword(String? keyword) {
    final trimmed = keyword?.trim();
    return trimmed == null || trimmed.isEmpty ? defaultKeyword : trimmed;
  }

  static int normalizeTimeoutMs(int value) {
    return value > 0 ? value : defaultTimeoutMs;
  }

  /// Single-request timeout from book source `respondTime` (ms).
  /// Defaults to Legado 180s and clamps to a safe range.
  static int normalizeRequestTimeoutMs(int? respondTimeMs) {
    final raw = respondTimeMs ?? defaultTimeoutMs;
    if (raw <= 0) {
      return defaultTimeoutMs;
    }
    return raw.clamp(minRequestTimeoutMs, maxRequestTimeoutMs).toInt();
  }

  static Duration requestTimeout(int? respondTimeMs) {
    return Duration(milliseconds: normalizeRequestTimeoutMs(respondTimeMs));
  }

  /// Shorter budget for concurrent multi-source probes (换源等).
  static int normalizeProbeTimeoutMs(int? respondTimeMs) {
    final full = normalizeRequestTimeoutMs(respondTimeMs);
    return full.clamp(minRequestTimeoutMs, maxProbeTimeoutMs).toInt();
  }

  static Duration probeTimeout(int? respondTimeMs) {
    return Duration(milliseconds: normalizeProbeTimeoutMs(respondTimeMs));
  }

  static bool isValidTimeoutSeconds(int value) {
    return value > 0;
  }

  static int normalizeConcurrency(int? value) {
    final raw = value ?? defaultConcurrency;
    return raw.clamp(minConcurrency, maxConcurrency).toInt();
  }

  static bool isValidConcurrency(int value) {
    return value >= minConcurrency && value <= maxConcurrency;
  }

  static SourceCheckToggles normalizeToggles({
    required bool checkSearch,
    required bool checkDiscovery,
    required bool checkInfo,
    required bool checkCategory,
    required bool checkContent,
  }) {
    var normalizedSearch = checkSearch;
    var normalizedDiscovery = checkDiscovery;
    if (!normalizedSearch && !normalizedDiscovery) {
      normalizedSearch = true;
    }

    final normalizedCategory = checkInfo && checkCategory;
    return SourceCheckToggles(
      checkSearch: normalizedSearch,
      checkDiscovery: normalizedDiscovery,
      checkInfo: checkInfo,
      checkCategory: normalizedCategory,
      checkContent: checkInfo && normalizedCategory && checkContent,
    );
  }

  static bool shouldSkipDiscovery(String? exploreUrl) {
    return exploreUrl == null || exploreUrl.trim().isEmpty;
  }

  static bool shouldSkipDetail(bool checkInfo) {
    return !checkInfo;
  }

  static bool shouldSkipCategory({
    required bool checkCategory,
    required int? bookSourceType,
  }) {
    return !checkCategory || bookSourceType == LegadoBookSourceType.file;
  }

  static bool isInvalidGroup(String tag) {
    return tag == SourceCheckTags.timeout || tag.contains('失效');
  }

  static bool isCheckTag(String tag) {
    return isInvalidGroup(tag) ||
        tag == SourceCheckTags.searchUrlEmpty ||
        tag == SourceCheckTags.discoveryRuleEmpty;
  }

  static bool isFatalCheckTag(String tag) {
    return isInvalidGroup(tag);
  }

  static bool isTransientNetworkFailure(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.cancel) {
        return false;
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode ?? 0;
          return status == 408 ||
              status == 429 ||
              status == 500 ||
              status == 502 ||
              status == 503 ||
              status == 504 ||
              status == 522 ||
              status == 524;
        case DioExceptionType.unknown:
          return _hasTransientNetworkMessage([
            error.message,
            error.error?.toString(),
            error.toString(),
          ]);
        case DioExceptionType.cancel:
        case DioExceptionType.badCertificate:
          return false;
      }
    }

    return _hasTransientNetworkMessage([error.toString()]);
  }

  static bool _hasTransientNetworkMessage(Iterable<String?> messages) {
    final message = messages
        .where((item) => item != null && item.trim().isNotEmpty)
        .join('\n')
        .toLowerCase();
    if (message.isEmpty) {
      return false;
    }

    return message.contains('connection reset') ||
        message.contains('connection refused') ||
        message.contains('connection closed') ||
        message.contains('connection aborted') ||
        message.contains('connection terminated') ||
        message.contains('broken pipe') ||
        message.contains('failed host lookup') ||
        message.contains('host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('no route to host') ||
        message.contains('software caused connection abort') ||
        message.contains('socketexception') ||
        message.contains('handshakeexception') ||
        message.contains('temporarily unavailable') ||
        message.contains('operation timed out') ||
        message.contains('timed out') ||
        message.contains('os error') ||
        message.contains('errno');
  }
}
