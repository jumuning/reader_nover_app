import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import '../../database/dao/local_book_file_dao.dart';
import '../../database/drift/app_database.dart' as db;
import '../book/chapter_content_loader.dart';
import '../book/service_result.dart';
import 'local_book_constants.dart';

class LocalBookContentLoader {
  LocalBookContentLoader({
    db.AppDatabase? database,
  }) : _database = database ?? db.AppDatabase.instance;

  static const int _fileBlockBytes = 8 * 1024 * 1024;
  static _FileBlockCache? _blockCache;

  final db.AppDatabase _database;
  late final LocalBookFileDao _localBookFileDao =
      LocalBookFileDao(database: _database);

  Future<ServiceResult<String>> loadChapterContent({
    required String? chapterUrl,
  }) async {
    final reference = LocalBookConstants.parseChapterUrl(chapterUrl);
    if (reference == null) {
      return ServiceResult<String>.failure(
        const ServiceError(
          code: ServiceErrorCodes.contentChapterUrlMissing,
          userMessage: '本地章节地址无效，请重新导入',
        ),
      );
    }

    final fileRecord = await _localBookFileDao.findByBookId(reference.bookId);
    if (fileRecord == null) {
      return ServiceResult<String>.failure(
        ServiceError(
          code: ServiceErrorCodes.contentLocalCacheMissing,
          userMessage: '本地书籍文件记录缺失，请重新导入',
          context: <String, Object?>{
            'bookId': reference.bookId,
            'chapterUrl': chapterUrl,
          },
        ),
      );
    }

    try {
      final content = reference.isByteRange
          ? await _loadByteRangeChapterContent(
              filePath: fileRecord.storedFilePath,
              charset: fileRecord.charset,
              reference: reference,
            )
          : await Isolate.run(
              () => _loadLegacyChapterContentSync(
                filePath: fileRecord.storedFilePath,
                charset: fileRecord.charset,
                reference: reference,
              ),
            );
      return ServiceResult<String>.success(content);
    } catch (e, stackTrace) {
      return ServiceResult<String>.failure(
        ServiceError(
          code: ServiceErrorCodes.contentLocalCacheMissing,
          userMessage: '本地章节读取失败，请重新导入',
          debugMessage: e.toString(),
          context: <String, Object?>{
            'bookId': reference.bookId,
            'chapterIndex': reference.chapterIndex,
            'chapterUrl': chapterUrl,
            'filePath': fileRecord.storedFilePath,
          },
          cause: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  static Future<String> _loadByteRangeChapterContent({
    required String filePath,
    required String? charset,
    required LocalChapterReference reference,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const FileSystemException('local book file missing');
    }

    final fileLength = await file.length();
    final start = reference.startOffset!.clamp(0, fileLength).toInt();
    final end = reference.endOffset!.clamp(start, fileLength).toInt();
    if (start >= end) return '';

    final bytes = await _readByteRange(
      file: file,
      start: start,
      end: end,
    );
    if (bytes.isEmpty) return '';

    final text = _decodeBytes(bytes, charset);
    return ChapterContentLoader.normalizeContent(
      text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').replaceAll(
            '\u{feff}',
            '',
          ),
    );
  }

  static Future<Uint8List> _readByteRange({
    required File file,
    required int start,
    required int end,
  }) async {
    final count = end - start;
    if (count <= 0) return Uint8List(0);

    final blockStart = _fileBlockBytes * (start ~/ _fileBlockBytes);
    final block = await _ensureFileBlock(file: file, blockStart: blockStart);
    if (start >= block.start && end <= block.end) {
      return Uint8List.sublistView(
        block.bytes,
        start - block.start,
        end - block.start,
      );
    }

    return _readExactRangeAsync(file: file, start: start, end: end);
  }

  static Future<_FileBlockCache> _ensureFileBlock({
    required File file,
    required int blockStart,
  }) async {
    final cache = _blockCache;
    if (cache != null &&
        cache.filePath == file.path &&
        cache.start == blockStart) {
      return cache;
    }

    final fileLength = await file.length();
    final blockEnd = math.min(blockStart + _fileBlockBytes, fileLength);
    final bytes = await _readExactRangeAsync(
      file: file,
      start: blockStart,
      end: blockEnd,
    );
    final nextCache = _FileBlockCache(
      filePath: file.path,
      start: blockStart,
      end: blockEnd,
      bytes: bytes,
    );
    _blockCache = nextCache;
    return nextCache;
  }

  static Future<Uint8List> _readExactRangeAsync({
    required File file,
    required int start,
    required int end,
  }) async {
    final count = end - start;
    if (count <= 0) return Uint8List(0);

    final raf = await file.open(mode: FileMode.read);
    try {
      await raf.setPosition(start);
      return await raf.read(count);
    } finally {
      await raf.close();
    }
  }

  static String _loadLegacyChapterContentSync({
    required String filePath,
    required String? charset,
    required LocalChapterReference reference,
  }) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw const FileSystemException('local book file missing');
    }

    final bytes = file.readAsBytesSync();
    if (bytes.isEmpty) return '';

    final text = _decodeBytes(bytes, charset);
    final normalized = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u{feff}', '');
    if (normalized.isEmpty) return '';

    final start = reference.hasRange
        ? reference.startOffset!.clamp(0, normalized.length).toInt()
        : 0;
    final end = reference.hasRange
        ? reference.endOffset!.clamp(start, normalized.length).toInt()
        : normalized.length;
    return ChapterContentLoader.normalizeContent(
        normalized.substring(start, end));
  }

  static String _decodeBytes(List<int> bytes, String? charset) {
    final utf8Bytes = _stripUtf8Bom(bytes);
    final normalizedCharset = charset?.trim().toLowerCase();
    if (normalizedCharset == null ||
        normalizedCharset.isEmpty ||
        normalizedCharset == 'utf-8') {
      return const Utf8Decoder(allowMalformed: false).convert(utf8Bytes);
    }
    throw FormatException('unsupported charset: $charset');
  }

  static List<int> _stripUtf8Bom(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      return bytes.sublist(3);
    }
    return bytes;
  }
}

class _FileBlockCache {
  const _FileBlockCache({
    required this.filePath,
    required this.start,
    required this.end,
    required this.bytes,
  });

  final String filePath;
  final int start;
  final int end;
  final Uint8List bytes;
}
