import 'dart:async';

import 'package:drift/drift.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/universal_io.dart';
import 'package:uuid/uuid.dart';

import '../dao/chapter_dao.dart';
import '../dao/history_dao.dart';
import '../dao/image_dao.dart';
import '../dao/job_dao.dart';
import '../dao/library_dao.dart';
import '../dao/manga_dao.dart';
import '../dao/tag_dao.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import '../tables/job_tables.dart';
import '../tables/library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';
import '../util/job_type_enum.dart';
import 'adapter/restore_database_unsupported.dart'
    if (dart.library.ffi) 'adapter/restore_database_supported.dart';
import 'executor.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    ImageTables,
    ChapterTables,
    LibraryTables,
    MangaTables,
    TagTables,
    RelationshipTables,
    JobTables,
  ],
  daos: [
    MangaDao,
    ChapterDao,
    LibraryDao,
    JobDao,
    ImageDao,
    TagDao,
    HistoryDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  final Executor _executor;

  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase({required Executor executor})
    : _executor = executor,
      super(executor.build());

  @override
  int get schemaVersion => 1;

  Future<void> clear() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  }

  // Example: https://github.com/simolus3/drift/blob/96b3947fc16de99ffe25bcabc124e3b3a7c69571/examples/app/lib/screens/backup/supported.dart#L47-L68
  Future<File> backup({Directory? directory, String? filename}) async {
    final dir = directory ?? await getTemporaryDirectory();
    final timestamp = DateTime.timestamp().microsecondsSinceEpoch;
    final name = filename ?? '$timestamp.sqlite';
    final file = File(join(dir.path, name));

    // Make sure the directory of the file exists
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // However, the file itself must not exist
    if (await file.exists()) {
      await file.delete();
    }

    await customStatement('VACUUM INTO ?', [file.absolute.path]);

    return file;
  }

  Future<void> restore({required File file}) async {
    await restoreDatabase(file: file, database: this, executor: _executor);
  }
}
