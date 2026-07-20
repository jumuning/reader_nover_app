import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../database/dao/local_book_file_dao.dart';
import '../../database/drift/app_database.dart' as db;
import 'models/local_book_storage_repair_report.dart';
import 'local_book_cover_service.dart';

class LocalBookStorageRepairService {
  LocalBookStorageRepairService({
    db.AppDatabase? database,
    Future<Directory> Function()? managedDirectoryProvider,
    LocalBookCoverService? coverService,
  })  : _database = database ?? db.AppDatabase.instance,
        _managedDirectoryProvider = managedDirectoryProvider ??
            (() async => Directory(p.join(
                  (await getApplicationSupportDirectory()).path,
                  'local_books',
                ))),
        _coverService = coverService ?? const LocalBookCoverService();

  final db.AppDatabase _database;
  final Future<Directory> Function() _managedDirectoryProvider;
  final LocalBookCoverService _coverService;
  late final LocalBookFileDao _fileDao = LocalBookFileDao(database: _database);

  Future<LocalBookStorageRepairReport> inspectAndRepair({
    bool repair = false,
  }) async {
    final root = await _managedDirectoryProvider();
    final rootPath = p.normalize(p.absolute(root.path));
    final records = await _fileDao.listAll();
    final books = await _database.select(_database.books).get();
    final booksById = {for (final book in books) book.id: book};
    final referencedPaths = <String>{};
    final issues = <LocalBookStorageIssue>[];
    final deletedPaths = <String>[];
    var reclaimedBytes = 0;

    for (final record in records) {
      final storedPath = p.normalize(p.absolute(record.storedFilePath));
      referencedPaths.add(storedPath);
      final book = booksById[record.bookId];
      if (!_isWithin(rootPath, storedPath)) {
        issues.add(LocalBookStorageIssue(
          type: LocalBookStorageIssueType.pathOutsideManagedDirectory,
          path: storedPath,
          bookId: record.bookId,
        ));
        continue;
      }

      if (book != null) {
        final coverUri = Uri.tryParse(book.cover?.trim() ?? '');
        final configuredCoverPath = coverUri?.scheme == 'file'
            ? p.normalize(p.absolute(File.fromUri(coverUri!).path))
            : null;
        final coverPath = configuredCoverPath ??
            p.normalize(p.absolute(p.join(
              File(storedPath).parent.path,
              LocalBookCoverService.fileName,
            )));
        if (_isWithin(rootPath, coverPath)) {
          referencedPaths.add(coverPath);
          if (!await File(coverPath).exists()) {
            issues.add(LocalBookStorageIssue(
              type: LocalBookStorageIssueType.missingCover,
              path: coverPath,
              bookId: record.bookId,
            ));
            if (repair) {
              final generatedUri = await _coverService.ensureGeneratedCover(
                bookDirectory: File(storedPath).parent,
                title: book.name,
                author: book.author,
              );
              await (_database.update(_database.books)
                    ..where((table) => table.id.equals(book.id)))
                  .write(
                db.BooksCompanion(cover: drift.Value(generatedUri)),
              );
              referencedPaths.add(
                p.normalize(
                    p.absolute(File.fromUri(Uri.parse(generatedUri)).path)),
              );
            }
          }
        }
      }

      final file = File(storedPath);
      if (!await file.exists()) {
        issues.add(LocalBookStorageIssue(
          type: LocalBookStorageIssueType.missingStoredFile,
          path: storedPath,
          bookId: record.bookId,
        ));
        continue;
      }
      final actualSize = await file.length();
      if (actualSize != record.fileSize) {
        issues.add(LocalBookStorageIssue(
          type: LocalBookStorageIssueType.fileSizeMismatch,
          path: storedPath,
          bookId: record.bookId,
          detail: 'expected=${record.fileSize}, actual=$actualSize',
        ));
      }
    }

    if (await root.exists()) {
      final entities =
          await root.list(recursive: true, followLinks: false).toList();
      for (final entity in entities.whereType<File>()) {
        final path = p.normalize(p.absolute(entity.path));
        if (referencedPaths.contains(path) ||
            !_isSafelyRebuildable(rootPath, path)) {
          continue;
        }
        issues.add(LocalBookStorageIssue(
          type: LocalBookStorageIssueType.orphanedManagedEntry,
          path: path,
        ));
        if (repair) {
          final size = await entity.length();
          await entity.delete();
          reclaimedBytes += size;
          deletedPaths.add(path);
        }
      }
      if (repair) {
        final directories = entities.whereType<Directory>().toList()
          ..sort((a, b) => b.path.length.compareTo(a.path.length));
        for (final directory in directories) {
          if (await directory.exists() && await directory.list().isEmpty) {
            await directory.delete();
            deletedPaths.add(p.normalize(p.absolute(directory.path)));
          }
        }
      }
    }

    return LocalBookStorageRepairReport(
      issues: List.unmodifiable(issues),
      deletedPaths: List.unmodifiable(deletedPaths),
      reclaimedBytes: reclaimedBytes,
    );
  }

  bool _isWithin(String rootPath, String candidatePath) {
    return candidatePath == rootPath || p.isWithin(rootPath, candidatePath);
  }

  bool _isSafelyRebuildable(String rootPath, String path) {
    if (!_isWithin(rootPath, path)) return false;
    final extension = p.extension(path).toLowerCase();
    if (extension == '.tmp' || extension == '.part') return true;
    if (p.basename(path) == LocalBookCoverService.fileName) return true;
    final relativeSegments = p.split(p.relative(path, from: rootPath));
    return relativeSegments.isNotEmpty && relativeSegments.first == 'cache';
  }
}
