import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../manga_service_drift.dart';
import '../database/database.dart';
import '../extension/nullable_generic.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';

part 'status_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    TagTables,
    RelationshipTables,
    ChapterTables,
    ImageTables,
  ],
)
class StatusDao extends DatabaseAccessor<AppDatabase> with _$StatusDaoMixin {
  StatusDao(AppDatabase db) : super(db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return select(relationshipTables).join(
      [
        leftOuterJoin(
          mangaTables,
          mangaTables.id.equalsExp(relationshipTables.mangaId),
        ),
        leftOuterJoin(
          tagTables,
          tagTables.id.equalsExp(relationshipTables.tagId),
        ),
        leftOuterJoin(
          chapterTables,
          chapterTables.mangaId.equalsExp(mangaTables.id),
        ),
        leftOuterJoin(
          imageTables,
          imageTables.chapterId.equalsExp(chapterTables.id),
        ),
      ],
    );
  }

  List<MangaModel> _parse(List<TypedResult> rows) {
    final data = <MangaModel>[];

    final groups = rows.groupListsBy((e) => e.readTableOrNull(mangaTables));

    for (final key in groups.keys.nonNulls) {
      final children = groups[key]?.groupListsBy(
        (e) => e.readTableOrNull(chapterTables),
      );

      data.add(
        MangaModel(
          manga: key,
          tags: [
            ...?groups[key]
                ?.map((e) => e.readTableOrNull(tagTables))
                .nonNulls
                .toSet(),
          ],
          chapters: [
            ...?children?.let(
              (e) => e.entries.map(
                (entry) => ChapterModel(
                  chapter: entry.key,
                  images: [
                    ...entry.value
                        .map((e) => e.readTableOrNull(imageTables))
                        .nonNulls,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return data;
  }

  Stream<List<MangaModel>> get history {
    final order = [
      OrderingTerm(
        expression: chapterTables.lastReadAt,
        mode: OrderingMode.desc,
      ),
    ];

    final selector = _aggregate
      ..where(chapterTables.lastReadAt.isNotNull())
      ..orderBy(order);

    return selector.watch().map(_parse);
  }
}
