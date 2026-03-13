import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';

void main() {
  late AppDatabase db;
  late JobDao jobDao;
  late MangaDao mangaDao;
  late ChapterDao chapterDao;

  final manga = MangaTablesCompanion(
    id: const Value('m1'),
    title: const Value('Manga 1'),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  );

  final chapter = ChapterTablesCompanion(
    id: const Value('c1'),
    mangaId: const Value('m1'),
    chapter: const Value('1'),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  );

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    jobDao = JobDao(db);
    mangaDao = MangaDao(db);
    chapterDao = ChapterDao(db);
  });

  tearDown(() => db.close());

  group('Job Dao Test', () {
    tearDown(() => db.clear());

    setUp(() async {
      await mangaDao.adds(values: {manga: []});
      await chapterDao.adds(values: {chapter: []});
    });

    test('add and stream', () async {
      await jobDao.add(const JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchChapter),
        mangaId: Value('m1'),
        chapterId: Value('c1'),
      ));

      final result = await jobDao.stream.first;
      expect(result.isNotEmpty, isTrue);
      expect(result.first.type, JobTypeEnum.prefetchChapter);
      expect(result.first.manga?.id, 'm1');
      expect(result.first.chapter?.id, 'c1');
    });

    test('streamMangaIds', () async {
      await jobDao.add(const JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchManga),
        mangaId: Value('m1'),
      ));

      await jobDao.add(const JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchChapter),
        chapterId: Value('c1'),
      ));

      final result = await jobDao.streamMangaIds.first;
      expect(result.length, 1);
      expect(result.first.type, JobTypeEnum.prefetchManga);
      expect(result.first.manga?.id, 'm1');
    });

    test('streamChapterIds', () async {
      await jobDao.add(const JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchChapter),
        chapterId: Value('c1'),
      ));

      final result = await jobDao.streamChapterIds.first;
      expect(result.length, 1);
      expect(result.first.chapter?.id, 'c1');
    });

    test('single', () async {
      await jobDao.add(const JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchManga),
        mangaId: Value('m1'),
      ));
      await jobDao.add(const JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchChapter),
        chapterId: Value('c1'),
      ));

      final result = await jobDao.single.first;
      expect(result != null, isTrue);
    });

    test('count', () async {
      await jobDao.add(const JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchManga),
        mangaId: Value('m1'),
      ));
      
      final count = await jobDao.count.first;
      expect(count, 1);
    });

    test('remove', () async {
      await jobDao.add(const JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchManga),
        mangaId: Value('m1'),
      ));

      final all = await jobDao.stream.first;
      expect(all.length, 1);
      
      await jobDao.remove(all.first.id);
      
      final count = await jobDao.count.first;
      expect(count, 0);
    });
  });
}
