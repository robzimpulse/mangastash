import 'package:drift/drift.dart';

import '../database/database.dart';
import '../model/history_model.dart';
import '../tables/chapter_tables.dart';
import '../tables/library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';

part 'history_dao.g.dart';

@DriftAccessor(
  tables: [LibraryTables, MangaTables, RelationshipTables, ChapterTables],
)
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(super.db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return select(chapterTables).join([
      innerJoin(mangaTables, mangaTables.id.equalsExp(chapterTables.mangaId)),
      innerJoin(libraryTables, libraryTables.mangaId.equalsExp(mangaTables.id)),
    ])..orderBy([OrderingTerm.desc(chapterTables.lastReadAt)]);
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
    final selector = _aggregate..where(chapterTables.lastReadAt.isNotNull());
    return selector.watch().map(_parse);
  }

  Stream<List<HistoryModel>> get unread {
    final selector = _aggregate..where(chapterTables.lastReadAt.isNull());
    return selector.watch().map(_parse);
  }
}
