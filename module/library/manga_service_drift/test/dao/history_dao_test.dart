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

    // Issue #131: `unread` froze its 7-day boundary at stream creation, so
    // on a long-lived stream chapters older than 7 days never dropped out.
    // The window must recompute from the (advancing) clock on refresh ticks.
    test('unread stream advances its 7-day window as time passes (#131)', () async {
      var now = DateTime.now();
      final dao = HistoryDao(
        db,
        clock: () => now,
        refreshInterval: const Duration(milliseconds: 100),
      );

      final emissions = <List<HistoryModel>>[];
      final subscription = dao.unread.listen(emissions.add);
      // Wait for the first (immediate) emission plus a refresh tick.
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(emissions, isNotEmpty);
      // c_unread_lib is readable "now" — inside the fresh window.
      expect(
        emissions.first.where((e) => e.chapter?.id == 'c_unread_lib'),
        isNotEmpty,
      );

      // 8 days later the chapter is outside the window; the next refresh
      // tick must rebuild the query with the moved boundary and drop it.
      now = now.add(const Duration(days: 8));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await subscription.cancel();

      expect(
        emissions.last.where((e) => e.chapter?.id == 'c_unread_lib'),
        isEmpty,
      );
    });
  });
}
