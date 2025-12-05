import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';

void main() {
  late AppDatabase db;
  late MangaDao dao;
  late TagDao tagDao;

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

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    dao = MangaDao(db);
    tagDao = TagDao(db);
  });

  tearDown(() => db.close());

  test('Create Delete Mangas', () async {
    final results = await dao.adds(
      values: {for (final (manga, tags) in mangas) manga: tags},
    );
    expect((await dao.all).length, equals(results.length));
    expect(dao.stream, emits(await dao.all));

    await dao.remove(ids: results.map((e) => e.manga?.id).nonNulls.toList());
    expect(dao.stream, emits([]));
    expect((await dao.all).length, equals(0));
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
        expect(dao.stream, emits(await dao.all));
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
        expect(dao.stream, emits(await dao.all));
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
