import 'dart:convert';
import 'dart:io';

import 'source_check_report.dart';

enum SourceCheckDiagnosticMode { batch, live }

class SourceCheckDiagnosticRecord {
  const SourceCheckDiagnosticRecord({
    required this.schemaVersion,
    required this.createdAt,
    required this.mode,
    required this.stages,
    this.sourceId,
    this.sourceNameHash,
    this.status,
    this.summary,
    this.elapsedMs,
    this.failureClass,
  });

  factory SourceCheckDiagnosticRecord.create({
    required SourceCheckDiagnosticMode mode,
    required List<SourceCheckStageReport> stages,
    int? sourceId,
    String? sourceName,
    String? status,
    String? summary,
    int? elapsedMs,
    SourceCheckFailureClass? failureClass,
    DateTime? createdAt,
  }) {
    final sourceNameHash = _hashNullable(sourceName);
    return SourceCheckDiagnosticRecord(
      schemaVersion: SourceCheckDiagnosticsStore.schemaVersion,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
      mode: mode,
      sourceId: sourceId,
      sourceNameHash: sourceNameHash,
      status: _sanitizeNullableString(status),
      summary: _sanitizeNullableString(summary, redactedText: sourceName),
      elapsedMs: elapsedMs,
      failureClass: failureClass,
      stages: stages.map(_stageToJson).toList(growable: false),
    );
  }

  factory SourceCheckDiagnosticRecord.fromJson(Map<String, Object?> json) {
    final rawStages = json['stages'];
    return SourceCheckDiagnosticRecord(
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '')?.toUtc() ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      mode: _parseMode(json['mode']),
      sourceId: (json['source_id'] as num?)?.toInt(),
      sourceNameHash: _sanitizeNullableString(json['source_name_hash']),
      status: _sanitizeNullableString(json['status']),
      summary: _sanitizeNullableString(json['summary']),
      elapsedMs: (json['elapsed_ms'] as num?)?.toInt(),
      failureClass: _parseFailureClass(json['failure_class']),
      stages: rawStages is List
          ? rawStages
              .whereType<Map>()
              .map((stage) => _sanitizeJsonMap(stage.cast<String, Object?>()))
              .toList(growable: false)
          : const <Map<String, Object?>>[],
    );
  }

  final int schemaVersion;
  final DateTime createdAt;
  final SourceCheckDiagnosticMode mode;
  final int? sourceId;
  final String? sourceNameHash;
  final String? status;
  final String? summary;
  final int? elapsedMs;
  final SourceCheckFailureClass? failureClass;
  final List<Map<String, Object?>> stages;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'schema_version': schemaVersion,
      'created_at': createdAt.toUtc().toIso8601String(),
      'mode': mode.name,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceNameHash != null) 'source_name_hash': sourceNameHash,
      if (status != null) 'status': status,
      if (summary != null) 'summary': summary,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (failureClass != null) 'failure_class': failureClass!.name,
      'stages': stages,
    };
  }
}

class SourceCheckDiagnosticsStore {
  SourceCheckDiagnosticsStore({
    File? file,
    int maxMemoryRecords = 200,
  })  : _file = file,
        _maxMemoryRecords = maxMemoryRecords < 1 ? 1 : maxMemoryRecords;

  static const int schemaVersion = 1;
  static final SourceCheckDiagnosticsStore instance =
      SourceCheckDiagnosticsStore();

  final File? _file;
  final int _maxMemoryRecords;
  final List<SourceCheckDiagnosticRecord> _memory =
      <SourceCheckDiagnosticRecord>[];

  Future<SourceCheckDiagnosticRecord> append({
    required SourceCheckDiagnosticMode mode,
    required List<SourceCheckStageReport> stages,
    int? sourceId,
    String? sourceName,
    String? status,
    String? summary,
    int? elapsedMs,
    SourceCheckFailureClass? failureClass,
    DateTime? createdAt,
  }) async {
    final record = SourceCheckDiagnosticRecord.create(
      mode: mode,
      stages: stages,
      sourceId: sourceId,
      sourceName: sourceName,
      status: status,
      summary: summary,
      elapsedMs: elapsedMs,
      failureClass: failureClass,
      createdAt: createdAt,
    );
    _remember(record);

    final file = _file;
    if (file != null) {
      await file.parent.create(recursive: true);
      await file.writeAsString(
        '${jsonEncode(record.toJson())}\n',
        mode: FileMode.append,
        flush: true,
      );
    }

    return record;
  }

  Future<List<SourceCheckDiagnosticRecord>> readRecent({int limit = 50}) async {
    final effectiveLimit = limit < 1 ? 1 : limit;
    final file = _file;
    if (file == null || !await file.exists()) {
      return _lastMemoryRecords(effectiveLimit);
    }

    final lines = await file.readAsLines();
    final records = <SourceCheckDiagnosticRecord>[];
    for (final line in lines.reversed) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final record = _recordFromJsonLine(trimmed);
      if (record == null) continue;
      records.add(record);
      if (records.length >= effectiveLimit) break;
    }
    return records.reversed.toList(growable: false);
  }

  Future<String> exportJsonLines({int limit = 200}) async {
    final records = await readRecent(limit: limit);
    return records.map((record) => jsonEncode(record.toJson())).join('\n');
  }

  List<SourceCheckDiagnosticRecord> recentMemoryRecords({int limit = 50}) {
    return _lastMemoryRecords(limit < 1 ? 1 : limit);
  }

  void clearMemory() {
    _memory.clear();
  }

  void _remember(SourceCheckDiagnosticRecord record) {
    _memory.add(record);
    if (_memory.length > _maxMemoryRecords) {
      _memory.removeRange(0, _memory.length - _maxMemoryRecords);
    }
  }

  List<SourceCheckDiagnosticRecord> _lastMemoryRecords(int limit) {
    final start = _memory.length > limit ? _memory.length - limit : 0;
    return List<SourceCheckDiagnosticRecord>.unmodifiable(
      _memory.sublist(start),
    );
  }

  static SourceCheckDiagnosticRecord? _recordFromJsonLine(String line) {
    try {
      final decoded = jsonDecode(line);
      if (decoded is! Map) return null;
      return SourceCheckDiagnosticRecord.fromJson(
        decoded.cast<String, Object?>(),
      );
    } catch (_) {
      return null;
    }
  }
}

Map<String, Object?> _stageToJson(SourceCheckStageReport report) {
  return <String, Object?>{
    'stage': report.stage.name,
    'stage_name': SourceCheckReport.stageLabel(report.stage),
    'ok': report.ok,
    'elapsed_ms': report.elapsedMs,
    if (report.message != null)
      'message': _sanitizeNullableString(report.message),
    if (report.failureClass != null) 'failure_class': report.failureClass!.name,
    'diagnostics': SourceCheckReport.sanitizeDiagnostics(report.diagnostics),
  };
}

Map<String, Object?> _sanitizeJsonMap(Map<String, Object?> json) {
  final sanitized = <String, Object?>{};
  for (final entry in json.entries) {
    final key = _sanitizeKey(entry.key);
    if (key == null) continue;
    final value = entry.value;
    if (value == null || value is num || value is bool) {
      sanitized[key] = value;
    } else if (value is String) {
      sanitized[key] = _sanitizeString(value);
    } else if (value is Map) {
      sanitized[key] = _sanitizeJsonMap(value.cast<String, Object?>());
    } else if (value is List) {
      sanitized[key] = value
          .map(_sanitizeJsonValue)
          .where((item) => item != _droppedValue)
          .toList(growable: false);
    }
  }
  return Map.unmodifiable(sanitized);
}

Object? _sanitizeJsonValue(Object? value) {
  if (value == null || value is num || value is bool) return value;
  if (value is String) return _sanitizeString(value);
  if (value is Map) return _sanitizeJsonMap(value.cast<String, Object?>());
  return _droppedValue;
}

const Object _droppedValue = Object();

String? _sanitizeKey(String raw) {
  final key = raw.trim();
  if (key.isEmpty || _isSensitiveKey(key)) return null;
  return key;
}

bool _isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  return lower.contains('url') ||
      lower.contains('html') ||
      lower.contains('preview') ||
      lower.contains('keyword') ||
      lower.contains('cookie') ||
      lower.contains('token') ||
      lower.contains('header') ||
      lower.contains('password') ||
      lower.contains('authorization');
}

String? _sanitizeNullableString(Object? value, {String? redactedText}) {
  if (value == null) return null;
  final sanitized =
      _sanitizeString(value.toString(), redactedText: redactedText);
  return sanitized.isEmpty ? null : sanitized;
}

String _sanitizeString(String value, {String? redactedText}) {
  var sanitized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  final textToRedact = redactedText?.trim();
  if (textToRedact != null && textToRedact.isNotEmpty) {
    sanitized = sanitized.replaceAll(textToRedact, '[redacted_source]');
  }
  sanitized = sanitized.replaceAll(
    RegExp("https?://[^\\s<>\"']+", caseSensitive: false),
    '[redacted_url]',
  );
  sanitized = sanitized.replaceAll(
    RegExp(
      r'\b(cookie|token|authorization|password|header)\b\s*[:=]\s*[^,\s;]+',
      caseSensitive: false,
    ),
    r'$1=[redacted]',
  );
  if (sanitized.length <= 240) return sanitized;
  return '${sanitized.substring(0, 240)}...';
}

String? _hashNullable(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;

  var hash = 0x811c9dc5;
  for (final unit in utf8.encode(text)) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

SourceCheckDiagnosticMode _parseMode(Object? value) {
  final name = value?.toString();
  return SourceCheckDiagnosticMode.values.firstWhere(
    (mode) => mode.name == name,
    orElse: () => SourceCheckDiagnosticMode.batch,
  );
}

SourceCheckFailureClass? _parseFailureClass(Object? value) {
  final name = value?.toString();
  if (name == null) return null;
  for (final failureClass in SourceCheckFailureClass.values) {
    if (failureClass.name == name) return failureClass;
  }
  return null;
}
