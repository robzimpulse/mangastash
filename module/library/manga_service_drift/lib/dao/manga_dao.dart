import 'package:drift/drift.dart';

import '../database/database.dart';
import '../model/manga_drift.dart';
import '../tables/manga_tables.dart';
import '../tables/manga_tag_relationship_tables.dart';
import '../tables/manga_tag_tables.dart';

part 'manga_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    MangaTagTables,
    MangaTagRelationshipTables,
  ],
)
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  // this constructor is required so that the main database can create an instance
  // of this object.
  MangaDao(AppDatabase db) : super(db);

  Future<List<MangaDrift>> search({
    List<String> ids = const [],
    List<String> titles = const [],
    List<String> coverUrls = const [],
    List<String> authors = const [],
    List<String> statuses = const [],
    List<String> descriptions = const [],
    List<String> webUrls = const [],
    List<String> sources = const [],
    List<String> tagsNames = const [],
  }) async {
    return transaction(
      () async {
        final tags = select(db.mangaTagRelationshipTables).join(
          [
            innerJoin(
              db.mangaTagRelationshipTables,
              db.mangaTagRelationshipTables.tagId
                  .equalsExp(db.mangaTagTables.id),
            ),
          ],
        )..where(
            [
              ...tagsNames.map((e) => db.mangaTagTables.name.equals(e)),
            ].reduce((result, element) => result | element),
          );

        final resultTags = await tags.get();

        final mangaIds = resultTags.map(
          (value) => value.read(db.mangaTagRelationshipTables.mangaId),
        );

        final selector = select(db.mangaTables)
          ..where(
            (f) => [
              for (final mangaId in mangaIds)
                if (mangaId != null) f.id.equals(mangaId),
              ...ids.map((e) => f.id.equals(e)),
              ...titles.map((e) => f.title.like('%$e}%')),
              ...coverUrls.map((e) => f.coverUrl.like('%$e}%')),
              ...authors.map((e) => f.author.like('%$e}%')),
              ...statuses.map((e) => f.status.like('%$e}%')),
              ...descriptions.map((e) => f.description.like('%$e}%')),
              ...webUrls.map((e) => f.webUrl.like('%$e}%')),
              ...sources.map((e) => f.source.like('%$e}%')),
            ].reduce((result, element) => result | element),
          )
          ..orderBy(
            [
              (f) => OrderingTerm(
                  expression: f.updatedAt, mode: OrderingMode.desc),
              (f) => OrderingTerm(expression: f.title, mode: OrderingMode.asc),
            ],
          );

        return selector.get();
      },
    );
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
