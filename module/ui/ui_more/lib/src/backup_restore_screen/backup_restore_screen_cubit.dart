import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'backup_restore_screen_state.dart';

class BackupRestoreScreenCubit extends Cubit<BackupRestoreScreenState> {
  final AppDatabase _database;
  BackupRestoreScreenCubit({
    BackupRestoreScreenState initialState = const BackupRestoreScreenState(),
    required AppDatabase database,
  }) : _database = database,
       super(initialState);

  void init() {}

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

  // Future<void> backup() async {
  //   final dir = await FilePicker.platform.getDirectoryPath();
  //   if (dir == null) return;
  //   final parent = Directory(dir);
  //   final file = File(join(dir, 'example_backup.db'));
  //
  //   // Make sure the directory of the file exists
  //   if (!await parent.exists()) {
  //     await parent.create(recursive: true);
  //   }
  //
  //   // However, the file itself must not exist
  //   if (await file.exists()) {
  //     await file.delete();
  //   }
  //
  //   try {
  //     await _database.customStatement('VACUUM INTO ?', [file.absolute.path]);
  //   } catch (e) {
  //     print(e);
  //   }
  //
  // }

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
