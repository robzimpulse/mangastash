import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
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
    final tags = mangas.expand((e) => e.tags).toList();

    final existingMangas = await searchMangas(
      ids: mangas.map((e) => e.id).nonNulls.toList(),
      titles: mangas.map((e) => e.title).nonNulls.toList(),
      coverUrls: mangas.map((e) => e.coverUrl).nonNulls.toList(),
      authors: mangas.map((e) => e.author).nonNulls.toList(),
      statuses: mangas.map((e) => e.status).nonNulls.toList(),
      descriptions: mangas.map((e) => e.description).nonNulls.toList(),
      webUrls: mangas.map((e) => e.webUrl).nonNulls.toList(),
      sources: mangas.map((e) => e.source).nonNulls.toList(),
    );

    final existingTags = await searchTags(
      ids: tags.map((e) => e.id).nonNulls.toList(),
      names: tags.map((e) => e.name).nonNulls.toList(),
    );

    final toUpdateManga = <(MangaTablesCompanion, List<String>)>[];
    final toInsertManga = mangas;

    final toUpdateTags = <MangaTagTablesCompanion>[];
    final toInsertTags = tags;

    for (final tag in existingTags) {
      /// convert existing record to companion
      final comp = tag.toCompanion(false);

      /// sort by similarity
      toInsertTags.sort(
        (a, b) {
          final left = comp.similarity(a.toCompanion());
          final right = comp.similarity(b.toCompanion());
          return ((left - right) * 1000).toInt();
        },
      );

      /// pop the first similar
      final result = toInsertTags.removeAt(0);

      toUpdateTags.add(
        comp.copyWith(
          name: Value.absentIfNull(result.name),
        ),
      );
    }

    for (final manga in existingMangas) {
      /// convert existing record to companion
      final comp = manga.toCompanion(false);

      /// sort by similarity
      toInsertManga.sort(
        (a, b) {
          final left = comp.similarity(a.toCompanion());
          final right = comp.similarity(b.toCompanion());
          return ((left - right) * 1000).toInt();
        },
      );

      /// pop the first similar
      final result = toInsertManga.removeAt(0);

      toUpdateManga.add(
        (
          comp.copyWith(
            title: Value.absentIfNull(result.title),
            coverUrl: Value.absentIfNull(result.coverUrl),
            author: Value.absentIfNull(result.author),
            status: Value.absentIfNull(result.status),
            description: Value.absentIfNull(result.description),
            webUrl: Value.absentIfNull(result.webUrl),
            source: Value.absentIfNull(result.source),
          ),
          result.tags.map((e) => e.name).nonNulls.toList(),
        ),
      );
    }

    return transaction(
      () async {
        final allManga = <(MangaTable, List<MangaTagTable>)>[];
        final allTag = <MangaTagTable>[];

        /// insert tag
        for (final tag in toInsertTags) {
          final tmp = tag.toCompanion();
          final result = await into(mangaTagTables).insertReturning(
            tmp.copyWith(
              id: tmp.id.present ? null : Value(const Uuid().v4().toString()),
              createdAt: Value(DateTime.now().toIso8601String()),
              updatedAt: Value(DateTime.now().toIso8601String()),
            ),
            onConflict: DoUpdate(
              (old) => tmp.copyWith(
                id: Value(const Uuid().v4().toString()),
                createdAt: Value(DateTime.now().toIso8601String()),
                updatedAt: Value(DateTime.now().toIso8601String()),
              ),
            ),
          );
          allTag.add(result);
        }

        /// update tag
        for (final tag in toUpdateTags) {
          final selector = update(mangaTagTables)
            ..where((f) => f.id.equals(tag.id.value));
          final result = await selector.writeReturning(
            tag.copyWith(updatedAt: Value(DateTime.now().toIso8601String())),
          );
          allTag.addAll(result);
        }

        /// update manga
        for (final (manga, tagNames) in toUpdateManga) {
          final selector = update(mangaTables)
            ..where((f) => f.id.equals(manga.id.value));
          final results = await selector.writeReturning(
            manga.copyWith(updatedAt: Value(DateTime.now().toIso8601String())),
          );
          for (final result in results) {
            /// delete existing relationship for updated manga
            await (delete(mangaTagRelationshipTables)
                  ..where((f) => f.mangaId.equals(manga.id.value)))
                .go();

            final newTags = [...allTag.where((e) => tagNames.contains(e.name))];
            for (final tag in newTags) {
              await into(mangaTagRelationshipTables).insert(
                MangaTagRelationshipTablesCompanion.insert(
                  tagId: tag.id,
                  mangaId: result.id,
                ),
              );
            }
            allManga.add((result, newTags));
          }
        }

        /// insert manga
        for (final manga in toInsertManga) {
          final tags = manga.tags.map((e) => e.name).nonNulls.toList();
          final newTags = [...allTag.where((e) => tags.contains(e.name))];
          final tmp = manga.toCompanion();
          final result = await into(mangaTables).insertReturning(
            tmp.copyWith(
              id: tmp.id.present ? null : Value(const Uuid().v4().toString()),
              createdAt: Value(DateTime.now().toIso8601String()),
              updatedAt: Value(DateTime.now().toIso8601String()),
            ),
            onConflict: DoUpdate(
              (old) => tmp.copyWith(
                id: Value(const Uuid().v4().toString()),
                createdAt: Value(DateTime.now().toIso8601String()),
                updatedAt: Value(DateTime.now().toIso8601String()),
              ),
            ),
          );
          for (final tag in newTags) {
            await into(mangaTagRelationshipTables).insert(
              MangaTagRelationshipTablesCompanion.insert(
                tagId: tag.id,
                mangaId: result.id,
              ),
            );
          }
          allManga.add((result, newTags));
        }

        return allManga
            .map(
              (e) => MangaDrift.fromCompanion(
                e.$1.toCompanion(false),
                e.$2.map((e) => e.toCompanion(false)).toList(),
              ),
            )
            .toList();
      },
    );
  }

  Future<List<MangaTagTable>> searchTags({
    List<String> ids = const [],
    List<String> names = const [],
  }) async {
    final isAllEmpty = [...ids.nonEmpty, ...names.nonEmpty].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(mangaTagTables)
      ..where(
        (f) => [
          for (final e in ids.nonEmpty) f.id.equals(e),
          for (final e in names.nonEmpty) f.name.equals(e),
        ].reduce((a, b) => a | b),
      );

    return selector.get();
  }

  Future<List<MangaTable>> searchMangas({
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
      ...ids.nonEmpty,
      ...titles.nonEmpty,
      ...coverUrls.nonEmpty,
      ...authors.nonEmpty,
      ...statuses.nonEmpty,
      ...descriptions.nonEmpty,
      ...webUrls.nonEmpty,
      ...sources.nonEmpty,
    ].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(mangaTables)
      ..where(
        (f) => [
          for (final e in ids.nonEmpty) f.id.equals(e),
          for (final e in titles.nonEmpty) f.title.like('%$e%'),
          for (final e in coverUrls.nonEmpty) f.coverUrl.like('%$e%'),
          for (final e in authors.nonEmpty) f.author.like('%$e%'),
          for (final e in statuses.nonEmpty) f.status.like('%$e%'),
          for (final e in descriptions.nonEmpty) f.description.like('%$e%'),
          for (final e in webUrls.nonEmpty) f.webUrl.like('%$e%'),
          for (final e in sources.nonEmpty) f.source.like('%$e%'),
        ].reduce((a, b) => a | b),
      );

    return selector.get();
  }
}
