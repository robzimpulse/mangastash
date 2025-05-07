import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../tables/manga_tag_tables.dart';

part 'manga_tag_dao.g.dart';

@DriftAccessor(tables: [MangaTagTables])
class MangaTagDao extends DatabaseAccessor<AppDatabase>
    with _$MangaTagDaoMixin {
  final Uuid _uuid;

  MangaTagDao({required AppDatabase db, Uuid? uuid})
      : _uuid = uuid ?? const Uuid(),
        super(db);

  Future<List<MangaTagTable>> search({List<String> names = const []}) async {
    if (names.isEmpty) return [];
    final selector = select(db.mangaTagTables)
      ..where(
        (f) => [
          for (final e in names)
            if (e.isNotEmpty) f.name.equals(e),
        ].reduce((result, element) => result | element),
      );

    return selector.get();
  }

  Future<List<MangaTagTable>> inserts(List<MangaTagTable> tags) async {
    return transaction(() async {
      /// initialize variable
      var items = [...tags];
      List<MangaTagTable> success = [];

      /// loop inserting until all items are inserted
      while (items.isNotEmpty) {
        /// get first item and remove from array [items]
        final item = items.removeAt(0);

        /// try to add item to database
        try {
          /// if insert item were success, add to array [success]
          success.add(await into(mangaTagTables).insertReturning(item));
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

  Future<List<MangaTagTable>> remove({List<String> names = const []}) async {
    if (names.isEmpty) return [];
    return transaction(() async {
      final selector = delete(mangaTagTables)
        ..where(
          (f) => [
            for (final e in names)
              if (e.isNotEmpty) f.name.equals(e),
          ].reduce((result, element) => result | element),
        );

      return selector.goAndReturn();
    });
  }
}
