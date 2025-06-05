import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  late AppDatabase db;
  late ChapterDao dao;
  late ImageDao imageDao;

  setUp(() {
    db = AppDatabase(
      executor: DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    dao = ChapterDao(db);
    imageDao = ImageDao(db);
  });

  final chapters = List.generate(
    10,
    (chpIdx) => (
      ChapterTablesCompanion(
        id: Value('id_$chpIdx'),
        title: Value('title_$chpIdx'),
        mangaId: const Value('manga_id_1'),
        volume: Value('volume_$chpIdx'),
        chapter: Value('chapter_$chpIdx'),
        translatedLanguage: Value('translated_language_$chpIdx'),
        scanlationGroup: Value('scanlation_group_$chpIdx'),
        webUrl: Value('web_url_$chpIdx'),
        lastReadAt: Value(DateTime.timestamp()),
      ),
      List.generate(10, (imgIdx) => 'chapter_id_${chpIdx}_image_url_$imgIdx'),
    ),
  );

  tearDown(() => db.close());

  group('Image Dao Test', () {
    setUp(() async {
      for (final (chapter, images) in chapters) {
        await dao.add(value: chapter, images: images);
      }
    });

    tearDown(() async => await db.clear());

    group('Specific Cases', () {
      test('Update Last Read At', () async {
        final chapter = (
          const ChapterTablesCompanion(
            id: Value('id_new'),
            title: Value('title_new'),
            mangaId: Value('manga_id_new'),
            volume: Value('volume_new'),
            chapter: Value('chapter_new'),
            translatedLanguage: Value('translated_language_new'),
            scanlationGroup: Value('scanlation_group_new'),
            webUrl: Value('web_url_new'),
          ),
          List.generate(
            10,
            (imgIdx) => 'chapter_id_new_image_url_$imgIdx',
          ),
        );

        final chapterUpdated = (
          chapter.$1.copyWith(
            lastReadAt: Value(DateTime.timestamp()),
          ),
          chapter.$2
        );

        await dao.add(value: chapter.$1, images: chapter.$2);
        expect((await dao.all).length, equals(chapters.length + 1));

        final a = await dao.search(ids: [chapter.$1.id.value]);
        expect(a.first.chapter?.lastReadAt == null, isTrue);

        await dao.add(value: chapterUpdated.$1, images: chapterUpdated.$2);
        expect((await dao.all).length, equals(chapters.length + 1));

        final b = await dao.search(ids: [chapter.$1.id.value]);
        expect(b.first.chapter?.lastReadAt == null, isFalse);

        await dao.add(value: chapter.$1, images: chapter.$2);
        expect((await dao.all).length, equals(chapters.length + 1));

        final c = await dao.search(ids: [chapter.$1.id.value]);
        expect(c.first.chapter?.lastReadAt == null, isFalse);
      });
    });

    group('With New Value', () {
      final chapter = (
        ChapterTablesCompanion(
          id: const Value('id_new'),
          title: const Value('title_new'),
          mangaId: const Value('manga_id_new'),
          volume: const Value('volume_new'),
          chapter: const Value('chapter_new'),
          translatedLanguage: const Value('translated_language_new'),
          scanlationGroup: const Value('scanlation_group_new'),
          webUrl: const Value('web_url_new'),
          lastReadAt: Value(DateTime.timestamp()),
        ),
        List.generate(
          10,
          (imgIdx) => 'chapter_id_new_image_url_$imgIdx',
        ),
      );

      test('Add Value', () async {
        await dao.add(value: chapter.$1, images: chapter.$2);
        expect((await dao.all).length, equals(chapters.length + 1));
        expect((await imageDao.all).length, equals((chapters.length + 1) * 10));
      });

      group('Search Value', () {
        test('By Id', () async {
          expect(
            (await dao.search(ids: [chapter.$1.id.value])).length,
            equals(0),
          );
        });
        test('By Manga Id', () async {
          final result = await dao.search(
            mangaIds: [chapter.$1.mangaId.value!],
          );
          expect(result.length, equals(0));
        });
        test('By Title', () async {
          expect(
            (await dao.search(titles: [chapter.$1.title.value!])).length,
            equals(0),
          );
        });
        test('By Volume', () async {
          expect(
            (await dao.search(volumes: [chapter.$1.volume.value!])).length,
            equals(0),
          );
        });
        test('By Chapter', () async {
          expect(
            (await dao.search(chapters: [chapter.$1.chapter.value!])).length,
            equals(0),
          );
        });
        test('By Translated Language', () async {
          final result = await dao.search(
            translatedLanguages: [chapter.$1.translatedLanguage.value!],
          );
          expect(result.length, equals(0));
        });
        test('By Scanlation Group', () async {
          final result = await dao.search(
            scanlationGroups: [chapter.$1.scanlationGroup.value!],
          );
          expect(result.length, equals(0));
        });
        test('By Web Url', () async {
          expect(
            (await dao.search(webUrls: [chapter.$1.webUrl.value!])).length,
            equals(0),
          );
        });
      });
    });

    group('With Old Value', () {
      final chapter = ([...chapters]..shuffle()).first;

      test('Add Value', () async {
        await dao.add(value: chapter.$1, images: chapter.$2);
        expect((await dao.all).length, equals(chapters.length));
        expect((await imageDao.all).length, equals((chapters.length) * 10));
      });

      group('Search Value', () {
        test('By Id', () async {
          expect(
            (await dao.search(ids: [chapter.$1.id.value])).length,
            equals(1),
          );
        });
        test('By Manga Id', () async {
          final result = await dao.search(
            mangaIds: [chapter.$1.mangaId.value!],
          );
          expect(result.length, equals(chapters.length));
        });
        test('By Title', () async {
          expect(
            (await dao.search(titles: [chapter.$1.title.value!])).length,
            equals(1),
          );
        });
        test('By Volume', () async {
          expect(
            (await dao.search(volumes: [chapter.$1.volume.value!])).length,
            equals(1),
          );
        });
        test('By Chapter', () async {
          expect(
            (await dao.search(chapters: [chapter.$1.chapter.value!])).length,
            equals(1),
          );
        });
        test('By Translated Language', () async {
          final result = await dao.search(
            translatedLanguages: [chapter.$1.translatedLanguage.value!],
          );
          expect(result.length, equals(1));
        });
        test('By Scanlation Group', () async {
          final result = await dao.search(
            scanlationGroups: [chapter.$1.scanlationGroup.value!],
          );
          expect(result.length, equals(1));
        });
        test('By Web Url', () async {
          expect(
            (await dao.search(webUrls: [chapter.$1.webUrl.value!])).length,
            equals(1),
          );
        });
      });
    });
  });
}
