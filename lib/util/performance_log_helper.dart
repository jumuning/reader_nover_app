import 'log_utils.dart';

class PerformanceLogScope {
  PerformanceLogScope._({
    required this.scope,
    required Map<String, Object?> fields,
  })  : _fields = Map<String, Object?>.unmodifiable(
          Map<String, Object?>.from(fields),
        ),
        _stopwatch = Stopwatch()..start();

  final String scope;
  final Map<String, Object?> _fields;
  final Stopwatch _stopwatch;
  bool _completed = false;

  void complete({Map<String, Object?> fields = const {}}) {
    if (_completed) return;
    _completed = true;
    _stopwatch.stop();
    PerformanceLogHelper.log(
      scope,
      fields: <String, Object?>{
        ..._fields,
        ...fields,
        'elapsedMs': _stopwatch.elapsedMilliseconds,
      },
    );
  }

  T completeWith<T>(
    T value, {
    Map<String, Object?> fields = const {},
  }) {
    complete(fields: fields);
    return value;
  }
}

class PerformanceLogHelper {
  const PerformanceLogHelper._();

  static PerformanceLogScope start(
    String scope, {
    Map<String, Object?> fields = const {},
  }) {
    return PerformanceLogScope._(scope: scope, fields: fields);
  }

  static void log(
    String scope, {
    Map<String, Object?> fields = const {},
  }) {
    final suffix = _formatFields(fields);
    LogUtils.d(suffix.isEmpty ? '[perf][$scope]' : '[perf][$scope] $suffix');
  }

  /// 供垂直阅读窗口化链路接入统一观测；当前调用点在禁改文件外预留接口。
  static void logVerticalWindow({
    required String event,
    required int mountedChapterCount,
    int? visibleChapterIndex,
    int? trimmedChapterCount,
    double? removedLeadingExtent,
  }) {
    log(
      'reader.verticalWindow',
      fields: <String, Object?>{
        'event': event,
        'mountedChapterCount': mountedChapterCount,
        'visibleChapterIndex': visibleChapterIndex,
        'trimmedChapterCount': trimmedChapterCount,
        'removedLeadingExtent': removedLeadingExtent,
      },
    );
  }

  static String _formatFields(Map<String, Object?> fields) {
    final parts = <String>[];
    fields.forEach((key, value) {
      if (value == null) return;
      parts.add('$key=${_formatValue(value)}');
    });
    return parts.join(', ');
  }

  static String _formatValue(Object value) {
    if (value is double) {
      return value.toStringAsFixed(2);
    }
    return value.toString().replaceAll('\n', r'\n');
  }
}
