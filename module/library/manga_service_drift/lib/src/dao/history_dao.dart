import 'package:drift/drift.dart';

import '../database/database.dart';
import '../model/history_model.dart';
import '../tables/chapter_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';

part 'history_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    RelationshipTables,
    ChapterTables,
  ],
)
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(AppDatabase db) : super(db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return select(relationshipTables).join(
      [
        leftOuterJoin(
          mangaTables,
          mangaTables.id.equalsExp(relationshipTables.mangaId),
        ),
        leftOuterJoin(
          chapterTables,
          chapterTables.mangaId.equalsExp(mangaTables.id),
        ),
      ],
    );
  }

  List<HistoryModel> _parse(List<TypedResult> rows) {
    return [
      for (final row in rows)
        HistoryModel(
          manga: row.readTableOrNull(mangaTables),
          chapter: row.readTableOrNull(chapterTables),
        ),
    ];
  }

  Stream<List<HistoryModel>> get history {
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
