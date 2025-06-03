import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  late AppDatabase db;
  late ImageDao dao;

  setUp(() {
    db = AppDatabase(
      executor: DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    dao = ImageDao(db);
  });

  final values = List.generate(
    10,
    (chpIdx) => (
      chpIdx,
      List.generate(
        10,
        (imgIdx) => ImageTablesCompanion(
          id: Value('id_$imgIdx'),
          webUrl: Value('web_url_$imgIdx'),
          chapterId: Value('chapter_id_$imgIdx'),
          order: Value(imgIdx),
        ),
      ),
    ),
  );

  tearDown(() => db.close());

  group('Image Dao Test', () {
    setUp(() async {
      for (final (_, values) in values) {
        for (final value in values) {
          await dao.add(value: value);
        }
      }
    });

    tearDown(() async => await db.clear());

    group('With New Value', () {
      const value = ImageTablesCompanion(
        id: Value('id_new'),
        webUrl: Value('web_url_new'),
        chapterId: Value('chapter_id_new'),
        order: Value(0),
      );

      group('Search Value', () {
        test('By Chapter Id', () async {
          expect(
            (await dao.search(chapterIds: [value.chapterId.value])).length,
            equals(0),
          );
        });

        test('By Id', () async {
          expect(
            (await dao.search(ids: [value.id.value])).length,
            equals(0),
          );
        });

        test('By Web Url', () async {
          expect(
            (await dao.search(ids: [value.webUrl.value])).length,
            equals(0),
          );
        });
      });

      group('Remove Value', () {
        test('By Chapter ID', () async {
          expect(
            (await dao.remove(chapterIds: [value.chapterId.value])).length,
            equals(0),
          );

          expect((await dao.all).length, equals(values.length));
        });

        test('By Web Url', () async {
          expect(
            (await dao.remove(webUrls: [value.webUrl.value])).length,
            equals(0),
          );

          expect((await dao.all).length, equals(values.length));
        });

        test('By Id', () async {
          expect(
            (await dao.remove(ids: [value.id.value])).length,
            equals(0),
          );

          expect((await dao.all).length, equals(values.length));
        });
      });

      test('Add Value', () async {
        await dao.add(value: value);
        expect((await dao.all).length, equals(values.length + 1));
      });

    });

    group('With Existing Value', () {
      final value = ([...values.expand((e) => e.$2)]..shuffle()).first;

      group('Search Value', () {
        test('By Chapter Id', () async {
          expect(
            (await dao.search(chapterIds: [value.chapterId.value])).length,
            greaterThan(0),
          );
        });

        test('By Id', () async {
          expect(
            (await dao.search(ids: [value.id.value])).length,
            equals(1),
          );
        });

        test('By Web Url', () async {
          expect(
            (await dao.search(ids: [value.webUrl.value])).length,
            equals(0),
          );
        });
      });

      group('Remove Value', () {
        test('By Chapter ID', () async {
          expect(
            (await dao.remove(chapterIds: [value.chapterId.value])).length,
            equals(1),
          );

          expect((await dao.all).length, equals(values.length - 1));
        });

        test('By Web Url', () async {
          expect(
            (await dao.remove(webUrls: [value.webUrl.value])).length,
            equals(1),
          );

          expect((await dao.all).length, equals(values.length - 1));
        });

        test('By Id', () async {
          expect(
            (await dao.remove(ids: [value.id.value])).length,
            equals(1),
          );

          expect((await dao.all).length, equals(values.length - 1));
        });
      });

      test('Add Value', () async {
        await dao.add(value: value);
        expect((await dao.all).length, equals(values.length));
      });
    });
  });
}
