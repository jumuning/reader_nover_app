import 'book_annotation.dart';

class ReaderAnnotationRange {
  const ReaderAnnotationRange({
    required this.start,
    required this.end,
    required this.type,
    this.colorValue,
  });

  final int start;
  final int end;
  final BookAnnotationType type;
  final int? colorValue;
}
