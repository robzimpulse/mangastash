import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Replaces the live `<directoryPath>/<name>.sqlite` file with [data].
///
/// Stale journal side files (`-wal`, `-shm`, `-journal`) of the old
/// database are deleted first so leftovers cannot corrupt the restored
/// file on the next open. The temp file is written in the same directory
/// and renamed over the target, so the swap is atomic on the same volume.
///
/// Called from [queryExecutor] when a pending restore was stashed by
/// `restore_database_io.dart`; the database is opened right after.
Future<void> seedRestoredDatabase({
  required Uint8List data,
  required String directoryPath,
  required String name,
}) async {
  final directory = Directory(directoryPath);
  final temp = File('${directory.path}/$name.sqlite.restored');
  await temp.writeAsBytes(data, flush: true);
  for (final suffix in const ['', '-wal', '-shm', '-journal']) {
    final file = File('${directory.path}/$name.sqlite$suffix');
    if (await file.exists()) await file.delete();
  }
  await temp.rename('${directory.path}/$name.sqlite');
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
