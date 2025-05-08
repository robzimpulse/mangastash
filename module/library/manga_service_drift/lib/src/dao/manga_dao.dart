import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../tables/manga_tables.dart';

part 'manga_dao.g.dart';

@DriftAccessor(tables: [MangaTables])
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  final Uuid _uuid;

  MangaDao({required AppDatabase db, Uuid? uuid})
      : _uuid = uuid ?? const Uuid(),
        super(db);

  Future<List<MangaTable>> search({
    List<String> titles = const [],
    List<String> coverUrls = const [],
    List<String> authors = const [],
    List<String> statuses = const [],
    List<String> descriptions = const [],
    List<String> webUrls = const [],
    List<String> sources = const [],
  }) async {
    final isAllEmpty = [
      titles.isEmpty,
      coverUrls.isEmpty,
      authors.isEmpty,
      statuses.isEmpty,
      descriptions.isEmpty,
      webUrls.isEmpty,
      sources.isEmpty,
    ].every((isTrue) => isTrue);

    if (isAllEmpty) return [];

    final selector = select(mangaTables)
      ..where(
        (f) => [
          for (final e in titles)
            if (e.isNotEmpty) f.title.like('%$e%'),
          for (final e in coverUrls)
            if (e.isNotEmpty) f.coverUrl.like('%$e%'),
          for (final e in authors)
            if (e.isNotEmpty) f.author.like('%$e%'),
          for (final e in statuses)
            if (e.isNotEmpty) f.status.like('%$e%'),
          for (final e in descriptions)
            if (e.isNotEmpty) f.description.like('%$e%'),
          for (final e in webUrls)
            if (e.isNotEmpty) f.webUrl.like('%$e%'),
          for (final e in sources)
            if (e.isNotEmpty) f.source.like('%$e%'),
        ].reduce((result, element) => result | element),
      )
      ..orderBy(
        [
          (f) => OrderingTerm(expression: f.updatedAt, mode: OrderingMode.desc),
          (f) => OrderingTerm(expression: f.title, mode: OrderingMode.asc),
        ],
      );

    return selector.get();
  }

  Future<List<MangaTable>> inserts(List<MangaTable> mangas) async {
    return transaction(() async {
      /// initialize variable
      var items = [...mangas];
      List<MangaTable> success = [];

      /// loop inserting until all items are inserted
      while (items.isNotEmpty) {
        /// get first item and remove from array [items]
        final item = items.removeAt(0);

        /// try to add item to database
        try {
          /// if insert item were success, add to array [success]
          success.add(await into(mangaTables).insertReturning(item));
        } catch (e) {
          /// if failed to insert item, put it back to array [items] with
          /// modified id
          items.add(item.copyWith(id: _uuid.v4()));
        }
      }

      /// return inserted item
      return success;
    });
  }

  Future<List<MangaTable>> remove({List<String> ids = const []}) async {
    if (ids.isEmpty) return [];
    return transaction(() async {
      final selector = delete(mangaTables)
        ..where(
          (f) => [
            for (final e in ids)
              if (e.isNotEmpty) f.id.equals(e),
          ].reduce((result, element) => result | element),
        );

      return selector.goAndReturn();
    });
  }
}
