class ServiceError {
  const ServiceError({
    required this.code,
    required this.userMessage,
    this.debugMessage,
    this.context = const <String, Object?>{},
    this.cause,
    this.stackTrace,
  });

  final String code;
  final String userMessage;
  final String? debugMessage;
  final Map<String, Object?> context;
  final Object? cause;
  final StackTrace? stackTrace;

  String? get formattedDebugDetail {
    final lines = <String>[
      'code: $code',
      if (debugMessage != null && debugMessage!.trim().isNotEmpty)
        debugMessage!.trim(),
      if (cause != null) 'cause: $cause',
      ...context.entries
          .where((entry) => entry.value != null)
          .map((entry) => '${entry.key}: ${entry.value}'),
    ];
    if (lines.isEmpty) {
      return null;
    }
    return lines.join('\n');
  }

  String formatForLog() {
    final detail = formattedDebugDetail;
    if (detail == null || detail.isEmpty) {
      return '[$code] $userMessage';
    }
    return '[$code] $userMessage\n$detail';
  }
}

class ServiceResult<T> {
  const ServiceResult._({
    this.data,
    this.error,
  });

  factory ServiceResult.success([T? data]) {
    return ServiceResult<T>._(data: data);
  }

  factory ServiceResult.failure(ServiceError error) {
    return ServiceResult<T>._(error: error);
  }

  final T? data;
  final ServiceError? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  T requireData() {
    if (isFailure) {
      throw StateError('当前结果没有可用数据: ${error!.code}');
    }
    return data as T;
  }
}

abstract final class ServiceErrorCodes {
  static const invalidInput = 'common.invalid_input';
  static const timeout = 'common.timeout';
  static const cancelled = 'common.cancelled';
  static const unexpected = 'common.unexpected';

  static const contentNetworkDisabled = 'book.content.network_disabled';
  static const contentChapterUrlMissing = 'book.content.chapter_url_missing';
  static const contentSourceMissing = 'book.content.source_missing';
  static const contentFetchFailed = 'book.content.fetch_failed';
  static const contentEmpty = 'book.content.empty';
  static const contentLocalCacheMissing = 'book.content.local_cache_missing';

  static const changeSourceFailed = 'book.change.failed';
  static const changeSourceChaptersEmpty = 'book.change.chapter_list_empty';

  static const sourceTestSearchFailed = 'source.test.search_failed';
  static const sourceTestSearchEmpty = 'source.test.search_empty';
  static const sourceTestDetailFailed = 'source.test.detail_failed';
  static const sourceTestTocFailed = 'source.test.toc_failed';
  static const sourceTestTocEmpty = 'source.test.toc_empty';
  static const sourceTestContentFailed = 'source.test.content_failed';
}

String? mergeDebugDetails(Iterable<String?> parts) {
  final values = parts
      .map((part) => part?.trim())
      .where((part) => part != null && part.isNotEmpty)
      .cast<String>()
      .toList(growable: false);
  if (values.isEmpty) {
    return null;
  }
  return values.join('\n');
}
