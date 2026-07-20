import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:reader_nover/pages/book_read/page_turn/pagination_service.dart';

/// 将阅读页文本中的 `<img>` 拆成 TextSpan + WidgetSpan（data URL / 网络图）。
///
/// 默认 [maxImageHeight]/[maxImageWidth] 与 [PaginationService] 占位常量一致。
/// 分页测量侧会按 `availableHeight - titleReserve - padding` 再 clamp；
/// 渲染侧若已知可用高度，也应传入已 clamp 的 [maxImageHeight]，避免超高图溢出。
List<InlineSpan> buildReaderContentSpans({
  required String content,
  required TextStyle style,
  double maxImageWidth = PaginationService.imagePlaceholderMaxWidth,
  double maxImageHeight = PaginationService.imagePlaceholderMaxHeight,
}) {
  if (content.isEmpty) {
    return <InlineSpan>[TextSpan(text: content, style: style)];
  }
  if (!_hasImgTag(content)) {
    return <InlineSpan>[TextSpan(text: content, style: style)];
  }

  final pattern = RegExp(
    r'''<img\b[^>]*?\bsrc\s*=\s*["']([^"']+)["'][^>]*>''',
    caseSensitive: false,
  );
  final spans = <InlineSpan>[];
  var cursor = 0;
  for (final match in pattern.allMatches(content)) {
    if (match.start > cursor) {
      final text = content.substring(cursor, match.start);
      if (text.isNotEmpty) {
        spans.add(TextSpan(text: text, style: style));
      }
    }
    final src = match.group(1)?.trim() ?? '';
    if (src.isNotEmpty) {
      spans.add(const TextSpan(text: '\n'));
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _ReaderInlineImage(
              src: src,
              maxWidth: maxImageWidth,
              maxHeight: maxImageHeight,
            ),
          ),
        ),
      );
      spans.add(const TextSpan(text: '\n'));
    }
    cursor = match.end;
  }
  if (cursor < content.length) {
    final text = content.substring(cursor);
    if (text.isNotEmpty) {
      spans.add(TextSpan(text: text, style: style));
    }
  }
  if (spans.isEmpty) {
    return <InlineSpan>[TextSpan(text: content, style: style)];
  }
  return spans;
}

bool readerContentHasImages(String content) => _hasImgTag(content);

bool _hasImgTag(String content) {
  final lower = content.toLowerCase();
  return lower.contains('<img');
}

class _ReaderInlineImage extends StatelessWidget {
  const _ReaderInlineImage({
    required this.src,
    required this.maxWidth,
    required this.maxHeight,
  });

  final String src;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: image,
    );
  }

  Widget _buildImage() {
    final data = _tryDecodeDataUrl(src);
    if (data != null) {
      return Image.memory(
        data,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
      );
    }
    final uri = Uri.tryParse(src);
    if (uri?.scheme == 'file') {
      return Image.file(
        File.fromUri(uri!),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.broken_image_outlined, size: 28),
    );
  }

  Uint8List? _tryDecodeDataUrl(String raw) {
    final match = RegExp(
      r'^data:.*?;base64,(.+)$',
      caseSensitive: false,
    ).firstMatch(raw.trim());
    if (match == null) return null;
    try {
      return Uint8List.fromList(base64Decode(match.group(1)!.trim()));
    } catch (_) {
      return null;
    }
  }
}
