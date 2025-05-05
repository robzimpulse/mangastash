import 'package:drift/drift.dart';

import '../database/database.dart';
import '../model/manga_drift.dart';
import '../tables/manga_tables.dart';

part 'manga_dao.g.dart';

@DriftAccessor(tables: [MangaTables])
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  // this constructor is required so that the main database can create an instance
  // of this object.
  MangaDao(AppDatabase db) : super(db);

  /// TODO: search by tags
  Future<List<MangaDrift>> search({
    String? title,
    String? coverUrl,
    String? author,
    String? status,
    String? description,
    String? webUrl,
    String? source,
  }) async {
    final selector = select(db.mangaTables)
      ..where(
        (f) => [
          if (title != null) f.title.like('%$title%'),
          if (coverUrl != null) f.coverUrl.like('%$coverUrl%'),
          if (author != null) f.author.like('%$author%'),
          if (status != null) f.status.like('$status%'),
          if (description != null) f.description.like('%$description%'),
          if (webUrl != null) f.webUrl.like('%$webUrl%'),
          if (source != null) f.source.like('%$source%'),
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

  Future<MangaDrift> insert(MangaDrift manga) {
    /// TODO: insert tags
    return transaction(
      () => into(db.mangaTables).insertReturning(
        manga,
        onConflict: DoUpdate(
          (old) => MangaDrift(
            title: manga.title,
            coverUrl: manga.coverUrl,
            author: manga.author,
            status: manga.status,
            description: manga.description,
            webUrl: manga.webUrl,
            source: manga.source,
          ),
        ),
      ),
    );
  }

  Future<void> batchInsert(List<MangaDrift> mangas) {
    /// TODO: insert tags
    return transaction(
      () => batch(
        (batch) => batch.insertAllOnConflictUpdate(db.mangaTables, mangas),
      ),
    );
  }

  Future<List<MangaDrift>> remove({required String id}) {
    /// TODO: also remove attached tags if not used
    return transaction(
      () {
        final selector = delete(db.mangaTables)..where((f) => f.id.equals(id));
        return selector.goAndReturn();
      },
    );
  }
}
