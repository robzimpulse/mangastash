import 'package:drift/drift.dart';

import '../database/database.dart';
import '../extension/parse_extension.dart';
import '../model/diagnostic_model.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';

part 'diagnostic_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    TagTables,
    RelationshipTables,
    ChapterTables,
    ImageTables,
  ],
  queries: {
    'duplicatedMangaQuery': '''
      SELECT * FROM (
        SELECT *, COUNT(*) OVER (PARTITION BY title, source) as counter 
        FROM manga_tables
      ) 
      WHERE counter > 1
      ORDER BY title, source;
      ''',
    'duplicatedTagQuery': '''
      SELECT * FROM (
        SELECT *, COUNT(*) OVER (PARTITION BY name, source) as counter 
        FROM tag_tables
      ) 
      WHERE counter > 1
      ORDER BY name, source;
      ''',
    'duplicatedChapterQuery': '''
      SELECT * FROM (
        SELECT *, COUNT(*) OVER (PARTITION BY manga_id, chapter) as counter 
        FROM chapter_tables
      ) 
      WHERE counter > 1
      ORDER BY manga_id, chapter;
      ''',
    'chapterGapQuery': '''
      SELECT 
          m.*, 
          gaps.gap_starts_after, 
          gaps.gap_ends_at,
          (gaps.next_val - gaps.current_val - 1) AS missing_count_estimate
      FROM (
          SELECT 
              manga_id, 
              chapter AS gap_starts_after, 
              next_chapter_num AS gap_ends_at,
              current_val,
              next_val
          FROM (
              SELECT 
                  manga_id, 
                  chapter, 
                  CAST(chapter AS REAL) AS current_val,
                  LEAD(CAST(chapter AS REAL)) OVER (
                      PARTITION BY manga_id 
                      ORDER BY CAST(chapter AS REAL) ASC
                  ) AS next_val,
                  LEAD(chapter) OVER (
                      PARTITION BY manga_id 
                      ORDER BY CAST(chapter AS REAL) ASC
                  ) AS next_chapter_num
              FROM chapter_tables
          ) AS sequence
          WHERE (next_val - current_val) > 1.1
      ) AS gaps
      JOIN manga_tables m ON m.id = gaps.manga_id
      ORDER BY m.title ASC, gaps.current_val ASC;
    ''',
  },
)
class DiagnosticDao extends DatabaseAccessor<AppDatabase>
    with _$DiagnosticDaoMixin {
  DiagnosticDao(super.db);

  JoinedSelectStatement<HasResultSet, dynamic> get orphanChapterQuery {
    final selector = select(chapterTables).join([
      leftOuterJoin(
        mangaTables,
        mangaTables.id.equalsExp(chapterTables.mangaId),
      ),
    ]);

    return selector..where(mangaTables.id.isNull());
  }

  JoinedSelectStatement<HasResultSet, dynamic> get orphanImageQuery {
    final selector = select(imageTables).join([
      leftOuterJoin(
        chapterTables,
        chapterTables.id.equalsExp(imageTables.chapterId),
      ),
    ]);

    return selector..where(chapterTables.id.isNull());
  }

  List<ChapterDrift> _parseOrphanChapter(List<TypedResult> result) {
    return [...result.map((e) => e.readTableOrNull(chapterTables)).nonNulls];
  }

  List<ImageDrift> _parseOrphanImage(List<TypedResult> result) {
    return [...result.map((e) => e.readTableOrNull(imageTables)).nonNulls];
  }

  Stream<Map<DuplicatedMangaKey, List<MangaDrift>>> get duplicateMangaStream {
    return duplicatedMangaQuery().watch().map((e) => e.parse());
  }

  Future<Map<DuplicatedMangaKey, List<MangaDrift>>> get duplicateManga async {
    return duplicatedMangaQuery().get().then((e) => e.parse());
  }

  Stream<Map<DuplicatedChapterKey, List<ChapterDrift>>>
  get duplicateChapterStream {
    return duplicatedChapterQuery().watch().map((e) => e.parse());
  }

  Future<Map<DuplicatedChapterKey, List<ChapterDrift>>> get duplicateChapter {
    return duplicatedChapterQuery().get().then((e) => e.parse());
  }

  Stream<Map<DuplicatedTagKey, List<TagDrift>>> get duplicateTagStream {
    return duplicatedTagQuery().watch().map((e) => e.parse());
  }

  Future<Map<DuplicatedTagKey, List<TagDrift>>> get duplicateTag {
    return duplicatedTagQuery().get().then((e) => e.parse());
  }

  Stream<List<ChapterDrift>> get orphanChapterStream {
    return orphanChapterQuery.watch().map(_parseOrphanChapter);
  }

  Future<List<ChapterDrift>> get orphanChapter {
    return orphanChapterQuery.get().then(_parseOrphanChapter);
  }

  Stream<List<ImageDrift>> get orphanImageStream {
    return orphanChapterQuery.watch().map(_parseOrphanImage);
  }

  Future<List<ImageDrift>> get orphanImage {
    return orphanChapterQuery.get().then(_parseOrphanImage);
  }

  Stream<List<IncompleteManga>> get chapterGapStream {
    return chapterGapQuery().watch().map((e) => e.parse());
  }

  Future<List<IncompleteManga>> get chapterGap {
    return chapterGapQuery().get().then((e) => e.parse());
  }
}
