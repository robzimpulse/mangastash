import 'package:core_network/core_network.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:universal_io/universal_io.dart';

class RestoreDatabaseUseCase {
  final AppDatabase _database;
  final Executor _executor;

  const RestoreDatabaseUseCase({
    required AppDatabase database,
    required Executor executor,
  }) : _database = database,
       _executor = executor;

  // Example: https://github.com/simolus3/drift/blob/96b3947fc16de99ffe25bcabc124e3b3a7c69571/examples/app/lib/screens/backup/supported.dart#L47-L68
  Future<Result<void>> execute({required File file}) async {
    try {
      await _database.close();

      final backupDb = sqlite3.open(file.absolute.path);

      // Vacuum it into a temporary location first to make sure it's working.
      final tempPath = await getTemporaryDirectory();
      final tempDb = path.join(tempPath.path, 'import.db');

      backupDb
        ..execute('VACUUM INTO ?', [tempDb])
        ..dispose();

      // Then replace the existing database file with it.
      final tempDbFile = File(tempDb);
      await tempDbFile.copy((await _executor.getDatabaseFile()).path);
      await tempDbFile.delete();

      return Success(null);
    } catch (e) {
      return Error(e);
    }
  }
}
