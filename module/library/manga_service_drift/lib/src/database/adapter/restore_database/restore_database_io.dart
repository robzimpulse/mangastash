import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../database.dart';
import '../../executor.dart';
import '../filesystem/filesystem_io.dart';

/// example: https://github.com/simolus3/drift/blob/96b3947fc16de99ffe25bcabc124e3b3a7c69571/examples/app/lib/screens/backup/supported.dart#L47-L68
Future<void> restoreDatabase({
  required Uint8List data,
  required AppDatabase database,
  required Executor executor,
}) async {
  /// close current database
  await database.close();

  /// put database data into temporary file
  final directory = await rootDirectory();
  final file = await directory.childFile('backup.sqlite').writeAsBytes(data);

  /// Open the temporary file
  final backup = sqlite3.open(file.absolute.path);

  /// Vacuum it into a another file in the temporary location first
  /// to make sure it's working.
  final temporary = directory.childFile('temp.sqlite');
  backup..execute('VACUUM INTO ?', [temporary.path])..dispose();

  /// Then replace the existing database file with it.
  await temporary.copy((await executor.databaseFile()).path);
  await temporary.delete();
}
