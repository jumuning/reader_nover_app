import 'dart:convert';

/// Legado 风格发现筛选定义（exploreScreen）。
///
/// 支持：
/// 1. JSON 数组：`[{ "name":"排序", "key":"sort", "value":"新", "options":["新","热"] }]`
/// 2. 多行文本：`排序::sort::新|热` 或 `排序::新|热`（key 默认 name）
class ExploreScreenField {
  const ExploreScreenField({
    required this.name,
    required this.key,
    required this.options,
    this.defaultValue,
  });

  final String name;
  final String key;
  final List<String> options;
  final String? defaultValue;

  String get initialValue {
    final preferred = defaultValue?.trim() ?? '';
    if (preferred.isNotEmpty) return preferred;
    return options.isNotEmpty ? options.first : '';
  }
}

class ExploreScreenParser {
  const ExploreScreenParser._();

  static List<ExploreScreenField> parse(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return const [];

    if (text.startsWith('[')) {
      return _parseJsonArray(text);
    }
    return _parseLineRules(text);
  }

  static List<ExploreScreenField> _parseJsonArray(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! List) return const [];
      final out = <ExploreScreenField>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final name =
            '${item['title'] ?? item['name'] ?? item['label'] ?? ''}'.trim();
        if (name.isEmpty) continue;
        final key =
            '${item['name'] ?? item['key'] ?? item['id'] ?? item['paramKey'] ?? name}'
                .trim();
        final options = _stringList(
          item['chars'] ?? item['options'] ?? item['values'] ?? item['items'],
        );
        final value =
            '${item['default'] ?? item['defaultValue'] ?? item['value'] ?? ''}'
                .trim();
        out.add(
          ExploreScreenField(
            name: name,
            key: key.isEmpty ? name : key,
            options: options,
            defaultValue: value.isEmpty ? null : value,
          ),
        );
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  static List<ExploreScreenField> _parseLineRules(String text) {
    final out = <ExploreScreenField>[];
    for (final line in text.split(RegExp(r'[\r\n]+'))) {
      final raw = line.trim();
      if (raw.isEmpty || raw.startsWith('//') || raw.startsWith('#')) {
        continue;
      }
      final parts = raw.split('::').map((e) => e.trim()).toList();
      if (parts.isEmpty || parts.first.isEmpty) continue;

      if (parts.length == 1) {
        out.add(
          ExploreScreenField(
            name: parts[0],
            key: parts[0],
            options: const [],
          ),
        );
        continue;
      }

      if (parts.length == 2) {
        // name::opt1|opt2  or name::default
        final second = parts[1];
        if (second.contains('|')) {
          final options = second
              .split('|')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          out.add(
            ExploreScreenField(
              name: parts[0],
              key: parts[0],
              options: options,
            ),
          );
        } else {
          out.add(
            ExploreScreenField(
              name: parts[0],
              key: parts[0],
              options: second.isEmpty ? const [] : [second],
              defaultValue: second.isEmpty ? null : second,
            ),
          );
        }
        continue;
      }

      // name::key::opt1|opt2  or name::key::default
      final key = parts[1].isEmpty ? parts[0] : parts[1];
      final third = parts.sublist(2).join('::');
      if (third.contains('|')) {
        final options = third
            .split('|')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        out.add(
          ExploreScreenField(
            name: parts[0],
            key: key,
            options: options,
          ),
        );
      } else {
        out.add(
          ExploreScreenField(
            name: parts[0],
            key: key,
            options: third.isEmpty ? const [] : [third],
            defaultValue: third.isEmpty ? null : third,
          ),
        );
      }
    }
    return out;
  }

  static List<String> _stringList(Object? raw) {
    if (raw is List) {
      return raw
          .map((e) => '$e'.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(RegExp(r'[,|，、]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }
}
