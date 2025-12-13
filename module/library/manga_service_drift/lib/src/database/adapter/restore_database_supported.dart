import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:universal_io/universal_io.dart';

import '../database.dart';
import '../executor.dart';

// Example: https://github.com/simolus3/drift/blob/96b3947fc16de99ffe25bcabc124e3b3a7c69571/examples/app/lib/screens/backup/supported.dart#L47-L68
Future<void> restoreDatabase({
  required File file,
  required AppDatabase database,
  required Executor executor,
}) async {
  await database.close();

  final backupDb = sqlite3.open(file.absolute.path);

  // Vacuum it into a temporary location first to make sure it's working.
  final tempPath = await getTemporaryDirectory();
  final tempDb = path.join(tempPath.path, 'import.db');

  backupDb
    ..execute('VACUUM INTO ?', [tempDb])
    ..dispose();
  // Then replace the existing database file with it.
  final tempDbFile = File(tempDb);
  await tempDbFile.copy((await executor.databaseFile()).path);
  await tempDbFile.delete();
}
