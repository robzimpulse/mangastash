import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';

void main() {
  late AppDatabase db;
  late ImageDao dao;

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    dao = ImageDao(db);
  });

  final values = Map.fromEntries(
    List.generate(10, (chpIdx) {
      return MapEntry(
        'chapter_id_$chpIdx',
        List.generate(10, (imgIdx) => 'web_url_${chpIdx}_$imgIdx'),
      );
    }),
  );

  final valuesLength = values.entries.fold(
    0,
    (total, curr) => total + curr.value.length,
  );

  tearDown(() => db.close());

  group('Image Dao Test', () {
    setUp(() async {
      for (final entry in values.entries) {
        await dao.adds(entry.key, values: entry.value);
      }
    });

    tearDown(() async => await db.clear());

    group('With New Value', () {
      final newValues = Map.fromEntries(
        List.generate(10, (chpIdx) {
          return MapEntry(
            'chapter_id_new_$chpIdx',
            List.generate(10, (imgIdx) => 'web_url_new_${chpIdx}_$imgIdx'),
          );
        }),
      );

      final newValuesLength = newValues.entries.fold(
        0,
        (total, curr) => total + curr.value.length,
      );

      setUp(() async {
        for (final entry in newValues.entries) {
          await dao.adds(entry.key, values: entry.value);
        }
      });

      group('Search Value', () {
        test('By Chapter Id', () async {
          expect(
            (await dao.search(chapterIds: [...newValues.keys])).length,
            equals(newValuesLength),
          );
          expect(
            (await dao.all).length,
            equals(valuesLength + newValuesLength),
          );
        });

        test('By Web Url', () async {
          final urls = [...newValues.values.expand((e) => e)];
          expect(
            (await dao.search(webUrls: urls)).length,
            equals(newValuesLength),
          );
          expect(
            (await dao.all).length,
            equals(valuesLength + newValuesLength),
          );
        });
      });

      group('Remove Value', () {
        test('By Chapter ID', () async {
          expect(
            (await dao.remove(chapterIds: [...newValues.keys])).length,
            equals(newValuesLength),
          );

          expect((await dao.all).length, equals(valuesLength));
        });

        test('By Web Url', () async {
          final urls = [...newValues.values.expand((e) => e)];
          expect(
            (await dao.remove(webUrls: urls)).length,
            equals(newValuesLength),
          );
          expect((await dao.all).length, equals(valuesLength));
        });

        test('Single Value', () async {
          final updatedValue = newValues.map(
            (key, value) => MapEntry(key, [...value.take(3)]),
          );
          final urls = [...updatedValue.values.expand((e) => e)];
          expect((await dao.remove(webUrls: urls)).length, equals(urls.length));
          expect(
            (await dao.all).length,
            equals(valuesLength + newValuesLength - urls.length),
          );
        });
      });

      test('Add Value', () async {
        expect(
          (await dao.all).length,
          equals(valuesLength + newValuesLength),
        );
      });
    });
  });
}
