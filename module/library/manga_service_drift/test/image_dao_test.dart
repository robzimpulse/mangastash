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

  final images = List.generate(
    100,
    (index) => ImageTablesCompanion(
      id: Value('image_$index'),
      webUrl: Value('web_url_$index'),
      chapterId: Value('chapter_id_$index'),
      order: Value(index),
    ),
  );

  tearDown(() => db.close());

  group('Image Dao Test', () {
    setUp(() async {
      for (final image in images) {
        await dao.add(
          chapterId: 'chapter_id',
          image: image.webUrl.value,
          index: image.order.value,
        );
      }
    });

    tearDown(() async => await db.clear());

    group('Add Image', () {
      test('Normal', () async {
        await dao.add(
          chapterId: 'chapter_id_new',
          image: 'web_url_new',
          index: 0,
        );

        expect((await dao.all).length, equals(images.length + 1));
      });

      test('With Conflicting Chapter Id & Web Url & Order', () async {
        final image = images.first;

        expect(
          () => dao.add(
            chapterId: 'chapter_id',
            image: image.webUrl.value,
            index: image.order.value,
          ),
          throwsA(isA<SqliteException>()),
        );

        expect((await dao.all).length, equals(images.length));
      });

      test('With Conflicting Chapter Id & Web Url', () async {
        final image = images.first;

        expect(
          () => dao.add(
            chapterId: 'chapter_id',
            image: image.webUrl.value,
            index: 99,
          ),
          throwsA(isA<SqliteException>()),
        );

        expect((await dao.all).length, equals(images.length));
      });

      test('With Conflicting Chapter Id & Order', () async {
        final image = images.first;

        expect(
          () => dao.add(
            chapterId: 'chapter_id',
            image: 'test_image_url',
            index: image.order.value,
          ),
          throwsA(isA<SqliteException>()),
        );

        expect((await dao.all).length, equals(images.length));
      });

      test('With Conflicting Image & Order', () async {
        final image = images.first;

        expect(
          () => dao.add(
            chapterId: 'chapter_id_new',
            image: image.webUrl.value,
            index: image.order.value,
          ),
          throwsA(isA<SqliteException>()),
        );

        expect((await dao.all).length, equals(images.length));
      });
    });
  });
}
