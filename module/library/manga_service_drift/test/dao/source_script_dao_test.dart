// Tests for SourceScriptDao (issue #115): upsert/replace/get/remove/watch and
// the unique `name` constraint of source_script_tables.
// Usage: `fvm flutter test test/dao/source_script_dao_test.dart` from the
// manga_service_drift module directory.
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;

SourceScriptTablesCompanion _row({
  String id = 'asura-scans',
  String name = 'Asura Scans',
  String code = 'return 1;',
  int version = 1,
  SourceScriptOrigin origin = SourceScriptOrigin.shippedEdited,
  int? baseVersion = 1,
}) {
  return SourceScriptTablesCompanion.insert(
    id: id,
    name: name,
    code: code,
    version: version,
    origin: origin,
    baseVersion: Value(baseVersion),
  );
}

void main() {
  late AppDatabase db;
  late SourceScriptDao dao;

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    dao = SourceScriptDao(db);
  });

  tearDown(() => db.close());

  group('SourceScriptDao', () {
    test('upsert then get returns the row', () async {
      await dao.upsert(_row());

      final result = await dao.get('asura-scans');

      expect(result, isNotNull);
      expect(result!.id, 'asura-scans');
      expect(result.name, 'Asura Scans');
      expect(result.code, 'return 1;');
      expect(result.version, 1);
      expect(result.origin, SourceScriptOrigin.shippedEdited);
      expect(result.baseVersion, 1);
    });

    test('get returns null for an unknown id', () async {
      expect(await dao.get('missing'), isNull);
    });

    test('upserting the same id replaces code and version', () async {
      await dao.upsert(_row());
      await dao.upsert(_row(code: 'return 2;', version: 2));

      final all = await dao.getAll();

      expect(all, hasLength(1));
      expect(all.single.code, 'return 2;');
      expect(all.single.version, 2);
    });

    test('remove deletes the row', () async {
      await dao.upsert(_row());
      await dao.remove('asura-scans');

      expect(await dao.get('asura-scans'), isNull);
      expect(await dao.getAll(), isEmpty);
    });

    test('watchAll emits after an upsert', () async {
      final emissions = expectLater(
        dao.watchAll().map((e) => e.map((r) => r.id).toList()),
        emitsInOrder([
          <String>[],
          ['asura-scans'],
        ]),
      );

      await Future<void>.delayed(Duration.zero);
      await dao.upsert(_row());

      await emissions;
    });

    test('a second row with the same name but another id throws', () async {
      await dao.upsert(_row());

      await expectLater(
        dao.upsert(_row(id: 'other-id', origin: SourceScriptOrigin.custom)),
        throwsA(isA<SqliteException>()),
      );

      final all = await dao.getAll();
      expect(all, hasLength(1));
      expect(all.single.id, 'asura-scans');
    });

    test('custom script stores a null baseVersion', () async {
      await dao.upsert(
        _row(
          id: 'mine',
          name: 'Mine',
          origin: SourceScriptOrigin.custom,
          baseVersion: null,
        ),
      );

      final result = await dao.get('mine');

      expect(result!.origin, SourceScriptOrigin.custom);
      expect(result.baseVersion, isNull);
    });
  });
}
