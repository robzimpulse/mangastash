import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
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
  },
)
class DiagnosticDao extends DatabaseAccessor<AppDatabase>
    with _$DiagnosticDaoMixin {
  DiagnosticDao(super.db);

  Future<DiagnosticModel> get execute async {
    final manga = await duplicatedMangaQuery().get().then(
      (e) => e.groupListsBy((e) => (e.title, e.source)),
    );
    final tag = await duplicatedTagQuery().get().then(
      (e) => e.groupListsBy((e) => (e.name, e.source)),
    );
    final chapter = await duplicatedChapterQuery().get().then(
      (e) => e.groupListsBy((e) => (e.mangaId, e.chapter)),
    );

    return DiagnosticModel(
      duplicatedManga: {
        for (final e in manga.entries)
          e.key: [
            ...e.value.map(
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
          ],
      },
      duplicatedTag: {
        for (final e in tag.entries)
          e.key: [
            ...e.value.map(
              (e) => TagDrift(
                createdAt: e.createdAt,
                updatedAt: e.updatedAt,
                id: e.id,
                tagId: e.tagId,
                name: e.name,
                source: e.source,
              ),
            ),
          ],
      },
      duplicatedChapter: {
        for (final e in chapter.entries)
          e.key: [
            ...e.value.map(
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
          ],
      },
    );
  }

  // late final MangaDao _mangaDao = MangaDao(db);

  // List<DiagnosticModel> _parse(List<TypedResult> rows) {
  //   return [
  //     for (final row in rows)
  //       DiagnosticModel(
  //         mangaTagRelationship: row.readTableOrNull(relationshipTables),
  //         manga: row.readTableOrNull(mangaTables),
  //         tag: row.readTableOrNull(tagTables),
  //         duplicatedManga: row.read(mangaTables.)
  //       ),
  //   ];
  // }
  //
  // Future<List<DiagnosticModel>> get missingMangaTagRelationship async {
  //   final selector = select(relationshipTables).join([
  //     leftOuterJoin(
  //       mangaTables,
  //       mangaTables.id.equalsExp(relationshipTables.mangaId),
  //     ),
  //     leftOuterJoin(
  //       tagTables,
  //       tagTables.id.equalsExp(relationshipTables.tagId),
  //     ),
  //   ]);
  //
  //   final filter = [
  //     mangaTables.id.isNull(),
  //     tagTables.id.isNull(),
  //   ].fold<Expression<bool>>(const Constant(false), (a, b) => a | b);
  //
  //   final query = selector..where(filter);
  //
  //   return query.get().then(_parse);
  // }

  // Future<List<DiagnosticModel>> get duplicatedManga async {
  //   final result = await duplicateMangaQuery().get();
  //   final groups = result.groupListsBy((e) => (e.title, e.source));
  //   return [
  //     for (final group in groups.entries)
  //       DiagnosticModel(
  //         duplicatedManga: MapEntry(group.key, [
  //           ...group.value.map(
  //             (e) => MangaDrift(
  //               createdAt: e.createdAt,
  //               updatedAt: e.updatedAt,
  //               id: e.id,
  //               title: e.title,
  //               coverUrl: e.coverUrl,
  //               author: e.author,
  //               status: e.status,
  //               webUrl: e.webUrl,
  //               description: e.description,
  //               source: e.source,
  //             ),
  //           ),
  //         ]),
  //       ),
  //   ];
  // }
}
