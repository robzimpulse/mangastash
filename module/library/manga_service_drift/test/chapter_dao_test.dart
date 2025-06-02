import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  late AppDatabase db;
  late ChapterV2Dao dao;

  setUp(() {
    db = AppDatabase(
      executor: DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    dao = ChapterV2Dao(db);
  });

  final chapters = List.generate(
    10,
    (index) => ChapterTablesCompanion(
      id: Value('id_$index'),
      title: Value('title_$index'),
      mangaId: const Value('manga_id_1'),
      volume: Value('volume_$index'),
      chapter: Value('chapter_$index'),
      translatedLanguage: Value('translated_language_$index'),
      scanlationGroup: Value('scanlation_group_$index'),
      webUrl: Value('web_url_$index'),
    ),
  );

  tearDown(() => db.close());

  group('Image Dao Test', () {
    setUp(() async {
      for (final chapter in chapters) {
        await dao.add(
          value: chapter,
          images: List.generate(
            100,
            (index) => 'chapter_${chapter.id}_image_$index',
          ),
        );
      }
    });

    tearDown(() async => await db.clear());

    group('Add Chapter', () {
      test('Normal', () async {
        await dao.add(
          value: ChapterTablesCompanion(
            webUrl: Value('web_url_${chapters.length + 1}'),
          ),
          images: List.generate(
            100,
            (index) => 'chapter_id_${chapters.length + 1}_image_$index',
          ),
        );

        expect((await dao.all).length, equals(chapters.length + 1));
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
              (index) => 'chapter_id_1_image_$index',
            ),
          ),
          throwsA(isA<SqliteException>()),
        );
      });
    });
  });
}
