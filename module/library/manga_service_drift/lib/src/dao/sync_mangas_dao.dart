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

    /// TODO: sync tags
    final toUpdate = <MangaTablesCompanion>[];
    final toInsert = <MangaTablesCompanion>[];

    /// separate manga that have id (scraped) and those that don't
    for (final manga in mangas) {
      if (manga.id?.isNotEmpty == true) {
        toUpdate.add(manga.toCompanion());
      } else {
        toInsert.add(manga.toCompanion());
      }
    }

    /// variable for full scan existing record
    final titles = <String?>[];
    final coverUrls = <String?>[];
    final authors = <String?>[];
    final statuses = <String?>[];
    final descriptions = <String?>[];
    final webUrls = <String?>[];
    final sources = <String?>[];
    final entries = <String?>[];
    for (final manga in toInsert) {
      titles.add(manga.title.value);
      coverUrls.add(manga.coverUrl.value);
      authors.add(manga.author.value);
      statuses.add(manga.status.value);
      descriptions.add(manga.description.value);
      webUrls.add(manga.webUrl.value);
      sources.add(manga.source.value);

      entries.addAll([
        manga.title.value,
        manga.coverUrl.value,
        manga.author.value,
        manga.status.value,
        manga.description.value,
        manga.webUrl.value,
        manga.source.value,
      ]);
    }

    /// perform full scan to select all manga that have similar value
    final selector = entries.nonNulls.isEmpty
        ? null
        : (select(mangaTables)
          ..where(
            (f) => [
              for (final value in titles.nonNulls) f.title.like('%$value%'),
              for (final value in coverUrls.nonNulls)
                f.coverUrl.like('%$value%'),
              for (final value in authors.nonNulls) f.author.like('%$value%'),
              for (final value in statuses.nonNulls) f.status.like('%$value%'),
              for (final value in descriptions.nonNulls)
                f.description.like('%$value%'),
              for (final value in webUrls.nonNulls) f.webUrl.like('%$value%'),
              for (final value in sources.nonNulls) f.source.like('%$value%'),
            ].reduce((a, b) => a | b),
          ));

    final existing = (await selector?.get()) ?? [];

    // final temp = toUpsert;
    for (final manga in existing) {
      /// exit if nothing found
      if (toInsert.isEmpty) break;

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

        /// update manga that have id
        for (final manga in toUpdate) {
          final selector = update(mangaTables)
            ..where((f) => f.id.equals(manga.id.value));
          final result = await selector.writeReturning(
            manga.copyWith(
              id: const Value.absent(),
              updatedAt: Value(DateTime.now().toIso8601String()),
            ),
          );
          all.addAll(result);
        }

        /// insert manga that don't have id and don't have similar data
        for (final manga in toInsert) {
          final result = await into(mangaTables).insertReturning(
            manga.copyWith(
              id: Value(const Uuid().v4().toString()),
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
}
