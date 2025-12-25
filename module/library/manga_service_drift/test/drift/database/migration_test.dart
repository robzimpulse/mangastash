// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/database/database.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(executor: MemoryExecutor());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldImageTablesData = <v1.ImageTablesData>[];
    final expectedNewImageTablesData = <v2.ImageTablesData>[];

    final oldChapterTablesData = <v1.ChapterTablesData>[];
    final expectedNewChapterTablesData = <v2.ChapterTablesData>[];

    final oldLibraryTablesData = <v1.LibraryTablesData>[];
    final expectedNewLibraryTablesData = <v2.LibraryTablesData>[];

    final oldMangaTablesData = <v1.MangaTablesData>[];
    final expectedNewMangaTablesData = <v2.MangaTablesData>[];

    final oldTagTablesData = <v1.TagTablesData>[];
    final expectedNewTagTablesData = <v2.TagTablesData>[];

    final oldRelationshipTablesData = <v1.RelationshipTablesData>[];
    final expectedNewRelationshipTablesData = <v2.RelationshipTablesData>[];

    final oldJobTablesData = <v1.JobTablesData>[];
    final expectedNewJobTablesData = <v2.JobTablesData>[];

    final oldFileTablesData = <v1.FileTablesData>[];
    final expectedNewFileTablesData = <v2.FileTablesData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: (executor) {
        return AppDatabase(executor: MemoryExecutor(executor: executor));
      },
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.imageTables, oldImageTablesData);
        batch.insertAll(oldDb.chapterTables, oldChapterTablesData);
        batch.insertAll(oldDb.libraryTables, oldLibraryTablesData);
        batch.insertAll(oldDb.mangaTables, oldMangaTablesData);
        batch.insertAll(oldDb.tagTables, oldTagTablesData);
        batch.insertAll(oldDb.relationshipTables, oldRelationshipTablesData);
        batch.insertAll(oldDb.jobTables, oldJobTablesData);
        batch.insertAll(oldDb.fileTables, oldFileTablesData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewImageTablesData,
          await newDb.select(newDb.imageTables).get(),
        );
        expect(
          expectedNewChapterTablesData,
          await newDb.select(newDb.chapterTables).get(),
        );
        expect(
          expectedNewLibraryTablesData,
          await newDb.select(newDb.libraryTables).get(),
        );
        expect(
          expectedNewMangaTablesData,
          await newDb.select(newDb.mangaTables).get(),
        );
        expect(
          expectedNewTagTablesData,
          await newDb.select(newDb.tagTables).get(),
        );
        expect(
          expectedNewRelationshipTablesData,
          await newDb.select(newDb.relationshipTables).get(),
        );
        expect(
          expectedNewJobTablesData,
          await newDb.select(newDb.jobTables).get(),
        );
        expect(
          expectedNewFileTablesData,
          await newDb.select(newDb.fileTables).get(),
        );
      },
    );
  });
}
