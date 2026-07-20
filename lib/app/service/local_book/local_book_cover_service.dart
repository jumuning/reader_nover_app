import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class LocalBookCoverService {
  const LocalBookCoverService();

  static const int width = 600;
  static const int height = 900;
  static const String fileName = 'cover.png';

  static const List<(Color, Color)> _palettes = [
    (Color(0xFF34495E), Color(0xFFE9C46A)),
    (Color(0xFF315C4C), Color(0xFFF2CC8F)),
    (Color(0xFF713E5A), Color(0xFFE8C1C5)),
    (Color(0xFF3D405B), Color(0xFF81B29A)),
    (Color(0xFF4B5563), Color(0xFFD97706)),
    (Color(0xFF264653), Color(0xFFE76F51)),
  ];

  Future<String> ensureGeneratedCover({
    required Directory bookDirectory,
    required String title,
    String? author,
  }) async {
    final file = File(p.join(bookDirectory.path, fileName));
    if (await file.exists() && await file.length() > 0) {
      return file.uri.toString();
    }
    await bookDirectory.create(recursive: true);
    final bytes = await _render(title: title, author: author);
    await file.writeAsBytes(bytes, flush: true);
    return file.uri.toString();
  }

  Future<List<int>> _render({
    required String title,
    required String? author,
  }) async {
    final normalizedTitle = title.trim().isEmpty ? '未命名书籍' : title.trim();
    final normalizedAuthor = author?.trim() ?? '';
    final palette = _palettes[
        _stableHash('$normalizedTitle\u0000$normalizedAuthor') %
            _palettes.length];
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(600, 900);
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.$1);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 18, 900),
      Paint()..color = palette.$2,
    );
    canvas.drawRect(
      const Rect.fromLTWH(72, 112, 68, 8),
      Paint()..color = palette.$2,
    );

    final titlePainter = TextPainter(
      text: TextSpan(
        text: normalizedTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 64,
          fontWeight: FontWeight.w700,
          height: 1.28,
        ),
      ),
      maxLines: 5,
      ellipsis: '...',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 144);
    titlePainter.paint(canvas, const Offset(72, 152));

    if (normalizedAuthor.isNotEmpty) {
      final authorPainter = TextPainter(
        text: TextSpan(
          text: normalizedAuthor,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 30,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
        maxLines: 2,
        ellipsis: '...',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width - 144);
      authorPainter.paint(
        canvas,
        Offset(72, height - 104 - authorPainter.height),
      );
    }

    final image = await recorder.endRecording().toImage(width, height);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('无法编码本地书籍封面');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }
}
