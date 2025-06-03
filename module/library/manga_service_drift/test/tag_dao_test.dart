import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  late AppDatabase db;
  late TagDao dao;

  setUp(() {
    db = AppDatabase(
      executor: DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    dao = TagDao(db);
  });

  final values = List.generate(
    10,
    (index) => TagTablesCompanion(
      id: Value('id_$index'),
      name: Value('name_$index'),
    ),
  );

  tearDown(() => db.close());

  group('Tag Dao Test', () {
    setUp(() async {
      for (final value in values) {
        await dao.add(value: value);
      }
    });

    tearDown(() async => await db.clear());

    group('With New Value', () {
      const value = TagTablesCompanion(
        id: Value('id_new'),
        name: Value('name_new'),
      );

      group('Search Value', () {
        test('By Name', () async {
          expect(
            (await dao.search(names: [value.name.value])).length,
            equals(0),
          );
        });

        test('By Id', () async {
          expect(
            (await dao.search(ids: [value.id.value])).length,
            equals(0),
          );
        });
      });

      group('Remove Value', () {
        test('By Name', () async {
          expect(
            (await dao.remove(names: [value.name.value])).length,
            equals(0),
          );

          expect(
            (await dao.all).length,
            equals(values.length),
          );
        });

        test('By Id', () async {
          expect(
            (await dao.remove(ids: [value.id.value])).length,
            equals(0),
          );

          expect(
            (await dao.all).length,
            equals(values.length),
          );
        });
      });

      test('Add Value', () async {
        await dao.add(value: value);
        expect((await dao.all).length, equals(values.length + 1));
      });

    });

    group('With Existing Value', () {
      final value = (values..shuffle()).first;

      group('Search Value', () {
        test('By Name', () async {
          expect(
            (await dao.search(names: [value.name.value])).length,
            equals(1),
          );
        });

        test('By Id', () async {
          expect(
            (await dao.search(ids: [value.id.value])).length,
            equals(1),
          );
        });
      });

      group('Remove Value', () {
        test('By Name', () async {
          expect(
            (await dao.remove(names: [value.name.value])).length,
            equals(1),
          );

          expect(
            (await dao.all).length,
            equals(values.length - 1),
          );
        });

        test('By Id', () async {
          expect(
            (await dao.remove(ids: [value.id.value])).length,
            equals(1),
          );

          expect(
            (await dao.all).length,
            equals(values.length - 1),
          );
        });
      });

      group('Add Value', () {
        test('With Conflicting Value', () async {
          await dao.add(value: value);
          expect((await dao.all).length, equals(values.length));
        });

        test('With Conflicting Name', () async {
          await dao.add(value: value.copyWith(id: const Value('id_new')));
          expect((await dao.all).length, equals(values.length + 1));
        });

        test('With Conflicting Id', () async {
          await dao.add(value: value.copyWith(name: const Value('name_new')));
          expect((await dao.all).length, equals(values.length));
        });
      });
    });

  });
}
