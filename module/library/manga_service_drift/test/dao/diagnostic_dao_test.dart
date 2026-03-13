import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';

void main() {
  late AppDatabase db;
  late DiagnosticDao dao;
  late LibraryDao libraryDao;

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    dao = DiagnosticDao(db);
    libraryDao = LibraryDao(db);
  });

  tearDown(() => db.close());

  group('Diagnostic Dao Test', () {
    tearDown(() => db.clear());

    test('duplicateManga', () async {
      final manga1 = MangaTablesCompanion(
        id: const Value('m1'),
        title: const Value('Dup'),
        source: const Value('src1'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      final manga2 = MangaTablesCompanion(
        id: const Value('m2'),
        title: const Value('Dup'),
        source: const Value('src1'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      
      await db.into(db.mangaTables).insert(manga1);
      await db.into(db.mangaTables).insert(manga2);

      final result1 = await dao.duplicateMangaStream.first;
      expect(result1.isNotEmpty, isTrue);
      
      final result2 = await dao.duplicateManga;
      expect(result2.isNotEmpty, isTrue);
    });

    test('duplicateChapter', () async {
      final manga = MangaTablesCompanion(
        id: const Value('m1'),
        title: const Value('Test'),
        source: const Value('src'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await db.into(db.mangaTables).insert(manga);

      final c1 = ChapterTablesCompanion(
        id: const Value('c1'),
        mangaId: const Value('m1'),
        chapter: const Value('1'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      final c2 = ChapterTablesCompanion(
        id: const Value('c2'),
        mangaId: const Value('m1'),
        chapter: const Value('1'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await db.into(db.chapterTables).insert(c1);
      await db.into(db.chapterTables).insert(c2);

      final result1 = await dao.duplicateChapterStream.first;
      expect(result1.isNotEmpty, isTrue);
      
      final result2 = await dao.duplicateChapter;
      expect(result2.isNotEmpty, isTrue);
    });

    test('duplicateTag', () async {
      final t1 = TagTablesCompanion(
        id: const Value(1),
        tagId: const Value('dup_tag_1'),
        name: const Value('Name'),
        source: const Value('src'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      final t2 = TagTablesCompanion(
        id: const Value(2),
        tagId: const Value('dup_tag_2'),
        name: const Value('Name'),
        source: const Value('src'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await db.into(db.tagTables).insert(t1);
      await db.into(db.tagTables).insert(t2);

      final result1 = await dao.duplicateTagStream.first;
      expect(result1.isNotEmpty, isTrue);
      
      final result2 = await dao.duplicateTag;
      expect(result2.isNotEmpty, isTrue);
    });

    test('orphanChapter', () async {
      final c1 = ChapterTablesCompanion(
        id: const Value('c1'),
        mangaId: const Value('m1_missing'),
        chapter: const Value('1'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await db.into(db.chapterTables).insert(c1);

      final result1 = await dao.orphanChapterStream.first;
      expect(result1.length, 1);
      
      final result2 = await dao.orphanChapter;
      expect(result2.length, 1);
    });

    test('orphanImage', () async {
      final i1 = ImageTablesCompanion(
        id: const Value('i1'),
        chapterId: const Value('c1_missing'),
        webUrl: const Value('url'),
        order: const Value(1),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await db.into(db.imageTables).insert(i1);

      final result1 = await dao.orphanImageStream.first;
      expect(result1.length, 1);
      
      final result2 = await dao.orphanImage;
      expect(result2.length, 1);
    });

    test('chapterGap', () async {
      final m1 = MangaTablesCompanion(
        id: const Value('m1'),
        title: const Value('Title'),
        source: const Value('src'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await db.into(db.mangaTables).insert(m1);
      await libraryDao.add('m1'); // Must be in library

      final c1 = ChapterTablesCompanion(
        id: const Value('c1'),
        mangaId: const Value('m1'),
        chapter: const Value('1'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      // Gap! Next is 3
      final c3 = ChapterTablesCompanion(
        id: const Value('c3'),
        mangaId: const Value('m1'),
        chapter: const Value('3'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await db.into(db.chapterTables).insert(c1);
      await db.into(db.chapterTables).insert(c3);

      final result1 = await dao.chapterGapStream.first;
      expect(result1.isNotEmpty, isTrue);
      
      final result2 = await dao.chapterGap;
      expect(result2.isNotEmpty, isTrue);
    });
  });
}
