import 'dart:typed_data';

import '../../database.dart';
import '../filesystem/filesystem_io.dart';

/// Example: https://github.com/simolus3/drift/blob/96b3947fc16de99ffe25bcabc124e3b3a7c69571/examples/app/lib/screens/backup/supported.dart#L47-L68
Future<Uint8List> backupDatabase({
  required String dbName,
  required AppDatabase database,
}) async {
  final directory = await rootDirectory();
  final timestamp = DateTime.timestamp().microsecondsSinceEpoch;
  final file = directory.childFile('$timestamp.sqlite');

  // Make sure the directory of the file exists
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  // However, the file itself must not exist
  if (await file.exists()) {
    await file.delete();
  }

  await database.customStatement('VACUUM INTO ?', [file.absolute.path]);

  return file.readAsBytes().whenComplete(() => file.delete());
}