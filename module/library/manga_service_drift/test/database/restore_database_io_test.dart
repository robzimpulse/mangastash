/// Tests for the IO restore adapter: restore must validate the incoming
/// bytes, stash them for the next app start, never close the live
/// database, and leave no scratch files behind.
import 'dart:io';
import 'dart:typed_data';

import 'package:file/local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/adapter/restore_database/restore_database_io.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockExecutor extends Mock implements Executor {}

void main() {
  late Directory tempDir;
  late _MockAppDatabase database;
  late _MockExecutor executor;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('restore_test');
    Executor.getBackup();
    database = _MockAppDatabase();
    when(() => database.close()).thenAnswer((_) async {});
    executor = _MockExecutor();
    final fs = LocalFileSystem();
    when(
      () => executor.databaseDirectory(),
    ).thenAnswer((_) async => fs.directory(tempDir.path));
    when(
      () => executor.databaseFile(),
    ).thenAnswer(
      (_) async => fs.directory(tempDir.path).childFile('live.sqlite'),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  Uint8List validDatabaseBytes() {
    final sourceDir = Directory.systemTemp.createTempSync('restore_src');
    final path = '${sourceDir.path}/source.sqlite';
    final db = sqlite3.open(path);
    db.execute('CREATE TABLE t (id INTEGER); INSERT INTO t VALUES (1);');
    db.dispose();
    final bytes = File(path).readAsBytesSync();
    sourceDir.deleteSync(recursive: true);
    return bytes;
  }

  test('stashes validated bytes for restart and never closes the database', () async {
    final bytes = validDatabaseBytes();

    await restoreDatabase(data: bytes, database: database, executor: executor);

    verifyNever(() => database.close());
    expect(Executor.getBackup(), equals(bytes));
  });

  test('leaves no scratch files behind on success', () async {
    final bytes = validDatabaseBytes();

    await restoreDatabase(data: bytes, database: database, executor: executor);

    expect(tempDir.listSync(), isEmpty);
  });

  test('throws on corrupt bytes and leaves no scratch files', () async {
    final corrupt = Uint8List.fromList(List.generate(64, (i) => i % 256));

    await expectLater(
      restoreDatabase(data: corrupt, database: database, executor: executor),
      throwsA(isA<SqliteException>()),
    );
    expect(tempDir.listSync(), isEmpty);
  });
}
