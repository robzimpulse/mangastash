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
      chapterId: const Value('chapter_id'),
      order: Value(index),
    ),
  );

  tearDown(() => db.close());

  group('Image Dao Test', () {
    setUp(() async {
      for (final image in images) {
        await dao.add(value: image);
      }
    });

    tearDown(() async => await db.clear());

    group('Add Image', () {
      test('Normal', () async {
        await dao.add(
          value: const ImageTablesCompanion(
            webUrl: Value('web_url_new'),
            chapterId: Value('chapter_id_new'),
            order: Value(0),
          ),
        );

        expect((await dao.all).length, equals(images.length + 1));
      });

      group('With Empty ID', () {
        final image = images.first.copyWith(id: const Value.absent());

        test('With Conflicting Chapter Id & Web Url & Order', () async {
          expect(
            () => dao.add(value: image),
            throwsA(isA<SqliteException>()),
          );

          expect((await dao.all).length, equals(images.length));
        });

        test('With Conflicting Chapter Id & Web Url', () async {
          expect(
            () => dao.add(value: image.copyWith(order: const Value(99))),
            throwsA(isA<SqliteException>()),
          );

          expect((await dao.all).length, equals(images.length));
        });

        test('With Conflicting Chapter Id & Order', () async {
          expect(
            () => dao.add(
              value: image.copyWith(webUrl: const Value('test_image_url')),
            ),
            throwsA(isA<SqliteException>()),
          );

          expect((await dao.all).length, equals(images.length));
        });

        test('With Conflicting Image & Order', () async {
          expect(
            () => dao.add(
              value: image.copyWith(chapterId: const Value('chapter_id_new')),
            ),
            throwsA(isA<SqliteException>()),
          );

          expect((await dao.all).length, equals(images.length));
        });
      });
    });
  });
}
