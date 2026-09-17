import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
  });

  tearDown(() => db.close());

  group('AppDatabase clear (#102)', () {
    test('empties every table', () async {
      await db.mangaDao.adds(values: {
        const MangaTablesCompanion(
          id: Value('manga_1'),
          title: Value('title_1'),
        ): ['tag_1'],
      });
      await db.chapterDao.adds(values: {
        const ChapterTablesCompanion(
          id: Value('chapter_1'),
          mangaId: Value('manga_1'),
          title: Value('chapter_title_1'),
        ): ['image_url_1'],
      });
      await db.libraryDao.add('manga_1');
      await db.jobDao.add(
        JobTablesCompanion.insert(type: JobTypeEnum.prefetchManga),
      );

      await db.clear();

      expect(await db.mangaDao.all, isEmpty);
      expect(await db.chapterDao.all, isEmpty);
      expect(await db.imageDao.all, isEmpty);
      expect(await db.tagDao.all, isEmpty);
      expect(await db.select(db.fileTables).get(), isEmpty);
      expect(
        await db.libraryDao.stream.first,
        isEmpty,
      );
      expect(await db.jobDao.stream.first, isEmpty);
      expect(
        await db.select(db.relationshipTables).get(),
        isEmpty,
      );
    });

    test('clear is safe to call repeatedly', () async {
      await db.mangaDao.adds(values: {
        const MangaTablesCompanion(
          id: Value('manga_1'),
          title: Value('title_1'),
        ): ['tag_1'],
      });

      await db.clear();
      await db.clear();

      expect(await db.mangaDao.all, isEmpty);
    });
  });
}
