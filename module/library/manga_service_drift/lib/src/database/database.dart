import 'dart:async';

import 'package:drift/drift.dart';
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
import 'adapter/backup_database/backup_database_adapter.dart'
    if (dart.library.js_interop) 'adapter/backup_database_web.dart'
    if (dart.library.io) 'adapter/backup_database_io.dart';
import 'adapter/restore_database/restore_database_adapter.dart'
    if (dart.library.js_interop) 'adapter/restore_database_web.dart'
    if (dart.library.io) 'adapter/restore_database_io.dart';
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

  Future<Uint8List> backup() {
    return backupDatabase(dbName: _executor.databaseName, database: this);
  }

  Future<void> restore({required Uint8List data}) async {
    return restoreDatabase(data: data, database: this, executor: _executor);
  }
}
