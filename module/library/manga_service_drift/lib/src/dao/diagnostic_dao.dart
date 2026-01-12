import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
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

  Stream<DuplicatedMangaResult> get duplicateManga {
    final result = duplicatedMangaQuery().watch().map(
      (e) => e.groupListsBy((e) => (e.title, e.source)),
    );
    return result.map(
      (e) => e.map(
        (key, value) => MapEntry(key, [
          ...value.map(
            (e) => MangaDrift(
              createdAt: e.createdAt,
              updatedAt: e.updatedAt,
              id: e.id,
              title: e.title,
              coverUrl: e.coverUrl,
              author: e.author,
              status: e.status,
              webUrl: e.webUrl,
              description: e.description,
              source: e.source,
            ),
          ),
        ]),
      ),
    );
  }

  Stream<DuplicatedChapterResult> get duplicateChapter {
    final result = duplicatedChapterQuery().watch().map(
      (e) => e.groupListsBy((e) => (e.mangaId, e.chapter)),
    );
    return result.map(
      (e) => e.map(
        (key, value) => MapEntry(key, [
          ...value.map(
            (e) => ChapterDrift(
              createdAt: e.createdAt,
              updatedAt: e.updatedAt,
              id: e.id,
              mangaId: e.mangaId,
              title: e.title,
              volume: e.volume,
              chapter: e.chapter,
              translatedLanguage: e.translatedLanguage,
              scanlationGroup: e.scanlationGroup,
              webUrl: e.webUrl,
              readableAt: e.readableAt,
              publishAt: e.publishAt,
              lastReadAt: e.lastReadAt,
            ),
          ),
        ]),
      ),
    );
  }

  Stream<DuplicatedTagResult> get duplicateTag {
    final result = duplicatedTagQuery().watch().map(
      (e) => e.groupListsBy((e) => (e.name, e.source)),
    );
    return result.map(
      (e) => e.map(
        (key, value) => MapEntry(key, [
          ...value.map(
            (e) => TagDrift(
              createdAt: e.createdAt,
              updatedAt: e.updatedAt,
              id: e.id,
              tagId: e.tagId,
              name: e.name,
              source: e.source,
            ),
          ),
        ]),
      ),
    );
  }

  Stream<List<ChapterDrift>> get orphanChapter {
    final selector = select(chapterTables).join([
      leftOuterJoin(
        mangaTables,
        mangaTables.id.equalsExp(chapterTables.mangaId),
      ),
    ]);

    final query = selector..where(mangaTables.id.isNull());

    return query.watch().map((e) {
      return [...e.map((e) => e.readTableOrNull(chapterTables)).nonNulls];
    });
  }
}
