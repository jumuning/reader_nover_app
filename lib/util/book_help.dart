import 'package:reader_nover/app/constants/app_pattern.dart';

/// Legado `BookHelp` / `StringUtils` / `HtmlFormatter` 文本书字段规范化。
///
/// 参照：
/// - `io.legado.app.help.book.BookHelp.formatBookName/Author`
/// - `io.legado.app.utils.StringUtils.wordCountFormat`
/// - `io.legado.app.utils.HtmlFormatter.format`（简介等纯文本字段）
class BookHelp {
  const BookHelp._();

  // ── HTML 纯文本清洗（简介/短字段，不保留 img）──

  static final _nbspRe = RegExp(r'(&nbsp;)+', caseSensitive: false);
  static final _espRe = RegExp(r'&ensp;|&emsp;', caseSensitive: false);
  static final _thinspRe = RegExp(
    r'&thinsp;|&zwnj;|&zwj;|\u2009|\u200c|\u200d',
    caseSensitive: false,
  );
  static final _noPrintRe = RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f]');
  static final _scriptRe = RegExp(
    r'<script\b[^>]*>[\s\S]*?</script>',
    caseSensitive: false,
  );
  static final _styleRe = RegExp(
    r'<style\b[^>]*>[\s\S]*?</style>',
    caseSensitive: false,
  );
  static final _noscriptRe = RegExp(
    r'<noscript\b[^>]*>[\s\S]*?</noscript>',
    caseSensitive: false,
  );
  static final _commentRe = RegExp(r'<!--[\s\S]*?-->');
  static final _fullwidthBrRe = RegExp(
    r'＜\s*br\s*/?\s*＞',
    caseSensitive: false,
  );
  static final _wrapHtmlRe = RegExp(
    r'</?(?:p|br|hr|div|td|tr|li|ul|ol|blockquote|article|section|dd|dl|dt|h[1-6])\b[^>]*/?>',
    caseSensitive: false,
  );
  static final _anyHtmlTagRe = RegExp(
    r'</?[a-zA-Z][^>]*/?>',
    caseSensitive: false,
  );
  static final _residualTagRe = RegExp(
    r'</?[a-zA-Z][^>]*/?>',
    caseSensitive: false,
  );
  static final _numericEntityRe = RegExp(r'&#(\d+);');
  static final _hexEntityRe = RegExp(
    r'&#x([0-9a-fA-F]+);',
    caseSensitive: false,
  );
  static final _multiNewlineRe = RegExp(r'\n{3,}');
  static final _spaceRunRe = RegExp(r'[^\S\n]{2,}');
  static final _lineTrimRe = RegExp(r'[^\S\n]+$|^\s+', multiLine: true);

  /// 去掉书名尾部「作者 xxx / 著」等噪声。
  static String formatBookName(String? name) {
    final raw = name?.trim() ?? '';
    if (raw.isEmpty) return '';
    return raw.replaceAll(AppPattern.nameRegex, '').trim();
  }

  /// 去掉作者前缀「作者:」与后缀「著」。
  static String formatBookAuthor(String? author) {
    final raw = author?.trim() ?? '';
    if (raw.isEmpty) return '';
    return raw.replaceAll(AppPattern.authorRegex, '').trim();
  }

  /// 纯数字字数格式化为「xx字 / x.x万字」；非数字原样返回。
  static String wordCountFormat(String? wordCount) {
    final raw = wordCount?.trim() ?? '';
    if (raw.isEmpty) return '';
    final words = int.tryParse(raw);
    if (words == null) return raw;
    if (words <= 0) return '';
    if (words > 10000) {
      final wan = words / 10000.0;
      final text = wan >= 100
          ? wan.toStringAsFixed(0)
          : wan
              .toStringAsFixed(1)
              .replaceFirst(RegExp(r'\.0$'), '');
      return '$text万字';
    }
    return '$words字';
  }

  /// 清洗简介等纯文本 HTML 字段（对齐 Legado `HtmlFormatter.format`）。
  ///
  /// - 块级/`br` → 换行
  /// - 剥离全部标签（含 img）
  /// - HTML 实体反转义；反转义后若再暴露标签则二次清洗
  /// - 压缩多余空白，避免阅读页简介出现裸 `<br>` 等残留
  static String formatIntro(String? intro) {
    final raw = intro ?? '';
    if (raw.isEmpty) return '';
    var out = _stripHtmlToText(raw);
    out = _unescapeHtml(out);
    // 实体反转义后可能重新出现 <br>/<p> 等。
    if (_residualTagRe.hasMatch(out) || _fullwidthBrRe.hasMatch(out)) {
      out = _stripHtmlToText(out);
    }
    return _normalizeIntroWhitespace(out);
  }

  static String _stripHtmlToText(String raw) {
    var out = raw;
    out = out.replaceAll(_nbspRe, ' ');
    out = out.replaceAll(_espRe, ' ');
    out = out.replaceAll(_thinspRe, '');
    out = out.replaceAll(_noPrintRe, '');
    out = out.replaceAll(_scriptRe, '');
    out = out.replaceAll(_styleRe, '');
    out = out.replaceAll(_noscriptRe, '');
    out = out.replaceAll(_commentRe, '');
    out = out.replaceAll(_fullwidthBrRe, '\n');
    out = out.replaceAll(_wrapHtmlRe, '\n');
    out = out.replaceAll(_anyHtmlTagRe, '');
    return out;
  }

  static String _unescapeHtml(String text) {
    if (!text.contains('&')) return text;
    // 先解 &amp;，再解 &lt;/&#60; 等；最多两轮覆盖双重实体。
    var out = text;
    for (var i = 0; i < 2; i++) {
      final next = out
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&apos;', "'")
          .replaceAllMapped(_numericEntityRe, (m) {
        final code = int.tryParse(m.group(1)!);
        return (code != null && code > 0 && code <= 0x10FFFF)
            ? String.fromCharCode(code)
            : m.group(0)!;
      }).replaceAllMapped(_hexEntityRe, (m) {
        final code = int.tryParse(m.group(1)!, radix: 16);
        return (code != null && code > 0 && code <= 0x10FFFF)
            ? String.fromCharCode(code)
            : m.group(0)!;
      });
      if (next == out) break;
      out = next;
    }
    return out;
  }

  static String _normalizeIntroWhitespace(String text) {
    var out = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    out = out.replaceAll(_spaceRunRe, ' ');
    out = out.replaceAll(_lineTrimRe, '');
    out = out.replaceAll(_multiNewlineRe, '\n\n');
    return out.trim();
  }
}
