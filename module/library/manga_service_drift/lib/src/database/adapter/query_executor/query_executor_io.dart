import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Replaces the live `<directoryPath>/<name>.sqlite` file with [data].
///
/// Stale journal side files (`-wal`, `-shm`, `-journal`) of the old
/// database are deleted first so leftovers cannot corrupt the restored
/// file on the next open. The temp file is written in the same directory
/// and the swap goes through two renames — live file aside, then temp
/// over the target — so both are atomic on the same volume, and a failed
/// swap puts the old database back instead of leaving none at all.
///
/// Called from [queryExecutor] when a pending restore was stashed by
/// `restore_database_io.dart`; the database is opened right after.
///
/// [rename] is injected by tests to simulate rename failures; it defaults
/// to [File.rename].
Future<void> seedRestoredDatabase({
  required Uint8List data,
  required String directoryPath,
  required String name,
  Future<File> Function(File file, String newPath)? rename,
}) async {
  final renameFile =
      rename ?? (File file, String newPath) => file.rename(newPath);
  final directory = Directory(directoryPath);
  final live = File('${directory.path}/$name.sqlite');
  final aside = File('${directory.path}/$name.sqlite.preRestore');
  final temp = File('${directory.path}/$name.sqlite.restored');
  await temp.writeAsBytes(data, flush: true);
  for (final suffix in const ['-wal', '-shm', '-journal']) {
    final file = File('${directory.path}/$name.sqlite$suffix');
    if (await file.exists()) await file.delete();
  }
  final hadLiveFile = await live.exists();
  if (hadLiveFile) await renameFile(live, aside.path);
  try {
    await renameFile(temp, live.path);
  } catch (error) {
    if (hadLiveFile) {
      try {
        await aside.rename(live.path);
      } catch (_) {
        // Best-effort rollback; the swap error is the one worth rethrowing.
      }
    }
    rethrow;
  }
  if (hadLiveFile && await aside.exists()) await aside.delete();
}

QueryExecutor queryExecutor({
  required String name,
  required DriftNativeOptions ioOptions,
  Uint8List? restoredDb,
}) {
  return LazyDatabase(() async {
    final restored = restoredDb;
    // drift_flutter types the resolver as Future<Object> so the file also
    // compiles for web; on IO it always resolves to a dart:io Directory.
    final directory = restored == null
        ? null
        : (await ioOptions.databaseDirectory?.call()) as Directory?;
    if (restored != null && directory != null) {
      await seedRestoredDatabase(
        data: restored,
        directoryPath: directory.path,
        name: name,
      );
    }
    return driftDatabase(name: name, native: ioOptions);
  });
}
