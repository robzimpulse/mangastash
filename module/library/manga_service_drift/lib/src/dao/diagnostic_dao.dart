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

  Future<DuplicatedMangaResult> get duplicateManga async {
    final result = await duplicatedMangaQuery().get().then(
      (e) => e.groupListsBy((e) => (e.title, e.source)),
    );
    return result.map(
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
    );
  }

  Future<DuplicatedChapterResult> get duplicateChapter async {
    final result = await duplicatedChapterQuery().get().then(
      (e) => e.groupListsBy((e) => (e.mangaId, e.chapter)),
    );
    return result.map(
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
    );
  }

  Future<DuplicatedTagResult> get duplicateTag async {
    final result = await duplicatedTagQuery().get().then(
      (e) => e.groupListsBy((e) => (e.name, e.source)),
    );
    return result.map(
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
    );
  }

  // Future<DiagnosticModel> get execute async {
  //   final manga = await duplicatedMangaQuery().get().then(
  //     (e) => e.groupListsBy((e) => (e.title, e.source)),
  //   );
  //   final tag = await duplicatedTagQuery().get().then(
  //     (e) => e.groupListsBy((e) => (e.name, e.source)),
  //   );
  //   final chapter = await duplicatedChapterQuery().get().then(
  //     (e) => e.groupListsBy((e) => (e.mangaId, e.chapter)),
  //   );
  //
  //   return DiagnosticModel(
  //     duplicatedManga: {
  //       for (final e in manga.entries)
  //         e.key: [
  //           ...e.value.map(
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
  //         ],
  //     },
  //     duplicatedTag: {
  //       for (final e in tag.entries)
  //         e.key: [
  //           ...e.value.map(
  //             (e) => TagDrift(
  //               createdAt: e.createdAt,
  //               updatedAt: e.updatedAt,
  //               id: e.id,
  //               tagId: e.tagId,
  //               name: e.name,
  //               source: e.source,
  //             ),
  //           ),
  //         ],
  //     },
  //     duplicatedChapter: {
  //       for (final e in chapter.entries)
  //         e.key: [
  //           ...e.value.map(
  //             (e) => ChapterDrift(
  //               createdAt: e.createdAt,
  //               updatedAt: e.updatedAt,
  //               id: e.id,
  //               mangaId: e.mangaId,
  //               title: e.title,
  //               volume: e.volume,
  //               chapter: e.chapter,
  //               translatedLanguage: e.translatedLanguage,
  //               scanlationGroup: e.scanlationGroup,
  //               webUrl: e.webUrl,
  //               readableAt: e.readableAt,
  //               publishAt: e.publishAt,
  //               lastReadAt: e.lastReadAt,
  //             ),
  //           ),
  //         ],
  //     },
  //   );
  // }
}
