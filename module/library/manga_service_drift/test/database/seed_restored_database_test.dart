/// Tests for the IO query-executor seeding: a pending restore must replace
/// the live database file atomically and remove stale journal side files
/// before the database is opened.
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/database/adapter/query_executor/query_executor_io.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('seed_test');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('replaces the live file and removes stale journals', () async {
    final data = Uint8List.fromList(List.generate(32, (i) => i));
    File('${tempDir.path}/testdb.sqlite').writeAsStringSync('old-live');
    File('${tempDir.path}/testdb.sqlite-wal').writeAsStringSync('wal');
    File('${tempDir.path}/testdb.sqlite-shm').writeAsStringSync('shm');
    File('${tempDir.path}/testdb.sqlite-journal').writeAsStringSync('journal');

    await seedRestoredDatabase(
      data: data,
      directoryPath: tempDir.path,
      name: 'testdb',
    );

    expect(File('${tempDir.path}/testdb.sqlite').readAsBytesSync(), data);
    expect(File('${tempDir.path}/testdb.sqlite-wal').existsSync(), isFalse);
    expect(File('${tempDir.path}/testdb.sqlite-shm').existsSync(), isFalse);
    expect(File('${tempDir.path}/testdb.sqlite-journal').existsSync(), isFalse);
    expect(
      File('${tempDir.path}/testdb.sqlite.restored').existsSync(),
      isFalse,
    );
  });

  test('queryExecutor opens the seeded file and reads restored rows', () async {
    final sourceDir = await Directory.systemTemp.createTemp('seed_src');
    final db = sqlite3.open('${sourceDir.path}/src.sqlite');
    db.execute('CREATE TABLE t (id INTEGER); INSERT INTO t VALUES (42);');
    db.dispose();
    final bytes = File('${sourceDir.path}/src.sqlite').readAsBytesSync();
    sourceDir.deleteSync(recursive: true);

    final executor = queryExecutor(
      name: 'testdb',
      restoredDb: bytes,
      ioOptions: DriftNativeOptions(
        databaseDirectory: () async => Directory(tempDir.path),
        tempDirectoryPath: () async => tempDir.path,
        shareAcrossIsolates: false,
      ),
    );

    await executor.ensureOpen(_RawUser());
    final rows = await executor.runSelect('SELECT id FROM t', []);
    await executor.close();

    expect(rows, equals([{'id': 42}]));
  });
}

class _RawUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {
  }
}
