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

    group('Add Chapter', () {
      group('With New Manga', () {
        final chapter = ChapterTablesCompanion(
          webUrl: Value('web_url_${chapters.length + 1}'),
        );

        test('With New Image', () async {
          final images = List.generate(
            10,
            (index) => 'chapter_id_${chapters.length + 1}_image_url_$index',
          );

          await dao.add(value: chapter, images: images);

          expect((await dao.all).length, equals(chapters.length + 1));
          expect(
            (await imageDao.all).length,
            equals((chapters.length + 1) * 10),
          );
        });

        test('With Old Image', () async {
          final images = chapters.first.$2;

          expect(
            () => dao.add(value: chapter, images: images),
            throwsA(isA<SqliteException>()),
          );

          expect((await dao.all).length, equals(chapters.length));
          expect((await imageDao.all).length, equals((chapters.length) * 10));
        });
      });

      test('With Conflicting Manga ID and Web Url', () async {
        expect(
          () => dao.add(
            value: const ChapterTablesCompanion(
              mangaId: Value('manga_id_1'),
              webUrl: Value('web_url_1'),
            ),
            images: List.generate(
              100,
              (index) => 'chapter_id_1_image_url_$index',
            ),
          ),
          throwsA(isA<SqliteException>()),
        );
      });
    });
  });
}
