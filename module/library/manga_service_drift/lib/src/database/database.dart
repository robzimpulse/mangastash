import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../dao/chapter_dao.dart';
import '../dao/history_dao.dart';
import '../dao/image_dao.dart';
import '../dao/job_dao.dart';
import '../dao/library_dao.dart';
import '../dao/manga_dao.dart';
import '../dao/tag_dao.dart';
import '../interceptor/log_interceptor.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import '../tables/job_tables.dart';
import '../tables/library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';
import '../util/job_type_enum.dart';
import '../util/typedef.dart';

import 'adapter/sql_workaround_adapter.dart'
    if (dart.library.io) 'adapter/sql_workaround_native.dart'
    if (dart.library.js) 'adapter/sql_workaround_web.dart';
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
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase({QueryExecutor? executor, LoggerCallback? logger})
    : super(executor ?? Executor.create(logger: logger));

  @override
  int get schemaVersion => 1;

  Future<void> clear() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  }
}
