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
    final toSync = <MangaTablesCompanion>[];
    final toUpdateExisting = <MangaTablesCompanion>[];

    /// separate manga that have id (scraped) and those that don't
    for (final manga in mangas) {
      if (manga.id?.isNotEmpty == true) {
        toSync.add(manga.toCompanion());
      } else {
        toUpdate.add(manga.toCompanion());
      }
    }

    /// select all manga that have properties like [mangas]
    final selector = select(mangaTables)
      ..where(
        (f) => [
          for (final manga in toSync) ...[
            if (manga.title.present) f.title.like('%${manga.title.value}%'),
            if (manga.coverUrl.present)
              f.coverUrl.like('%${manga.coverUrl.value}%'),
            if (manga.author.present) f.author.like('%${manga.author.value}%'),
            if (manga.status.present) f.status.like('%${manga.status.value}%'),
            if (manga.description.present)
              f.description.like('%${manga.description.value}%'),
            if (manga.webUrl.present) f.webUrl.like('%${manga.webUrl.value}%'),
            if (manga.source.present) f.source.like('%${manga.source.value}%'),
          ],
        ].reduce((a, b) => a | b),
      );

    final existing = await selector.get();

    final temp = toSync;
    for (final manga in existing) {
      /// exit if nothing found
      if (temp.isEmpty) break;

      /// convert existing manga record to companion
      final comp = manga.toCompanion(false);

      /// sort by similarity
      temp.sort(
        (a, b) => ((comp.similarity(a) - comp.similarity(b)) * 1000).toInt(),
      );

      /// pop the first similar
      final result = temp.removeAt(0);

      toUpdateExisting.add(
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
              updatedAt: Value(
                DateTime.now().toIso8601String(),
              ),
            ),
          );
          all.addAll(result);
        }

        /// update manga that don't have id but have similar data
        for (final manga in toUpdateExisting) {
          final selector = update(mangaTables)
            ..where((f) => f.id.equals(manga.id.value));
          final result = await selector.writeReturning(
            manga.copyWith(
              updatedAt: Value(
                DateTime.now().toIso8601String(),
              ),
            ),
          );
          all.addAll(result);
        }

        /// insert manga that don't have id and don't have similar data
        for (final manga in temp) {
          final result = await into(mangaTables).insertReturning(
            manga,
            onConflict: DoUpdate(
              (old) => manga.copyWith(
                id: Value(
                  const Uuid().v4().toString(),
                ),
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
