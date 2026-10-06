import 'package:drift/drift.dart';
import 'package:rxdart/transformers.dart';

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
  HistoryDao(
    super.db, {
    DateTime Function()? clock,
    this.refreshInterval = const Duration(minutes: 30),
  }) : _clock = clock ?? DateTime.now;

  /// Clock the rolling 7-day unread window is computed from. Injectable so
  /// tests can move time without waiting it out.
  final DateTime Function() _clock;

  /// How often the [unread] stream rebuilds its query. The window boundary
  /// is bound into the statement as a variable, so a single watched query
  /// would freeze it at stream creation — long-lived streams would keep
  /// surfacing chapters older than 7 days forever (issue #131).
  final Duration refreshInterval;

  JoinedSelectStatement<HasResultSet, dynamic> _aggregate({
    bool onlyLibrary = true,
  }) {
    return select(chapterTables).join([
      innerJoin(mangaTables, mangaTables.id.equalsExp(chapterTables.mangaId)),
      if (onlyLibrary)
        innerJoin(
          libraryTables,
          libraryTables.mangaId.equalsExp(mangaTables.id),
        ),
    ]);
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
    final selector =
        _aggregate(onlyLibrary: false)
          ..orderBy([OrderingTerm.desc(chapterTables.lastReadAt)])
          ..where(chapterTables.lastReadAt.isNotNull());
    return selector.watch().map(_parse);
  }

  Stream<List<HistoryModel>> get unread {
    // Rebuild the selector on every tick so the 7-day boundary is recomputed
    // from the current clock (issue #131); switchMap keeps exactly one
    // active watched query, so drift's table-change reactivity still works
    // between ticks.
    return Stream<void>.periodic(refreshInterval)
        .startWith(null)
        .switchMap((_) => _unreadSelector().watch().map(_parse));
  }

  JoinedSelectStatement<HasResultSet, dynamic> _unreadSelector() {
    // 1. Calculate the timestamp for 7 days ago
    final oneWeekAgo = _clock().subtract(const Duration(days: 7));

    return _aggregate(onlyLibrary: true)
      ..orderBy([
        OrderingTerm.desc(chapterTables.createdAt),
        OrderingTerm.desc(chapterTables.readableAt),
      ])
      ..where(chapterTables.readableAt.isBiggerOrEqualValue(oneWeekAgo))
      ..where(chapterTables.lastReadAt.isNull());
  }
}
