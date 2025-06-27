import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../dao/cache_dao.dart';
import '../dao/chapter_dao.dart';
import '../dao/history_dao.dart';
import '../dao/image_dao.dart';
import '../dao/job_dao.dart';
import '../dao/library_dao.dart';
import '../dao/manga_dao.dart';
import '../dao/tag_dao.dart';
import '../interceptor/log_interceptor.dart';
import '../tables/cache_tables.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import '../tables/job_tables.dart';
import '../tables/library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';
import '../util/job_type_enum.dart';
import '../util/typedef.dart';

import 'adapter/application_documents_directory_adapter.dart'
    if (dart.library.io) 'adapter/application_documents_directory_native.dart'
    if (dart.library.js) 'adapter/application_documents_directory_web.dart';

import 'adapter/sql_workaround_adapter.dart'
    if (dart.library.io) 'adapter/sql_workaround_native.dart'
    if (dart.library.js) 'adapter/sql_workaround_web.dart';

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
    CacheTables,
  ],
  daos: [
    MangaDao,
    ChapterDao,
    LibraryDao,
    JobDao,
    ImageDao,
    TagDao,
    CacheDao,
    HistoryDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase({
    QueryExecutor? executor,
    LoggerCallback? logger,
  }) : super(
          LazyDatabase(
            () async => (executor ?? await _openConnection(logger: logger))
                .interceptWith(LogInterceptor(logger: logger)),
          ),
        );

  @override
  int get schemaVersion => 1;

  Future<void> clear() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  }
}

Future<QueryExecutor> _openConnection({LoggerCallback? logger}) async {
  await sqlWorkaround();

  return driftDatabase(
    name: 'mangastash-local',
    native: DriftNativeOptions(
      databaseDirectory: () => applicationDocumentsDirectory().then(
        (value) {
          logger?.call('Database location: $value', name: 'AppDatabase');
          return value;
        },
      ),
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.missingFeatures.isEmpty) return;
        logger?.call(
          'Using ${result.chosenImplementation} due to unsupported '
          'browser features: ${result.missingFeatures}',
          name: 'AppDatabase',
        );
      },
    ),
  );
}
