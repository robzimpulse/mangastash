import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../database.dart';
import '../../executor.dart';

/// Validates the backup [data] and stashes it for the next app start via
/// [Executor.setBackup]; the seeded open happens in `query_executor_io.dart`.
///
/// The live database is never closed or modified here: the caller keeps
/// using the current data until `WrapperScreen.restart` rebuilds the
/// locator, at which point the stashed bytes replace the database file.
/// Throws [SqliteException] when [data] is not a working SQLite database,
/// before anything destructive has happened.
///
/// Example: https://github.com/simolus3/drift/blob/96b3947fc16de99ffe25bcabc124e3b3a7c69571/examples/app/lib/screens/backup/supported.dart#L47-L68
Future<void> restoreDatabase({
  required Uint8List data,
  required AppDatabase database,
  required Executor executor,
}) async {
  final directory = await executor.databaseDirectory();
  final stamp = DateTime.timestamp().microsecondsSinceEpoch;
  final source = directory.childFile('restore-$stamp.sqlite');
  final verify = directory.childFile('restore-$stamp-verify.sqlite');
  try {
    await source.writeAsBytes(data, flush: true);
    final backup = sqlite3.open(source.absolute.path);
    try {
      /// VACUUM INTO a throwaway copy to prove the bytes are a working
      /// database before they can replace the live file on restart.
      backup.execute('VACUUM INTO ?', [verify.absolute.path]);
    } finally {
      backup.dispose();
    }
    Executor.setBackup(data);
  } finally {
    if (await source.exists()) await source.delete();
    if (await verify.exists()) await verify.delete();
  }
}
