import 'dart:async';

import 'package:drift/drift.dart';
import 'package:file/file.dart';
import 'package:uuid/uuid.dart';

import '../dao/chapter_dao.dart';
import '../dao/file_dao.dart';
import '../dao/history_dao.dart';
import '../dao/image_dao.dart';
import '../dao/job_dao.dart';
import '../dao/library_dao.dart';
import '../dao/manga_dao.dart';
import '../dao/tag_dao.dart';
import '../tables/chapter_tables.dart';
import '../tables/file_tables.dart';
import '../tables/image_tables.dart';
import '../tables/job_tables.dart';
import '../tables/library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';
import '../util/job_type_enum.dart';
import 'adapter/backup_database/backup_database_adapter.dart'
    if (dart.library.js_interop) 'adapter/backup_database/backup_database_web.dart'
    if (dart.library.io) 'adapter/backup_database/backup_database_io.dart';
import 'adapter/restore_database/restore_database_adapter.dart'
    if (dart.library.js_interop) 'adapter/restore_database/restore_database_web.dart'
    if (dart.library.io) 'adapter/restore_database/restore_database_io.dart';
import 'database.steps.dart';
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
    FileTables,
  ],
  daos: [
    MangaDao,
    ChapterDao,
    LibraryDao,
    JobDao,
    ImageDao,
    TagDao,
    HistoryDao,
    FileDao,
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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // FK enforcement is per-connection in SQLite (off by default).
        // Both the IO and web executors go through this hook.
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: stepByStep(
        from1To2: (m, schema) async {
          // Historical: `path` was added in v2 and dropped again in v4, so
          // this step still has to create it for real v1 installs (from3To4
          // removes it again). The column is gone from the Dart table, so
          // `m.addColumn` — which needs the live definition — cannot be used.
          await customStatement(
            'ALTER TABLE job_tables ADD COLUMN path TEXT NULL',
          );
        },
        from2To3: (m, schema) async {
          // Legacy installs may hold rows whose parent was deleted before
          // #136's app-level cascades existed; enabling FK enforcement on
          // dirty data would turn routine deletes into constraint errors.
          // Chapters are removed FIRST so the image pass also catches
          // images of chapters deleted here (images-first would strand
          // them — unreachable by any cascade once their parent is gone).
          await customStatement(
            'DELETE FROM chapter_tables WHERE manga_id IS NOT NULL AND '
            'manga_id NOT IN (SELECT id FROM manga_tables)',
          );
          await customStatement(
            'DELETE FROM image_tables WHERE chapter_id NOT IN '
            '(SELECT id FROM chapter_tables)',
          );
          await customStatement(
            'DELETE FROM library_tables WHERE manga_id NOT IN '
            '(SELECT id FROM manga_tables)',
          );
          await customStatement(
            'DELETE FROM relationship_tables WHERE manga_id NOT IN '
            '(SELECT id FROM manga_tables) OR tag_id NOT IN '
            '(SELECT id FROM tag_tables)',
          );

          // SQLite cannot ALTER-add FK constraints: recreate each child
          // table from the v3 definitions (alterTable with an empty
          // TableMigration copies rows into the rebuilt table).
          await m.alterTable(TableMigration(chapterTables));
          await m.alterTable(TableMigration(imageTables));
          await m.alterTable(TableMigration(libraryTables));
          await m.alterTable(TableMigration(relationshipTables));
        },
        from3To4: (m, schema) async {
          // Delete first: JobDao._parse skips rows whose type has no enum
          // value, so a surviving persistentImage row would wedge `single`
          // on an unparsable head row that nothing ever removes.
          await customStatement(
            "DELETE FROM job_tables WHERE type = 'persistentImage'",
          );
          await m.dropColumn(jobTables, 'path');
        },
      ),
    );
  }

  Future<void> clear() {
    return transaction(() async {
      await batch((batch) {
        for (final table in allTables) {
          batch.deleteAll(table);
        }
      });
    });
  }

  Future<Uint8List> backup() {
    return backupDatabase(dbName: _executor.databaseName, database: this);
  }

  Future<void> restore({required Uint8List data}) async {
    return restoreDatabase(data: data, database: this, executor: _executor);
  }

  Future<Directory> databaseDirectory() => _executor.databaseDirectory();
}
