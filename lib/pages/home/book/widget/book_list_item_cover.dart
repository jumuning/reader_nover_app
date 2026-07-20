import 'package:flutter/material.dart';

import '../../../../app/constants/assets.dart';
import '../../../../app/database/drift/app_database.dart' as db;
import '../../../../pages/common/decoded_network_image.dart';

class BookListItemCover extends StatelessWidget {
  const BookListItemCover({
    super.key,
    required this.coverUrl,
    required this.width,
    required this.height,
    this.bookSourceId,
    this.source,
  });

  final String? coverUrl;
  final double width;
  final double height;
  final int? bookSourceId;
  final db.BookSource? source;

  @override
  Widget build(BuildContext context) {
    const double spineWidth = 12;
    const double shadowOffset = 8;

    return SizedBox(
      width: width + spineWidth + shadowOffset,
      height: height + shadowOffset,
      child: Stack(
        children: [
          Positioned(
            left: spineWidth + 4,
            top: 6,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: spineWidth + width - 3,
            top: 3,
            child: Container(
              width: 6,
              height: height - 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[300]!,
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: spineWidth,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.brown[700]!,
                    Colors.brown[500]!,
                    Colors.brown[600]!,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  bottomLeft: Radius.circular(2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(1, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 2,
                    margin: const EdgeInsets.only(top: 8),
                    color: Colors.brown[800]!.withValues(alpha: 0.5),
                  ),
                  Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.brown[800]!.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: spineWidth,
            top: 0,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
                child: Stack(
                  children: [
                    _CoverImage(
                      coverUrl: coverUrl,
                      width: width,
                      height: height,
                      bookSourceId: bookSourceId,
                      source: source,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.05),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.coverUrl,
    required this.width,
    required this.height,
    this.bookSourceId,
    this.source,
  });

  final String? coverUrl;
  final double width;
  final double height;
  final int? bookSourceId;
  final db.BookSource? source;

  @override
  Widget build(BuildContext context) {
    final url = coverUrl ?? Assets.defaultBook;
    final error = Image.asset(
      Assets.defaultBook,
      width: width,
      height: height,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
    );
    final placeholder = Container(
      width: width,
      height: height,
      color: Colors.grey[200],
    );

    if (source != null) {
      return DecodedCoverImage(
        imageUrl: url,
        source: source,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: placeholder,
        errorWidget: error,
      );
    }

    return DecodedCoverImage(
      imageUrl: url,
      source: null,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: placeholder,
      errorWidget: error,
    );
  }
}
