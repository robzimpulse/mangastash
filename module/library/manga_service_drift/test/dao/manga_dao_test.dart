import 'dart:convert';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  MockPathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late MangaDao dao;
  late TagDao tagDao;
  late ChapterDao chapterDao;
  late ImageDao imageDao;
  late LibraryDao libraryDao;
  late FileDao fileDao;
  late Directory supportDir;

  final mangas = List.generate(
    10,
    (mangaIdx) => (
      MangaTablesCompanion(
        id: Value('manga_$mangaIdx'),
        title: Value('title_$mangaIdx'),
        coverUrl: Value('cover_url_$mangaIdx'),
        status: Value('status_$mangaIdx'),
        author: Value('value_$mangaIdx'),
        description: Value('description_$mangaIdx'),
        webUrl: Value('web_url_$mangaIdx'),
        source: Value('source_$mangaIdx'),
      ),
      List.generate(10, (index) => 'name_$index'),
    ),
  );

  setUp(() async {
    supportDir = await const LocalFileSystem().systemTempDirectory
        .createTemp('manga_dao_test');
    PathProviderPlatform.instance = MockPathProviderPlatform(supportDir.path);
    db = AppDatabase(executor: MemoryExecutor());
    dao = MangaDao(db);
    tagDao = TagDao(db);
    chapterDao = ChapterDao(db);
    imageDao = ImageDao(db);
    libraryDao = LibraryDao(db);
    fileDao = FileDao(db);
    await (await db.databaseDirectory()).create(recursive: true);
  });

  tearDown(() => db.close());

  test('Create Delete Mangas', () async {
    final results = await dao.adds(
      values: {for (final (manga, tags) in mangas) manga: tags},
    );
    expect((await dao.all).length, equals(results.length));

    await dao.remove(ids: results.map((e) => e.manga?.id).nonNulls.toList());
    expect((await dao.all).length, equals(0));
  });

  test('Remove cascades children (#102)', () async {
    final (manga, tags) = mangas.first;
    const otherMangaId = 'manga_other';

    await dao.adds(values: {manga: tags});
    await dao.adds(values: {
      mangas[1].$1.copyWith(id: const Value(otherMangaId)): [],
    });

    final chapter = ChapterTablesCompanion(
      id: const Value('chapter_1'),
      mangaId: Value(manga.id.value),
      title: const Value('chapter_title'),
      webUrl: const Value('chapter_web_url'),
    );

    final otherChapter = ChapterTablesCompanion(
      id: const Value('chapter_other'),
      mangaId: const Value(otherMangaId),
      title: const Value('chapter_title_other'),
      webUrl: const Value('chapter_web_url_other'),
    );

    await chapterDao.adds(values: {chapter: ['image_url_a', 'image_url_b']});
    await chapterDao.adds(values: {otherChapter: ['image_url_other']});

    await libraryDao.add(manga.id.value);
    await libraryDao.add(otherMangaId);

    final source = await supportDir.createTemp('src');
    await fileDao.addFromFile(
      webUrl: 'image_url_a',
      file: source.childFile('a.bin')..writeAsBytes(utf8.encode('a')),
    );
    await fileDao.addFromFile(
      webUrl: 'image_url_other',
      file: source.childFile('other.bin')..writeAsBytes(utf8.encode('other')),
    );

    await dao.remove(ids: [manga.id.value]);

    expect(
      (await dao.all).map((e) => e.manga?.id),
      equals([otherMangaId]),
    );
    expect(
      (await chapterDao.all).map((e) => e.chapter?.id),
      equals(['chapter_other']),
    );
    expect(
      (await imageDao.all).map((e) => e.chapterId),
      equals(['chapter_other']),
    );
    expect(
      (await db.select(db.fileTables).get()).map((e) => e.webUrl),
      equals(['image_url_other']),
    );

    final libraryMangaIds = await libraryDao.stream.first;
    expect(libraryMangaIds.map((e) => e.manga?.id), equals([otherMangaId]));
    expect(
      (await db.select(db.libraryTables).get()).map((e) => e.mangaId),
      equals([otherMangaId]),
    );
  });

  group('Manga Dao Test', () {
    setUp(() async {
      await dao.adds(values: {for (final (manga, tags) in mangas) manga: tags});
    });

    group('Specific Cases', () {
      test('Add tags to existing manga', () async {
        final (manga, tags) = ([...mangas]..shuffle()).first;
        const newTag = 'tag_name_new';
        final newTags = [...tags, newTag];

        await dao.adds(values: {manga: newTags});

        expect((await dao.search(ids: [manga.id.value])).length, equals(1));
        expect(
          (await dao.search(titles: [manga.title.value!])).length,
          equals(1),
        );
        expect(
          (await dao.search(coverUrls: [manga.coverUrl.value!])).length,
          equals(1),
        );
        expect(
          (await dao.search(statuses: [manga.status.value!])).length,
          equals(1),
        );
        expect(
          (await dao.search(webUrls: [manga.webUrl.value!])).length,
          equals(1),
        );
        expect(
          (await dao.search(authors: [manga.author.value!])).length,
          equals(1),
        );
        expect(
          (await dao.search(descriptions: [manga.description.value!])).length,
          equals(1),
        );
        expect((await dao.search(tags: [newTag])).length, equals(1));
      });

      test('Update existing manga', () async {
        final (manga, tags) = ([...mangas]..shuffle()).first;
        final updatedManga = manga.copyWith(title: Value('${manga.title.value}_updated'));

        await dao.adds(values: {updatedManga: tags});

        final result = await dao.search(ids: [manga.id.value]);
        expect(result.first.manga?.title, equals('${manga.title.value}_updated'));
      });

      test('Upserting an existing manga keeps its children (#137)', () async {
        final (manga, tags) = mangas.first;
        final mangaId = manga.id.value;

        final chapter = ChapterTablesCompanion(
          id: const Value('chapter_upsert'),
          mangaId: Value(mangaId),
          title: const Value('chapter_title'),
          webUrl: const Value('chapter_web_url'),
        );
        await chapterDao.adds(values: {
          chapter: ['image_url_upsert_a', 'image_url_upsert_b'],
        });
        await libraryDao.add(mangaId);

        // Any non-timestamp field change makes shouldUpdate true, which
        // used to run INSERT OR REPLACE — with FK cascades ON that deleted
        // and re-inserted the row, cascading away every child.
        final updated = manga.copyWith(
          status: const Value('status_updated'),
        );
        await dao.adds(values: {updated: tags});

        final stored = await dao.search(ids: [mangaId]);
        expect(stored.first.manga?.status, equals('status_updated'));

        final chapters = await chapterDao.search(mangaIds: [mangaId]);
        expect(chapters.map((e) => e.chapter?.id), equals(['chapter_upsert']));
        expect(chapters.first.images, hasLength(2));

        expect(
          (await db.select(db.libraryTables).get()).map((e) => e.mangaId),
          equals([mangaId]),
        );
        expect(
          (await tagDao.search(names: [...tags])).map((e) => e.name),
          containsAll(tags),
        );
      });
    });

    group('With New Value', () {
      final (manga, tags) = (
        const MangaTablesCompanion(
          id: Value('manga_new'),
          title: Value('title_new'),
          coverUrl: Value('cover_url_new'),
          status: Value('status_new'),
          author: Value('value_new'),
          description: Value('description_new'),
          webUrl: Value('web_url_new'),
          source: Value('source_new'),
        ),
        List.generate(10, (index) => 'name_new_$index'),
      );

      test('Add Value', () async {
        await dao.adds(values: {manga: tags});
        expect((await dao.all).length, equals(mangas.length + 1));
        expect((await tagDao.all).length, equals((mangas.length + 1) * 10));
      });

      group('Search Value', () {
        test('By Id', () async {
          expect((await dao.search(ids: [manga.id.value])).length, equals(0));
        });
        test('By Title', () async {
          expect(
            (await dao.search(titles: [manga.title.value!])).length,
            equals(0),
          );
        });
        test('By Cover Url', () async {
          expect(
            (await dao.search(coverUrls: [manga.coverUrl.value!])).length,
            equals(0),
          );
        });
        test('By Status', () async {
          expect(
            (await dao.search(statuses: [manga.status.value!])).length,
            equals(0),
          );
        });
        test('By Author', () async {
          final result = await dao.search(authors: [manga.author.value!]);
          expect(result.length, equals(0));
        });
        test('By Web Url', () async {
          final result = await dao.search(webUrls: [manga.webUrl.value!]);
          expect(result.length, equals(0));
        });
        test('By Description', () async {
          expect(
            (await dao.search(descriptions: [manga.description.value!])).length,
            equals(0),
          );
        });
      });
    });

    group('With Old Value', () {
      final (manga, tags) = ([...mangas]..shuffle()).first;

      test('Add Value', () async {
        await dao.adds(values: {manga: tags});
        expect((await dao.all).length, equals(mangas.length));
        expect((await tagDao.all).length, equals(mangas.length * 10));
      });

      group('Search Value', () {
        test('By Id', () async {
          expect((await dao.search(ids: [manga.id.value])).length, equals(1));
        });
        test('By Title', () async {
          expect(
            (await dao.search(titles: [manga.title.value!])).length,
            equals(1),
          );
        });
        test('By Cover Url', () async {
          expect(
            (await dao.search(coverUrls: [manga.coverUrl.value!])).length,
            equals(1),
          );
        });
        test('By Status', () async {
          expect(
            (await dao.search(statuses: [manga.status.value!])).length,
            equals(1),
          );
        });
        test('By Author', () async {
          final result = await dao.search(authors: [manga.author.value!]);
          expect(result.length, equals(1));
        });
        test('By Web Url', () async {
          final result = await dao.search(webUrls: [manga.webUrl.value!]);
          expect(result.length, equals(1));
        });
        test('By Description', () async {
          expect(
            (await dao.search(descriptions: [manga.description.value!])).length,
            equals(1),
          );
        });
      });
    });
  });
}
