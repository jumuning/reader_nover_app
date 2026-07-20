import 'package:flutter/material.dart';

import '../models/reader_paragraph_range.dart';
import 'reader_paragraph_utils.dart';

class ReaderTextHitTest {
  const ReaderTextHitTest._();

  static ReaderParagraphRange? resolveParagraphAtPosition({
    required Offset localPosition,
    required double maxWidth,
    required String content,
    required TextStyle baseStyle,
    required TextScaler textScaler,
    List<InlineSpan> leadingSpans = const <InlineSpan>[],
    TextAlign textAlign = TextAlign.left,
    StrutStyle? strutStyle,
  }) {
    if (content.isEmpty || maxWidth <= 0) return null;

    final painter = TextPainter(
      text: TextSpan(
        children: <InlineSpan>[
          ...leadingSpans,
          TextSpan(text: content, style: baseStyle),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
      textScaler: textScaler,
      strutStyle: strutStyle,
    )..layout(maxWidth: maxWidth);

    if (localPosition.dx < 0 || localPosition.dx > maxWidth) {
      return null;
    }
    if (localPosition.dy < 0 || localPosition.dy > painter.height) {
      return null;
    }

    final textPosition = painter.getPositionForOffset(localPosition);
    final leadingLength = TextSpan(children: leadingSpans).toPlainText().length;
    final rawContentOffset = textPosition.offset - leadingLength;
    if (rawContentOffset >= content.length) {
      return ReaderParagraphUtils.resolveAt(content, content.length - 1);
    }
    if (rawContentOffset < 0) {
      return null;
    }

    return ReaderParagraphUtils.resolveAt(content, rawContentOffset);
  }
}
