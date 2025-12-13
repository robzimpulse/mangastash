import 'dart:typed_data';

import 'package:sqlite3/wasm.dart';

import '../database.dart';

/// Example: https://github.com/simolus3/drift/issues/3511#issuecomment-2755611490
Future<Uint8List> backupDatabase({
  required String dbName,
  required AppDatabase database,
}) async {
  // Manually open the file system previously used
  final fs = await IndexedDbFileSystem.open(dbName: dbName);
  const path = '/database'; // Drift will always use this path.

  final (file: file, outFlags: _) = fs.xOpen(Sqlite3Filename(path), 0);
  final blob = Uint8List(file.xFileSize());
  file.xRead(blob, 0);
  file.xClose();

  await fs.close();
  return blob;
}