import 'dart:typed_data';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/service/source/source_image_decoder.dart';

/// 优先走 `coverDecodeJs` 解密；失败则回退普通网络图。
class DecodedCoverImage extends StatefulWidget {
  const DecodedCoverImage({
    super.key,
    required this.imageUrl,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final db.BookSource? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  State<DecodedCoverImage> createState() => _DecodedCoverImageState();
}

class _DecodedCoverImageState extends State<DecodedCoverImage> {
  Future<Uint8List?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant DecodedCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.source?.id != widget.source?.id ||
        oldWidget.source?.coverDecodeJs != widget.source?.coverDecodeJs) {
      _future = _load();
    }
  }

  Future<Uint8List?> _load() async {
    final source = widget.source;
    final url = widget.imageUrl.trim();
    if (source == null ||
        url.isEmpty ||
        (source.coverDecodeJs?.trim().isEmpty ?? true)) {
      return null;
    }
    return SourceImageDecoder.loadCoverBytes(
      source: source,
      imageUrl: url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.imageUrl.trim();
    final placeholder = widget.placeholder ??
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
    final error = widget.errorWidget ??
        SizedBox(width: widget.width, height: widget.height);

    if (url.isEmpty) return error;
    final uri = Uri.tryParse(url);
    if (uri?.scheme == 'file') {
      return Image.file(
        File.fromUri(uri!),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (_, __, ___) => error,
      );
    }

    final source = widget.source;
    if (source == null || (source.coverDecodeJs?.trim().isEmpty ?? true)) {
      return CachedNetworkImage(
        imageUrl: url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => error,
      );
    }

    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return placeholder;
        }
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return CachedNetworkImage(
            imageUrl: url,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholder: (_, __) => placeholder,
            errorWidget: (_, __, ___) => error,
          );
        }
        return Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (_, __, ___) => error,
        );
      },
    );
  }
}
