import '../../database/dao/bookshelf_dao.dart';
import '../../database/dao/local_book_file_dao.dart';
import '../../database/drift/app_database.dart' as db;
import '../../database/models/models.dart';
import 'local_book_constants.dart';
import 'local_book_repository.dart';
import 'local_text_book_parser.dart';

class LocalBookChapterService {
  LocalBookChapterService({
    db.AppDatabase? database,
    LocalTextBookParser? parser,
  })  : _database = database ?? db.AppDatabase.instance,
        _parser = parser ?? LocalTextBookParser();

  final db.AppDatabase _database;
  final LocalTextBookParser _parser;
  late final BookshelfDao _bookshelfDao = BookshelfDao(database: _database);
  late final LocalBookFileDao _localBookFileDao =
      LocalBookFileDao(database: _database);
  late final LocalBookRepository _repository =
      LocalBookRepository(database: _database);

  Future<BookDetail> ensureChapters(BookDetail bookDetail) async {
    if (!LocalBookConstants.isLocalBookSource(bookDetail.bookSourceId)) {
      return bookDetail;
    }
    if (bookDetail.chapters?.isNotEmpty == true) {
      return bookDetail;
    }

    final bookName = bookDetail.name?.trim();
    if (bookName == null || bookName.isEmpty) {
      return bookDetail;
    }

    final book = await _bookshelfDao.findBook(
      bookSourceId: bookDetail.bookSourceId,
      bookName: bookName,
    );
    if (book == null) {
      return bookDetail;
    }

    final existingChapters = await _bookshelfDao.listChaptersByBookId(book.id);
    if (existingChapters.isNotEmpty) {
      return bookDetail.copyWith(
        chapters: existingChapters
            .map(
              (chapter) => BookChapterInfo(
                bookSourceId: chapter.bookSourceId,
                chapterIndex: chapter.chapterIndex,
                chapterName: chapter.chapterName,
                chapterUrl: chapter.chapterUrl,
              ),
            )
            .toList(growable: false),
      );
    }

    final localFile = await _localBookFileDao.findByBookId(book.id);
    if (localFile == null) {
      return bookDetail;
    }

    final parsedBook = await _parser.parseFile(
      filePath: localFile.storedFilePath,
      fallbackTitle: book.name,
    );
    return _repository.saveParsedChaptersForBook(
      book: book,
      parsedBook: parsedBook,
    );
  }
}
