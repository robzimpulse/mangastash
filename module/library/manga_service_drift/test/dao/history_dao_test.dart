import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';

void main() {
  late AppDatabase db;
  late HistoryDao historyDao;
  late MangaDao mangaDao;
  late ChapterDao chapterDao;
  late LibraryDao libraryDao;

  final manga1 = MangaTablesCompanion(
    id: const Value('m1'),
    title: const Value('Manga 1'),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  );
  
  final manga2 = MangaTablesCompanion(
    id: const Value('m2'),
    title: const Value('Manga 2'),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  );

  final chapterRead = ChapterTablesCompanion(
    id: const Value('c_read'),
    mangaId: const Value('m1'),
    chapter: const Value('1'),
    lastReadAt: Value(DateTime.now()),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  );

  final chapterUnreadLibrary = ChapterTablesCompanion(
    id: const Value('c_unread_lib'),
    mangaId: const Value('m2'),
    chapter: const Value('1'),
    readableAt: Value(DateTime.now()),
    lastReadAt: const Value.absent(),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  );
  
  final chapterUnreadOld = ChapterTablesCompanion(
    id: const Value('c_unread_old'),
    mangaId: const Value('m2'),
    chapter: const Value('2'),
    readableAt: Value(DateTime.now().subtract(const Duration(days: 8))),
    lastReadAt: const Value.absent(),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  );

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    historyDao = HistoryDao(db);
    mangaDao = MangaDao(db);
    chapterDao = ChapterDao(db);
    libraryDao = LibraryDao(db);
  });

  tearDown(() => db.close());

  group('History Dao Test', () {
    tearDown(() => db.clear());

    setUp(() async {
      await mangaDao.adds(values: {manga1: [], manga2: []});
      await chapterDao.adds(values: {chapterRead: [], chapterUnreadLibrary: [], chapterUnreadOld: []});
      await libraryDao.add('m2'); // manga2 is in library
    });

    test('history stream', () async {
      final result = await historyDao.history.first;
      expect(result.isNotEmpty, isTrue);
      // c_read has lastReadAt
      expect(result.first.chapter?.id, 'c_read');
    });

    test('unread stream', () async {
      final result = await historyDao.unread.first;
      expect(result.isNotEmpty, isTrue);
      // c_unread_lib is unread, in library, and within 7 days
      expect(result.length, 1);
      expect(result.first.chapter?.id, 'c_unread_lib');
    });
  });
}
