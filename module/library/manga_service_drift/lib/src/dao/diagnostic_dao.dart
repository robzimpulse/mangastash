import 'package:drift/drift.dart';

import '../database/database.dart';
import '../extension/parse_extension.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';
import '../util/typedef.dart';

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

  List<ChapterDrift> _parseOrphanChapter(List<TypedResult> result) {
    return [...result.map((e) => e.readTableOrNull(chapterTables)).nonNulls];
  }

  Stream<DuplicatedResult<MangaDrift>> get duplicateMangaStream {
    return duplicatedMangaQuery().watch().map((e) => e.parse());
  }

  Future<DuplicatedResult<MangaDrift>> get duplicateManga async {
    return duplicatedMangaQuery().get().then((e) => e.parse());
  }

  Stream<DuplicatedResult<ChapterDrift>> get duplicateChapterStream {
    return duplicatedChapterQuery().watch().map((e) => e.parse());
  }

  Future<DuplicatedResult<ChapterDrift>> get duplicateChapter {
    return duplicatedChapterQuery().get().then((e) => e.parse());
  }

  Stream<DuplicatedResult<TagDrift>> get duplicateTagStream {
    return duplicatedTagQuery().watch().map((e) => e.parse());
  }

  Future<DuplicatedResult<TagDrift>> get duplicateTag {
    return duplicatedTagQuery().get().then((e) => e.parse());
  }

  Stream<List<ChapterDrift>> get orphanChapterStream {
    return orphanChapterQuery.watch().map(_parseOrphanChapter);
  }

  Future<List<ChapterDrift>> get orphanChapter {
    return orphanChapterQuery.get().then(_parseOrphanChapter);
  }
}
