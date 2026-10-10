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
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;

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
            // Start from a real old-version database — a fresh AppDatabase
            // would run onCreate at the latest schema instead.
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(
              executor: MemoryExecutor(executor: schema.newConnection()),
            );
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
  // Issue #131: the generated placeholder was unfilled — the test inserted
  // and validated nothing, so the v1→v2 step (ALTER TABLE job_tables ADD
  // COLUMN path) had no real data coverage. One referentially-consistent
  // row per table; every row must survive, and the job row gains path=null.
  test('migration from v1 to v2 does not corrupt data', () async {
    final oldImageTablesData = [
      v1.ImageTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 'image_1',
        order: 0,
        chapterId: 'chapter_1',
        webUrl: 'https://example.com/image_1.jpg',
      ),
    ];
    final expectedNewImageTablesData = [
      v2.ImageTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 'image_1',
        order: 0,
        chapterId: 'chapter_1',
        webUrl: 'https://example.com/image_1.jpg',
      ),
    ];

    final oldChapterTablesData = [
      v1.ChapterTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 'chapter_1',
        mangaId: 'manga_1',
        title: 'Chapter 1',
        volume: '1',
        chapter: '1',
        translatedLanguage: 'en',
        scanlationGroup: null,
        webUrl: 'https://example.com/chapter_1',
        readableAt: 1000,
        publishAt: 1000,
        lastReadAt: null,
      ),
    ];
    final expectedNewChapterTablesData = [
      v2.ChapterTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 'chapter_1',
        mangaId: 'manga_1',
        title: 'Chapter 1',
        volume: '1',
        chapter: '1',
        translatedLanguage: 'en',
        scanlationGroup: null,
        webUrl: 'https://example.com/chapter_1',
        readableAt: 1000,
        publishAt: 1000,
        lastReadAt: null,
      ),
    ];

    final oldLibraryTablesData = [
      v1.LibraryTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        mangaId: 'manga_1',
      ),
    ];
    final expectedNewLibraryTablesData = [
      v2.LibraryTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        mangaId: 'manga_1',
      ),
    ];

    final oldMangaTablesData = [
      v1.MangaTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 'manga_1',
        title: 'Manga 1',
        coverUrl: 'https://example.com/cover_1.jpg',
        author: 'Author 1',
        status: 'ongoing',
        description: 'Description 1',
        webUrl: 'https://example.com/manga_1',
        source: 'mangadex',
      ),
    ];
    final expectedNewMangaTablesData = [
      v2.MangaTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 'manga_1',
        title: 'Manga 1',
        coverUrl: 'https://example.com/cover_1.jpg',
        author: 'Author 1',
        status: 'ongoing',
        description: 'Description 1',
        webUrl: 'https://example.com/manga_1',
        source: 'mangadex',
      ),
    ];

    final oldTagTablesData = [
      v1.TagTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 1,
        tagId: 'tag_1',
        name: 'Action',
        source: 'mangadex',
      ),
    ];
    final expectedNewTagTablesData = [
      v2.TagTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 1,
        tagId: 'tag_1',
        name: 'Action',
        source: 'mangadex',
      ),
    ];

    final oldRelationshipTablesData = [
      v1.RelationshipTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        tagId: 1,
        mangaId: 'manga_1',
      ),
    ];
    final expectedNewRelationshipTablesData = [
      v2.RelationshipTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        tagId: 1,
        mangaId: 'manga_1',
      ),
    ];

    final oldJobTablesData = [
      v1.JobTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 1,
        type: 'prefetchImage',
        source: 'mangadex',
        chapterId: 'chapter_1',
        mangaId: 'manga_1',
        imageUrl: 'https://example.com/image_1.jpg',
      ),
    ];
    final expectedNewJobTablesData = [
      v2.JobTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 1,
        type: 'prefetchImage',
        source: 'mangadex',
        chapterId: 'chapter_1',
        mangaId: 'manga_1',
        imageUrl: 'https://example.com/image_1.jpg',
        // The v1→v2 step ALTERs job_tables to add `path`; existing rows
        // must come back with it null.
        path: null,
      ),
    ];

    final oldFileTablesData = [
      v1.FileTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 'file_1',
        webUrl: 'https://example.com/image_1.jpg',
        relativePath: 'file_1.jpg',
      ),
    ];
    final expectedNewFileTablesData = [
      v2.FileTablesData(
        createdAt: 1000,
        updatedAt: 1000,
        id: 'file_1',
        webUrl: 'https://example.com/image_1.jpg',
        relativePath: 'file_1.jpg',
      ),
    ];

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

  test('v3 to v4 deletes legacy persistentImage rows and drops path', () async {
    // The legacy rows can only be seeded with raw SQL: v4 drops `path`, so
    // the current `JobTablesCompanion` can no longer carry the value that
    // distinguishes a legacy row. `customInsert` returns the new rowid, which
    // is how the surviving job is identified after the migration.
    final schema = await verifier.schemaAt(3);
    final legacyDb = v3.DatabaseAtV3(schema.newConnection());
    await legacyDb.customStatement(
      'INSERT INTO job_tables (type, image_url, path, created_at, '
      "updated_at) VALUES ('persistentImage', 'https://example.com/a.jpg', "
      "'staging/a.jpg', 0, 0)",
    );
    final prefetchId = await legacyDb.customInsert(
      'INSERT INTO job_tables (type, image_url, created_at, updated_at) '
      "VALUES ('prefetchImage', 'https://example.com/b.jpg', 0, 0)",
    );
    await legacyDb.close();

    final db = AppDatabase(
      executor: MemoryExecutor(executor: schema.newConnection()),
    );
    await verifier.migrateAndValidate(db, 4);

    // The legacy type has to be compared as the raw string SQLite holds, read
    // with raw SQL rather than through `JobTables.type`: that column is typed
    // `JobTypeEnum`, and v4 removes `persistentImage` from the enum, so a
    // surviving row would make the typed read below throw on
    // `EnumNameConverter`'s `values.byName(...)` rather than yield a value to
    // compare — asserting on the enum would be tautological. The name being
    // un-representable is the point: it is why the migration deletes the rows
    // outright instead of leaving `JobDao._parse` to skip them.
    final types = await db
        .customSelect('SELECT type FROM job_tables', readsFrom: {db.jobTables})
        .get();
    expect(types.map((e) => e.read<String>('type')), ['prefetchImage']);

    final remaining = await db.select(db.jobTables).get();
    expect(remaining.map((e) => e.id), contains(prefetchId));
    expect(db.jobTables.$columns.map((e) => e.name), isNot(contains('path')));

    await db.close();
  });

  // Issue #131: v5 adds manga_tables.artist (nullable) and the three
  // secondary indices. Rows must survive with artist null; the indices are
  // validated by migrateAndValidate against the v5 schema.
  test('v4 to v5 preserves rows and adds a nullable artist column', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: 5,
      createOld: v4.DatabaseAtV4.new,
      createNew: v5.DatabaseAtV5.new,
      openTestedDatabase: (executor) {
        return AppDatabase(executor: MemoryExecutor(executor: executor));
      },
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.mangaTables, [
          v4.MangaTablesData(
            createdAt: 1000,
            updatedAt: 1000,
            id: 'manga_1',
            title: 'Manga 1',
            coverUrl: 'https://example.com/cover_1.jpg',
            author: 'Author 1',
            status: 'ongoing',
            description: 'Description 1',
            webUrl: 'https://example.com/manga_1',
            source: 'mangadex',
          ),
        ]);
        batch.insertAll(oldDb.chapterTables, [
          v4.ChapterTablesData(
            createdAt: 1000,
            updatedAt: 1000,
            id: 'chapter_1',
            mangaId: 'manga_1',
            title: 'Chapter 1',
            volume: '1',
            chapter: '1',
            translatedLanguage: 'en',
            scanlationGroup: null,
            webUrl: 'https://example.com/chapter_1',
            readableAt: 1000,
            publishAt: 1000,
            lastReadAt: null,
          ),
        ]);
        batch.insertAll(oldDb.jobTables, [
          v4.JobTablesData(
            createdAt: 1000,
            updatedAt: 1000,
            id: 1,
            type: 'prefetchImage',
            source: 'mangadex',
            chapterId: 'chapter_1',
            mangaId: 'manga_1',
            imageUrl: 'https://example.com/image_1.jpg',
          ),
        ]);
      },
      validateItems: (newDb) async {
        final mangas = await newDb.select(newDb.mangaTables).get();
        expect(mangas, hasLength(1));
        // The column is added nullable: pre-v5 rows have no artist.
        expect(mangas.single.artist, null);
        expect(mangas.single.author, 'Author 1');

        expect(await newDb.select(newDb.chapterTables).get(), hasLength(1));
        expect(await newDb.select(newDb.jobTables).get(), hasLength(1));
      },
    );
  });

  // v6 scopes tag uniqueness per source. Under v5's global (tag_id, name)
  // key, a second source upserting ('action', 'Action') rewrote the first
  // source's row to its own source ("stolen" row) — so v6 also repairs
  // links and invalidates scraped tag caches, without losing a genre link.
  test('v5 to v6 rebuilds tag keys per source and repairs stolen tags', () async {
    const katana = 'Manga Katana';
    const asura = 'Asura Scans';
    const dex = 'Manga Dex';
    const uuidAction = '391b0423-d847-456f-aff0-8b0cfc03066b';
    const uuidDrama = 'b9af3a63-f058-46de-a9a0-e0c13906197a';

    await verifier.testWithDataIntegrity(
      oldVersion: 5,
      newVersion: 6,
      createOld: v5.DatabaseAtV5.new,
      createNew: v6.DatabaseAtV6.new,
      openTestedDatabase: (executor) {
        return AppDatabase(executor: MemoryExecutor(executor: executor));
      },
      createItems: (batch, oldDb) {
        v5.MangaTablesData manga(String id, String source) {
          return v5.MangaTablesData(
            createdAt: 1000,
            updatedAt: 1000,
            id: id,
            webUrl: 'https://example.com/$id',
            source: source,
          );
        }

        v5.TagTablesData tag(int id, String? tagId, String name, String src) {
          return v5.TagTablesData(
            createdAt: 1000,
            updatedAt: 1000,
            id: id,
            tagId: tagId,
            name: name,
            source: src,
          );
        }

        v5.RelationshipTablesData link(int tagId, String mangaId) {
          return v5.RelationshipTablesData(
            createdAt: 1000,
            updatedAt: 1000,
            tagId: tagId,
            mangaId: mangaId,
          );
        }

        batch.insertAll(oldDb.mangaTables, [
          manga('mk1', katana),
          manga('as1', asura),
          manga('md1', dex),
        ]);
        batch.insertAll(oldDb.tagTables, [
          // Katana's row, rewritten to Asura by the v5 upsert.
          tag(1, 'action', 'Action', asura),
          tag(2, null, 'Romance', katana),
          // Unreferenced genre-list cache row.
          tag(3, 'comedy', 'Comedy', katana),
          tag(4, uuidAction, 'Action', dex),
          tag(5, uuidDrama, 'Drama', dex),
          // NULL tag_id escaped v5's key: duplicate of 2 by (source, name).
          tag(6, null, 'Romance', katana),
          // Different names escaped v5's key: duplicates by (source, tag_id).
          tag(7, 'drama', 'Drama', asura),
          tag(8, 'drama', 'Dramas', asura),
        ]);
        batch.insertAll(oldDb.relationshipTables, [
          link(1, 'mk1'),
          link(1, 'as1'),
          link(2, 'mk1'),
          link(4, 'md1'),
          link(6, 'mk1'),
          link(8, 'as1'),
        ]);
      },
      validateItems: (newDb) async {
        final tags = await newDb.select(newDb.tagTables).get();
        final byId = {for (final t in tags) t.id: t};

        // Duplicates merged into the lowest id; the unreferenced scraped
        // row is dropped; a fresh Katana 'Action' row replaces the stolen one.
        expect(
          tags.map((e) => (e.name, e.source)),
          unorderedEquals([
            ('Action', asura),
            ('Romance', katana),
            ('Action', dex),
            ('Drama', dex),
            ('Drama', asura),
            ('Action', katana),
          ]),
        );
        expect(byId.keys, containsAll([1, 2, 4, 5, 7]));

        // Scraped tag ids are cleared so GetTagsUseCase re-scrapes the
        // genre lists (one may be missing rows lost to the old upsert).
        final scraped = tags.where((e) => e.source != dex);
        expect(scraped.map((e) => e.tagId).toSet(), {null});
        expect(byId[4]?.tagId, uuidAction);
        expect(byId[5]?.tagId, uuidDrama);

        final katanaAction = tags.singleWhere(
          (e) => e.name == 'Action' && e.source == katana,
        );
        final links = await newDb.select(newDb.relationshipTables).get();
        expect(
          links.map((e) => (e.tagId, e.mangaId)),
          unorderedEquals([
            (katanaAction.id, 'mk1'),
            (1, 'as1'),
            (2, 'mk1'),
            (4, 'md1'),
            (7, 'as1'),
          ]),
        );
      },
    );
  });
}
