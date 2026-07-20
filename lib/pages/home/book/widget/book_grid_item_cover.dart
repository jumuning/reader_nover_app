import 'package:flutter/material.dart';

import '../../../../app/constants/assets.dart';
import '../../../../app/database/drift/app_database.dart' as db;
import '../../../../pages/common/decoded_network_image.dart';

class BookGridItemCover extends StatelessWidget {
  const BookGridItemCover({
    super.key,
    required this.coverUrl,
    this.bookSourceId,
    this.source,
  });

  final String? coverUrl;
  final int? bookSourceId;
  final db.BookSource? source;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final url = coverUrl ?? Assets.defaultBook;
        final error = Image.asset(
          Assets.defaultBook,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        );
        final placeholder = Container(color: Colors.grey[200]);

        Widget image;
        if (source != null) {
          image = DecodedCoverImage(
            imageUrl: url,
            source: source,
            fit: BoxFit.cover,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            placeholder: placeholder,
            errorWidget: error,
          );
        } else {
          image = DecodedCoverImage(
            imageUrl: url,
            source: null,
            fit: BoxFit.cover,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            placeholder: placeholder,
            errorWidget: error,
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox.expand(child: image),
          ),
        );
      },
    );
  }
}
