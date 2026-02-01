// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_dao.dart';

// ignore_for_file: type=lint
mixin _$DiagnosticDaoMixin on DatabaseAccessor<AppDatabase> {
  $MangaTablesTable get mangaTables => attachedDatabase.mangaTables;
  $TagTablesTable get tagTables => attachedDatabase.tagTables;
  $RelationshipTablesTable get relationshipTables =>
      attachedDatabase.relationshipTables;
  $ChapterTablesTable get chapterTables => attachedDatabase.chapterTables;
  $ImageTablesTable get imageTables => attachedDatabase.imageTables;
  Selectable<DuplicatedMangaQueryResult> duplicatedMangaQuery() {
    return customSelect(
      'SELECT * FROM (SELECT *, COUNT(*)OVER (PARTITION BY title, source RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS counter FROM manga_tables) WHERE counter > 1 ORDER BY title, source',
      variables: [],
      readsFrom: {mangaTables},
    ).map(
      (QueryRow row) => DuplicatedMangaQueryResult(
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
        id: row.read<String>('id'),
        title: row.readNullable<String>('title'),
        coverUrl: row.readNullable<String>('cover_url'),
        author: row.readNullable<String>('author'),
        status: row.readNullable<String>('status'),
        description: row.readNullable<String>('description'),
        webUrl: row.readNullable<String>('web_url'),
        source: row.readNullable<String>('source'),
        counter: row.read<int>('counter'),
      ),
    );
  }

  Selectable<DuplicatedTagQueryResult> duplicatedTagQuery() {
    return customSelect(
      'SELECT * FROM (SELECT *, COUNT(*)OVER (PARTITION BY name, source RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS counter FROM tag_tables) WHERE counter > 1 ORDER BY name, source',
      variables: [],
      readsFrom: {tagTables},
    ).map(
      (QueryRow row) => DuplicatedTagQueryResult(
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
        id: row.read<int>('id'),
        tagId: row.readNullable<String>('tag_id'),
        name: row.read<String>('name'),
        source: row.readNullable<String>('source'),
        counter: row.read<int>('counter'),
      ),
    );
  }

  Selectable<DuplicatedChapterQueryResult> duplicatedChapterQuery() {
    return customSelect(
      'SELECT * FROM (SELECT *, COUNT(*)OVER (PARTITION BY manga_id, chapter RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS counter FROM chapter_tables) WHERE counter > 1 ORDER BY manga_id, chapter',
      variables: [],
      readsFrom: {chapterTables},
    ).map(
      (QueryRow row) => DuplicatedChapterQueryResult(
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
        id: row.read<String>('id'),
        mangaId: row.readNullable<String>('manga_id'),
        title: row.readNullable<String>('title'),
        volume: row.readNullable<String>('volume'),
        chapter: row.readNullable<String>('chapter'),
        translatedLanguage: row.readNullable<String>('translated_language'),
        scanlationGroup: row.readNullable<String>('scanlation_group'),
        webUrl: row.readNullable<String>('webUrl'),
        readableAt: row.readNullable<DateTime>('readable_at'),
        publishAt: row.readNullable<DateTime>('publish_at'),
        lastReadAt: row.readNullable<DateTime>('last_read_at'),
        counter: row.read<int>('counter'),
      ),
    );
  }

  Selectable<ChapterGapQueryResult> chapterGapQuery() {
    return customSelect(
      'SELECT m.*, gaps.gap_starts_after, gaps.gap_ends_at,(gaps.next_val - gaps.current_val - 1)AS missing_count_estimate FROM (SELECT manga_id, chapter AS gap_starts_after, next_chapter_num AS gap_ends_at, current_val, next_val FROM (SELECT manga_id, chapter, CAST(chapter AS REAL) AS current_val, LEAD(CAST(chapter AS REAL))OVER (PARTITION BY manga_id ORDER BY CAST(chapter AS REAL) ASC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_val, LEAD(chapter)OVER (PARTITION BY manga_id ORDER BY CAST(chapter AS REAL) ASC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_chapter_num FROM chapter_tables WHERE manga_id IN (SELECT manga_id FROM library_tables)) AS sequence WHERE(next_val - current_val)> 1.1) AS gaps JOIN manga_tables AS m ON m.id = gaps.manga_id ORDER BY m.title ASC',
      variables: [],
      readsFrom: {chapterTables, mangaTables},
    ).map(
      (QueryRow row) => ChapterGapQueryResult(
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
        id: row.read<String>('id'),
        title: row.readNullable<String>('title'),
        coverUrl: row.readNullable<String>('cover_url'),
        author: row.readNullable<String>('author'),
        status: row.readNullable<String>('status'),
        description: row.readNullable<String>('description'),
        webUrl: row.readNullable<String>('web_url'),
        source: row.readNullable<String>('source'),
        gapStartsAfter: row.readNullable<String>('gap_starts_after'),
        gapEndsAt: row.readNullable<String>('gap_ends_at'),
        missingCountEstimate: row.readNullable<double>(
          'missing_count_estimate',
        ),
      ),
    );
  }

  DiagnosticDaoManager get managers => DiagnosticDaoManager(this);
}

class DiagnosticDaoManager {
  final _$DiagnosticDaoMixin _db;
  DiagnosticDaoManager(this._db);
  $$MangaTablesTableTableManager get mangaTables =>
      $$MangaTablesTableTableManager(_db.attachedDatabase, _db.mangaTables);
  $$TagTablesTableTableManager get tagTables =>
      $$TagTablesTableTableManager(_db.attachedDatabase, _db.tagTables);
  $$RelationshipTablesTableTableManager get relationshipTables =>
      $$RelationshipTablesTableTableManager(
        _db.attachedDatabase,
        _db.relationshipTables,
      );
  $$ChapterTablesTableTableManager get chapterTables =>
      $$ChapterTablesTableTableManager(_db.attachedDatabase, _db.chapterTables);
  $$ImageTablesTableTableManager get imageTables =>
      $$ImageTablesTableTableManager(_db.attachedDatabase, _db.imageTables);
}

class DuplicatedMangaQueryResult {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final String? webUrl;
  final String? source;
  final int counter;
  DuplicatedMangaQueryResult({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.webUrl,
    this.source,
    required this.counter,
  });
}

class DuplicatedTagQueryResult {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String? tagId;
  final String name;
  final String? source;
  final int counter;
  DuplicatedTagQueryResult({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.tagId,
    required this.name,
    this.source,
    required this.counter,
  });
}

class DuplicatedChapterQueryResult {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String? mangaId;
  final String? title;
  final String? volume;
  final String? chapter;
  final String? translatedLanguage;
  final String? scanlationGroup;
  final String? webUrl;
  final DateTime? readableAt;
  final DateTime? publishAt;
  final DateTime? lastReadAt;
  final int counter;
  DuplicatedChapterQueryResult({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.mangaId,
    this.title,
    this.volume,
    this.chapter,
    this.translatedLanguage,
    this.scanlationGroup,
    this.webUrl,
    this.readableAt,
    this.publishAt,
    this.lastReadAt,
    required this.counter,
  });
}

class ChapterGapQueryResult {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final String? webUrl;
  final String? source;
  final String? gapStartsAfter;
  final String? gapEndsAt;
  final double? missingCountEstimate;
  ChapterGapQueryResult({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.webUrl,
    this.source,
    this.gapStartsAfter,
    this.gapEndsAt,
    this.missingCountEstimate,
  });
}
