import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';

import '../drift/database/generated/schema_v2.dart' as v2;

void main() {
  group('migration v2 → v3 (#137)', () {
    test('deletes legacy orphan rows before enabling FK enforcement', () async {
      final file = File(
        '${Directory.systemTemp.createTempSync('mig_v3_').path}/legacy.sqlite',
      );

      // Legacy v2 install with dirty state: children whose parents never
      // existed or were deleted before the app-level cascades (#136).
      final legacy = v2.DatabaseAtV2(NativeDatabase(file));
      await legacy.customStatement(
        'INSERT INTO manga_tables (id, title, created_at, updated_at) '
        "VALUES ('manga_ok', 'Kept', 0, 0)",
      );
      await legacy.customStatement(
        'INSERT INTO chapter_tables (id, manga_id, title, "webUrl", '
        'created_at, updated_at) VALUES '
        "('chapter_ok', 'manga_ok', 'Kept chapter', 'https://ok/1', 0, 0), "
        "('chapter_orphan', 'manga_gone', 'Orphan chapter', "
        "'https://gone/1', 0, 0), "
        "('chapter_null_manga', NULL, 'No manga chapter', "
        "'https://null/1', 0, 0)",
      );
      await legacy.customStatement(
        'INSERT INTO image_tables (id, chapter_id, web_url, "order", '
        'created_at, updated_at) VALUES '
        "('image_ok', 'chapter_ok', 'https://ok/img', 0, 0, 0), "
        "('image_orphan', 'chapter_gone', 'https://gone/img', 0, 0, 0)",
      );
      await legacy.customStatement(
        'INSERT INTO library_tables (manga_id, created_at, updated_at) '
        "VALUES ('manga_ok', 0, 0), ('manga_gone', 0, 0)",
      );
      await legacy.customStatement(
        'INSERT INTO tag_tables (id, tag_id, name, source, created_at, '
        "updated_at) VALUES (1, 'tag_1', 'Action', 'mangadex', 0, 0)",
      );
      await legacy.customStatement(
        'INSERT INTO relationship_tables (tag_id, manga_id, created_at, '
        "updated_at) VALUES (1, 'manga_ok', 0, 0), (1, 'manga_gone', 0, 0), "
        "(999, 'manga_ok', 0, 0)",
      );

      final schemaVersionBefore = await legacy
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(schemaVersionBefore.data.values.first, 2);
      await legacy.close();

      // Open the same file with the real v3 database: runs the migration.
      final db = AppDatabase(
        executor: MemoryExecutor(executor: NativeDatabase(file)),
      );

      final chapters = await db.chapterDao.all;
      expect(
        chapters.map((e) => e.chapter?.id),
        containsAll(['chapter_ok', 'chapter_null_manga']),
      );
      expect(
        chapters.map((e) => e.chapter?.id),
        isNot(contains('chapter_orphan')),
      );

      expect(await db.imageDao.all, hasLength(1));
      expect(await db.select(db.libraryTables).get(), hasLength(1));
      expect(await db.select(db.relationshipTables).get(), hasLength(1));

      await db.close();
    });

    test('cascades manga deletion to children at the DB level', () async {
      final db = AppDatabase(executor: MemoryExecutor());

      await db.mangaDao.adds(values: {
        const MangaTablesCompanion(
          id: Value('manga_cascade'),
          title: Value('Cascade Target'),
        ): const ['Action'],
      });
      await db.chapterDao.adds(values: {
        const ChapterTablesCompanion(
          id: Value('chapter_cascade'),
          mangaId: Value('manga_cascade'),
          title: Value('Chapter'),
          webUrl: Value('https://x/1'),
        ): const ['https://x/img.png'],
      });
      await db.libraryDao.add('manga_cascade');

      // Raw delete on the parent: with PRAGMA foreign_keys = ON and the v3
      // schema, the DB itself removes the children (images included).
      await db.customStatement(
        "DELETE FROM manga_tables WHERE id = 'manga_cascade'",
      );

      expect(await db.chapterDao.all, isEmpty);
      expect(await db.imageDao.all, isEmpty);
      expect(await db.select(db.libraryTables).get(), isEmpty);

      await db.close();
    });

    test('rejects child insert with a dangling foreign key', () async {
      final db = AppDatabase(executor: MemoryExecutor());

      expect(
        db.customStatement(
          'INSERT INTO chapter_tables (id, manga_id, title, created_at, '
          "updated_at) VALUES ('chapter_bad', 'no_such_manga', 'Bad', 0, 0)",
        ),
        throwsA(anything),
      );

      await db.close();
    });
  });
}
