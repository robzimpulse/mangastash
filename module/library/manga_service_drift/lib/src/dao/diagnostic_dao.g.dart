// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_dao.dart';

// ignore_for_file: type=lint
mixin _$DiagnosticDaoMixin on DatabaseAccessor<AppDatabase> {
  $LibraryTablesTable get libraryTables => attachedDatabase.libraryTables;
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
      'SELECT m.id AS manga_id, m.title AS manga_title, m.source AS manga_source, m.web_url AS manga_web_url, m.author AS manga_author, m.cover_url AS manga_cover_url, m.status AS manga_status, m.description AS manga_description, m.created_at AS manga_created_at, m.updated_at AS manga_updated_at, dupes.id AS chapter_id, dupes.chapter AS chapter_number, dupes.title AS chapter_title, dupes.webUrl AS chapter_web_url, dupes.created_at AS chapter_created_at, dupes.updated_at AS chapter_updated_at, dupes.readable_at AS chapter_readable_at, dupes.publish_at AS chapter_publish_at, dupes.last_read_at AS chapter_last_read_at, dupes.volume AS chapter_volume, dupes.translated_language AS chapter_translated_language, dupes.scanlation_group AS chapter_scanlation_group, dupes.counter AS total_duplicates_found FROM (SELECT *, COUNT(*)OVER (PARTITION BY manga_id, chapter RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS counter FROM chapter_tables) AS dupes JOIN manga_tables AS m ON m.id = dupes.manga_id WHERE dupes.counter > 1 ORDER BY m.source, m.title, CAST(dupes.chapter AS REAL), dupes.created_at DESC',
      variables: [],
      readsFrom: {mangaTables, chapterTables},
    ).map(
      (QueryRow row) => DuplicatedChapterQueryResult(
        mangaId: row.read<String>('manga_id'),
        mangaTitle: row.readNullable<String>('manga_title'),
        mangaSource: row.readNullable<String>('manga_source'),
        mangaWebUrl: row.readNullable<String>('manga_web_url'),
        mangaAuthor: row.readNullable<String>('manga_author'),
        mangaCoverUrl: row.readNullable<String>('manga_cover_url'),
        mangaStatus: row.readNullable<String>('manga_status'),
        mangaDescription: row.readNullable<String>('manga_description'),
        mangaCreatedAt: row.read<DateTime>('manga_created_at'),
        mangaUpdatedAt: row.read<DateTime>('manga_updated_at'),
        chapterId: row.read<String>('chapter_id'),
        chapterNumber: row.readNullable<String>('chapter_number'),
        chapterTitle: row.readNullable<String>('chapter_title'),
        chapterWebUrl: row.readNullable<String>('chapter_web_url'),
        chapterCreatedAt: row.read<DateTime>('chapter_created_at'),
        chapterUpdatedAt: row.read<DateTime>('chapter_updated_at'),
        chapterReadableAt: row.readNullable<DateTime>('chapter_readable_at'),
        chapterPublishAt: row.readNullable<DateTime>('chapter_publish_at'),
        chapterLastReadAt: row.readNullable<DateTime>('chapter_last_read_at'),
        chapterVolume: row.readNullable<String>('chapter_volume'),
        chapterTranslatedLanguage: row.readNullable<String>(
          'chapter_translated_language',
        ),
        chapterScanlationGroup: row.readNullable<String>(
          'chapter_scanlation_group',
        ),
        totalDuplicatesFound: row.read<int>('total_duplicates_found'),
      ),
    );
  }

  Selectable<ChapterGapQueryResult> chapterGapQuery() {
    return customSelect(
      'SELECT m.*, gaps.gap_starts_after, gaps.gap_ends_at,(gaps.next_val - gaps.current_val - 1)AS missing_count_estimate FROM (SELECT manga_id, chapter AS gap_starts_after, next_chapter_num AS gap_ends_at, current_val, next_val FROM (SELECT manga_id, chapter, CAST(chapter AS REAL) AS current_val, LEAD(CAST(chapter AS REAL))OVER (PARTITION BY manga_id ORDER BY CAST(chapter AS REAL) ASC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_val, LEAD(chapter)OVER (PARTITION BY manga_id ORDER BY CAST(chapter AS REAL) ASC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_chapter_num FROM chapter_tables WHERE manga_id IN (SELECT manga_id FROM library_tables)) AS sequence WHERE(next_val - current_val)> 1.1) AS gaps JOIN manga_tables AS m ON m.id = gaps.manga_id ORDER BY m.title ASC',
      variables: [],
      readsFrom: {chapterTables, libraryTables, mangaTables},
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
  $$LibraryTablesTableTableManager get libraryTables =>
      $$LibraryTablesTableTableManager(_db.attachedDatabase, _db.libraryTables);
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
  final String mangaId;
  final String? mangaTitle;
  final String? mangaSource;
  final String? mangaWebUrl;
  final String? mangaAuthor;
  final String? mangaCoverUrl;
  final String? mangaStatus;
  final String? mangaDescription;
  final DateTime mangaCreatedAt;
  final DateTime mangaUpdatedAt;
  final String chapterId;
  final String? chapterNumber;
  final String? chapterTitle;
  final String? chapterWebUrl;
  final DateTime chapterCreatedAt;
  final DateTime chapterUpdatedAt;
  final DateTime? chapterReadableAt;
  final DateTime? chapterPublishAt;
  final DateTime? chapterLastReadAt;
  final String? chapterVolume;
  final String? chapterTranslatedLanguage;
  final String? chapterScanlationGroup;
  final int totalDuplicatesFound;
  DuplicatedChapterQueryResult({
    required this.mangaId,
    this.mangaTitle,
    this.mangaSource,
    this.mangaWebUrl,
    this.mangaAuthor,
    this.mangaCoverUrl,
    this.mangaStatus,
    this.mangaDescription,
    required this.mangaCreatedAt,
    required this.mangaUpdatedAt,
    required this.chapterId,
    this.chapterNumber,
    this.chapterTitle,
    this.chapterWebUrl,
    required this.chapterCreatedAt,
    required this.chapterUpdatedAt,
    this.chapterReadableAt,
    this.chapterPublishAt,
    this.chapterLastReadAt,
    this.chapterVolume,
    this.chapterTranslatedLanguage,
    this.chapterScanlationGroup,
    required this.totalDuplicatesFound,
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
