import 'package:flutter/material.dart';

import '../../../app/service/annotation/book_annotation.dart';
import '../../../app/l10n/generated/l10n.dart';

class BookReadAnnotationEditorSheet extends StatefulWidget {
  const BookReadAnnotationEditorSheet({
    super.key,
    required this.title,
    required this.excerpt,
    required this.initialNote,
  });

  final String title;
  final String excerpt;
  final String initialNote;

  static Future<String?> show(
    BuildContext context, {
    BookAnnotation? annotation,
    String? excerpt,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BookReadAnnotationEditorSheet(
        title:
            annotation == null ? S.of(context).addNote : S.of(context).editNote,
        excerpt: annotation?.excerpt ?? excerpt ?? '',
        initialNote: annotation?.note ?? '',
      ),
    );
  }

  @override
  State<BookReadAnnotationEditorSheet> createState() =>
      _BookReadAnnotationEditorSheetState();
}

class _BookReadAnnotationEditorSheetState
    extends State<BookReadAnnotationEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        18 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          if (widget.excerpt.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.excerpt.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: S.of(context).writeYourThoughts,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final value = _controller.text.trim();
                if (value.isNotEmpty) Navigator.of(context).pop(value);
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(S.of(context).save),
            ),
          ),
        ],
      ),
    );
  }
}
