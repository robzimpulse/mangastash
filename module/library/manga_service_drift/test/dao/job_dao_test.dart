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

    test('add skips duplicate prefetchManga job', () async {
      const job = JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchManga),
        source: Value('Asura Scans'),
        mangaId: Value('m1'),
      );

      await jobDao.add(job);
      await jobDao.add(job);

      final count = await jobDao.count.first;
      expect(count, 1);
    });

    test('add skips duplicate prefetchChapter job', () async {
      const job = JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchChapter),
        source: Value('Asura Scans'),
        mangaId: Value('m1'),
        chapterId: Value('c1'),
      );

      await jobDao.add(job);
      await jobDao.add(job);

      final count = await jobDao.count.first;
      expect(count, 1);
    });

    test('add skips duplicate prefetchImage job', () async {
      const job = JobTablesCompanion(
        type: Value(JobTypeEnum.prefetchImage),
        mangaId: Value('m1'),
        chapterId: Value('c1'),
        imageUrl: Value('https://example.com/page-1.png'),
      );

      await jobDao.add(job);
      await jobDao.add(job);

      final count = await jobDao.count.first;
      expect(count, 1);
    });

    test('add keeps jobs with different imageUrl', () async {
      Future<void> enqueue(String url) => jobDao.add(
        JobTablesCompanion(
          type: const Value(JobTypeEnum.prefetchImage),
          mangaId: const Value('m1'),
          chapterId: const Value('c1'),
          imageUrl: Value(url),
        ),
      );

      await enqueue('https://example.com/page-1.png');
      await enqueue('https://example.com/page-2.png');

      final count = await jobDao.count.first;
      expect(count, 2);
    });

    test('add keeps same manga with different type', () async {
      await jobDao.add(
        const JobTablesCompanion(
          type: Value(JobTypeEnum.prefetchManga),
          source: Value('Asura Scans'),
          mangaId: Value('m1'),
        ),
      );
      await jobDao.add(
        const JobTablesCompanion(
          type: Value(JobTypeEnum.prefetchChapters),
          source: Value('m1'),
          mangaId: Value('m1'),
        ),
      );

      final count = await jobDao.count.first;
      expect(count, 2);
    });

    test('add treats absent and explicit-null fields as equal', () async {
      await jobDao.add(
        const JobTablesCompanion(
          type: Value(JobTypeEnum.prefetchManga),
          mangaId: Value('m1'),
        ),
      );
      await jobDao.add(
        const JobTablesCompanion(
          type: Value(JobTypeEnum.prefetchManga),
          mangaId: Value('m1'),
          source: Value(null),
        ),
      );

      final count = await jobDao.count.first;
      expect(count, 1);
    });
  });
}
