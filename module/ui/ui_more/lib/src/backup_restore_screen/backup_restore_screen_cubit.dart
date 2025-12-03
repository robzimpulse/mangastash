import 'package:core_storage/core_storage.dart';
import 'package:path/path.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:universal_io/universal_io.dart';

import 'backup_restore_screen_state.dart';

class BackupRestoreScreenCubit extends Cubit<BackupRestoreScreenState>
    with AutoSubscriptionMixin {
  final AppDatabase _database;
  final SetBackupPathUseCase _setBackupPathUseCase;

  BackupRestoreScreenCubit({
    BackupRestoreScreenState initialState = const BackupRestoreScreenState(),
    required AppDatabase database,
    required ListenBackupPathUseCase listenBackupPathUseCase,
    required SetBackupPathUseCase setBackupPathUseCase,
    required GetRootPathUseCase getRootPathUseCase,
  }) : _database = database,
       _setBackupPathUseCase = setBackupPathUseCase,
       super(initialState.copyWith(rootPath: getRootPathUseCase.rootPath)) {
    addSubscription(
      listenBackupPathUseCase.backupPathStream.listen(
        (e) => emit(state.copyWith(backupPath: e)),
      ),
    );
  }

  void setBackupPath(String path) => _setBackupPathUseCase.setBackupPath(path);

  // Example: https://github.com/simolus3/drift/blob/96b3947fc16de99ffe25bcabc124e3b3a7c69571/examples/app/lib/screens/backup/supported.dart#L47-L68
  // Future<void> restore() async {
  //   final db = ref.read(AppDatabase.provider);
  //   await db.close();
  //
  //   // Open the selected database file
  //   final backupFile = await FilePicker.platform.pickFiles();
  //   if (backupFile == null) return;
  //   final backupDb = sqlite3.open(backupFile.files.single.path!);
  //
  //   // Vacuum it into a temporary location first to make sure it's working.
  //   final tempPath = await getTemporaryDirectory();
  //   final tempDb = p.join(tempPath.path, 'import.db');
  //   backupDb
  //     ..execute('VACUUM INTO ?', [tempDb])
  //     ..dispose();
  //
  //   // Then replace the existing database file with it.
  //   final tempDbFile = File(tempDb);
  //   await tempDbFile.copy((await databaseFile).path);
  //   await tempDbFile.delete();
  //
  //   // And now, re-open the database!
  //   ref.read(AppDatabase.provider.notifier).state = AppDatabase();
  // }

  Future<void> backup() async {
    final directory = state.backupPath;
    if (directory == null) return;
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
  }

  // Future<void> createDatabaseBackup(DatabaseConnectionUser database) async {
  //   final choosenDirectory = await FilePicker.platform.getDirectoryPath();
  //   if (choosenDirectory == null) return;
  //
  //   final parent = Directory(choosenDirectory);
  //   final file = File(p.join(choosenDirectory, 'drift_example_backup.db'));
  //
  //   // Make sure the directory of the file exists
  //   if (!await parent.exists()) {
  //     await parent.create(recursive: true);
  //   }
  //   // However, the file itself must not exist
  //   if (await file.exists()) {
  //     await file.delete();
  //   }
  //
  //   await database.customStatement('VACUUM INTO ?', [file.absolute.path]);
  // }
}
