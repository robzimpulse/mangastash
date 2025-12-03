import 'package:core_network/core_network.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:path/path.dart';
import 'package:universal_io/universal_io.dart';

import 'listen_backup_path_use_case.dart';

class BackupDatabaseUseCase {
  final AppDatabase _database;
  final ListenBackupPathUseCase _listenBackupPathUseCase;

  const BackupDatabaseUseCase({
    required AppDatabase database,
    required ListenBackupPathUseCase listenBackupPathUseCase,
  }) : _database = database,
       _listenBackupPathUseCase = listenBackupPathUseCase;

  // Example: https://github.com/simolus3/drift/blob/96b3947fc16de99ffe25bcabc124e3b3a7c69571/examples/app/lib/screens/backup/supported.dart#L47-L68
  Future<Result<File>> execute() async {
    try {
      final directory = _listenBackupPathUseCase.backupPathStream.valueOrNull;
      if (directory == null) throw Exception('No backup path');

      final name = 'mangastash_backup_${DateTime.timestamp().toString()}.db';
      final file = File(join(directory.path, name));

      // Make sure the directory of the file exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // However, the file itself must not exist
      if (await file.exists()) {
        await file.delete();
      }

      await _database.customStatement('VACUUM INTO ?', [file.absolute.path]);

      return Success(file);
    } catch (e) {
      return Error(e);
    }
  }
}
