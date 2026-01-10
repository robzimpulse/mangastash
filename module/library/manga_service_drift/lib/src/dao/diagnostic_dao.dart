import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../manga_service_drift.dart';
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
)
class DiagnosticDao extends DatabaseAccessor<AppDatabase>
    with _$DiagnosticDaoMixin {
  DiagnosticDao(super.db);

  late final MangaDao _mangaDao = MangaDao(db);

  List<DiagnosticModel> _parse(List<TypedResult> rows) {
    return [
      for (final row in rows)
        DiagnosticModel(
          mangaTagRelationship: row.readTableOrNull(relationshipTables),
          manga: row.readTableOrNull(mangaTables),
          tag: row.readTableOrNull(tagTables),
        ),
    ];
  }

  Future<List<DiagnosticModel>> get missingMangaTagRelationship async {
    final selector = select(relationshipTables).join([
      leftOuterJoin(
        mangaTables,
        mangaTables.id.equalsExp(relationshipTables.mangaId),
      ),
      leftOuterJoin(
        tagTables,
        tagTables.id.equalsExp(relationshipTables.tagId),
      ),
    ]);

    final filter = [
      mangaTables.id.isNull(),
      tagTables.id.isNull(),
    ].fold<Expression<bool>>(const Constant(false), (a, b) => a | b);

    final query = selector..where(filter);

    return query.get().then(_parse);
  }

  Future<List<DiagnosticModel>> get duplicatedManga async {
    return _mangaDao.all.then((e) {
      return e
          .groupListsBy((e) => (e.manga?.title, e.manga?.source))
          .entries
          .where((e) => e.value.length > 1)
          .map(
            (e) => MapEntry(
              e.key,
              e.value
                  .sortedBy(
                    (e) =>
                        e.manga?.updatedAt ??
                        DateTime.fromMillisecondsSinceEpoch(0),
                  )
                  .reversed
                  .toList(),
            ),
          )
          .map((e) => DiagnosticModel(duplicatedManga: e))
          .toList();
    });
  }
}
