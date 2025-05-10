import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../model/manga_drift.dart';
import '../tables/manga_tables.dart';
import '../tables/manga_tag_relationship_tables.dart';
import '../tables/manga_tag_tables.dart';

part 'sync_mangas_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    MangaTagTables,
    MangaTagRelationshipTables,
  ],
)
class SyncMangasDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMangasDaoMixin {
  SyncMangasDao(AppDatabase db) : super(db);

  Future<List<MangaDrift>> sync(List<MangaDrift> mangas) async {
    if (mangas.isEmpty) return [];

    /// variable for full scan existing record
    final existing = await scan(
      ids: mangas.map((e) => e.id).nonNulls.toList(),
      titles: mangas.map((e) => e.title).nonNulls.toList(),
      coverUrls: mangas.map((e) => e.coverUrl).nonNulls.toList(),
      authors: mangas.map((e) => e.author).nonNulls.toList(),
      statuses: mangas.map((e) => e.status).nonNulls.toList(),
      descriptions: mangas.map((e) => e.description).nonNulls.toList(),
      webUrls: mangas.map((e) => e.webUrl).nonNulls.toList(),
      sources: mangas.map((e) => e.source).nonNulls.toList(),
    );

    /// TODO: sync tags
    final toUpdate = <MangaTablesCompanion>[];
    final toInsert = mangas.map((e) => e.toCompanion()).toList();
    for (final manga in existing) {
      /// convert existing manga record to companion
      final comp = manga.toCompanion(false);

      /// sort by similarity
      toInsert.sort(
        (a, b) => ((comp.similarity(a) - comp.similarity(b)) * 1000).toInt(),
      );

      /// pop the first similar
      final result = toInsert.removeAt(0);

      toUpdate.add(
        comp.copyWith(
          title: result.title,
          coverUrl: result.coverUrl,
          author: result.author,
          status: result.status,
          description: result.description,
          webUrl: result.webUrl,
          source: result.source,
        ),
      );
    }

    return transaction(
      () async {
        final all = <MangaTable>[];

        /// update manga
        for (final manga in toUpdate) {
          final selector = update(mangaTables)
            ..where((f) => f.id.equals(manga.id.value));
          final result = await selector.writeReturning(
            manga.copyWith(updatedAt: Value(DateTime.now().toIso8601String())),
          );
          all.addAll(result);
        }

        /// insert manga
        for (final manga in toInsert) {
          final result = await into(mangaTables).insertReturning(
            manga.copyWith(
              id: manga.id.present ? null : Value(const Uuid().v4().toString()),
            ),
            onConflict: DoUpdate(
              (old) => manga.copyWith(
                id: Value(const Uuid().v4().toString()),
              ),
            ),
          );
          all.add(result);
        }

        return all
            .map((e) => MangaDrift.fromCompanion(e.toCompanion(false), []))
            .toList();
      },
    );
  }

  Future<List<MangaTable>> scan({
    List<String> ids = const [],
    List<String> titles = const [],
    List<String> coverUrls = const [],
    List<String> authors = const [],
    List<String> statuses = const [],
    List<String> descriptions = const [],
    List<String> webUrls = const [],
    List<String> sources = const [],
  }) async {
    final isAllEmpty = [
      ...ids,
      ...titles,
      ...coverUrls,
      ...authors,
      ...statuses,
      ...descriptions,
      ...webUrls,
      ...sources,
    ].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(mangaTables)
      ..where(
        (f) => [
          for (final e in ids) f.id.equals(e),
          for (final e in titles) f.title.like('%$e%'),
          for (final e in coverUrls) f.coverUrl.like('%$e%'),
          for (final e in authors) f.author.like('%$e%'),
          for (final e in statuses) f.status.like('%$e%'),
          for (final e in descriptions) f.description.like('%$e%'),
          for (final e in webUrls) f.webUrl.like('%$e%'),
          for (final e in sources) f.source.like('%$e%'),
        ].reduce((a, b) => a | b),
      );

    return selector.get();
  }
}
