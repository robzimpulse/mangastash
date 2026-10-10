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
  int get schemaVersion => 6;

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
          // Delete first: 'persistentImage' is no longer a `JobTypeEnum`
          // value, and a surviving row is NOT skippable. The generated
          // `$JobTablesTable.map` converts `type` through
          // `EnumNameConverter(JobTypeEnum.values)`, whose `fromSql` is
          // `values.byName(...)` — it THROWS on an unknown stored name, and it
          // throws while a joined query maps its rows, before `JobDao._parse`
          // sees one: `_parse`'s `firstWhereOrNull` guard is dead code for an
          // unknown name, not the safety net it looks like. Every joined read
          // that maps the row then errors out (the three list streams map all
          // rows, `single` its `limit(1)` head) and `JobManager` consumes
          // `single` with no `onError` on that path, so it escapes as an
          // unhandled async error every time the query re-runs. The row can
          // never become a `JobModel`, so the `finally` calling `JobDao.remove`
          // never runs and nothing else will ever drain it.
          await customStatement(
            "DELETE FROM job_tables WHERE type = 'persistentImage'",
          );
          await m.dropColumn(jobTables, 'path');
        },
        from4To5: (m, schema) async {
          // v5 (issue #131): persist artist credits and index the hot
          // join/filter paths. `m.addColumn` works here (unlike the
          // historical v1→v2 `path` case) because `artist` exists in the
          // live Dart table definition. The index SQL must stay
          // byte-identical to what drift generates for the @TableIndex
          // annotations — migrateAndValidate compares schema entities.
          await m.addColumn(mangaTables, mangaTables.artist);
          await m.createIndex(
            Index(
              'idx_relationship_manga_id',
              'CREATE INDEX idx_relationship_manga_id ON '
              'relationship_tables (manga_id)',
            ),
          );
          await m.createIndex(
            Index(
              'idx_job_chapter_id',
              'CREATE INDEX idx_job_chapter_id ON job_tables (chapter_id)',
            ),
          );
          await m.createIndex(
            Index(
              'idx_job_manga_id',
              'CREATE INDEX idx_job_manga_id ON job_tables (manga_id)',
            ),
          );
        },
        from5To6: (m, schema) async {
          // v6: tag uniqueness is per source. v5's global (tag_id, name)
          // key collided across scraped sources sharing genre slugs, and
          // TagDao's DO UPDATE upsert then rewrote the other source's row
          // to its own source ("stolen" rows). Steps run in this order:
          // dedupe (so the rebuild's new keys hold), rebuild, repair the
          // stolen rows' links, then invalidate scraped tag caches.

          // 1. Merge rows that v5 allowed but v6 keys reject (NULL tag_id
          // escaped v5's key; same slug with different names too) into the
          // lowest id of each group, moving their manga links first.
          for (final key in const ['name', 'tag_id']) {
            const dup = 'd.id > (SELECT MIN(k.id) FROM tag_tables k '
                'WHERE k.source = d.source AND k.{key} = d.{key})';
            await customStatement(
              'INSERT OR IGNORE INTO relationship_tables '
              '(created_at, updated_at, tag_id, manga_id) '
              'SELECT r.created_at, r.updated_at, '
              '(SELECT MIN(k.id) FROM tag_tables k WHERE '
              'k.source = d.source AND k.$key = d.$key), r.manga_id '
              'FROM relationship_tables r '
              'JOIN tag_tables d ON d.id = r.tag_id '
              'WHERE ${dup.replaceAll('{key}', key)}',
            );
            await customStatement(
              'DELETE FROM tag_tables AS d '
              'WHERE ${dup.replaceAll('{key}', key)}',
            );
          }
          // FK enforcement may be off during migration (no cascade).
          await customStatement(
            'DELETE FROM relationship_tables WHERE tag_id NOT IN '
            '(SELECT id FROM tag_tables)',
          );

          // 2. SQLite cannot drop a table-level UNIQUE: rebuild the table.
          // Row ids are copied, so relationship_tables stays valid.
          await m.alterTable(TableMigration(tagTables));

          // 3. A stolen row is linked to manga of a different source than
          // its own. Recreate the tag under the manga's source and move
          // those links onto it. Tag and manga source are always equal
          // for honest links (MangaDao.reattach passes the manga source).
          const links = 'FROM relationship_tables r '
              'JOIN tag_tables t ON t.id = r.tag_id '
              'JOIN manga_tables m ON m.id = r.manga_id';
          const mismatch = '$links '
              'WHERE m.source IS NOT NULL AND t.source IS NOT NULL '
              'AND m.source <> t.source';
          await customStatement(
            'INSERT OR IGNORE INTO tag_tables '
            '(created_at, updated_at, name, source) '
            'SELECT MIN(t.created_at), MAX(t.updated_at), t.name, m.source '
            '$mismatch GROUP BY t.name, m.source',
          );
          await customStatement(
            'INSERT OR IGNORE INTO relationship_tables '
            '(created_at, updated_at, tag_id, manga_id) '
            'SELECT r.created_at, r.updated_at, n.id, r.manga_id $links '
            'JOIN tag_tables n ON n.source = m.source AND n.name = t.name '
            'WHERE m.source <> t.source',
          );
          await customStatement(
            'DELETE FROM relationship_tables WHERE rowid IN '
            '(SELECT r.rowid $mismatch)',
          );

          // 4. A source whose row was stolen has an incomplete cached genre
          // list, and which source lost rows is unknowable. Drop unlinked
          // scraped tags and clear scraped tag ids: GetTagsUseCase treats a
          // cache without tag ids as a miss and re-scrapes, and TagDao.adds
          // re-attaches the slugs by name, keeping every manga link.
          // 'Manga Dex' (MangaDexSourceExternal.name) is skipped: its ids
          // are API UUIDs that never collided.
          const scraped = "source IS NOT NULL AND source <> 'Manga Dex'";
          await customStatement(
            'DELETE FROM tag_tables WHERE $scraped AND id NOT IN '
            '(SELECT tag_id FROM relationship_tables)',
          );
          await customStatement(
            'UPDATE tag_tables SET tag_id = NULL WHERE $scraped',
          );
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
