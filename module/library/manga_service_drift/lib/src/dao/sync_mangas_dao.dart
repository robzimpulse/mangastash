import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../manga_service_drift.dart';
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
    final tags = mangas.expand((e) => e.tags ?? <MangaTagDrift>[]).toList();

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

    final toUpdateManga = <MangaTablesCompanion>[];
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
        comp.copyWith(
          title: Value.absentIfNull(result.title),
          coverUrl: Value.absentIfNull(result.coverUrl),
          author: Value.absentIfNull(result.author),
          status: Value.absentIfNull(result.status),
          description: Value.absentIfNull(result.description),
          webUrl: Value.absentIfNull(result.webUrl),
          source: Value.absentIfNull(result.source),
        ),
      );
    }

    return transaction(
      () async {
        final allManga = <MangaTable>[];
        final allTag = <MangaTagTable>[];

        /// update manga
        for (final manga in toUpdateManga) {
          final selector = update(mangaTables)
            ..where((f) => f.id.equals(manga.id.value));
          final result = await selector.writeReturning(
            manga.copyWith(updatedAt: Value(DateTime.now().toIso8601String())),
          );
          allManga.addAll(result);
        }

        for (final tag in toUpdateTags) {
          final selector = update(mangaTagTables)
            ..where((f) => f.id.equals(tag.id.value));
          final result = await selector.writeReturning(
            tag.copyWith(updatedAt: Value(DateTime.now().toIso8601String())),
          );
          allTag.addAll(result);
        }

        /// insert manga
        for (final manga in toInsertManga) {
          final result = await into(mangaTables).insertReturning(
            manga.toCompanion().copyWith(
                  id: manga.toCompanion().id.present
                      ? null
                      : Value(const Uuid().v4().toString()),
                ),
            onConflict: DoUpdate(
              (old) => manga.toCompanion()
                ..copyWith(
                  id: Value(const Uuid().v4().toString()),
                ),
            ),
          );
          allManga.add(result);
        }

        for (final tag in toInsertTags) {
          final result = await into(mangaTagTables).insertReturning(
            tag.toCompanion().copyWith(
                  id: tag.toCompanion().id.present
                      ? null
                      : Value(const Uuid().v4().toString()),
                ),
            onConflict: DoUpdate(
              (old) => tag.toCompanion().copyWith(
                    id: Value(const Uuid().v4().toString()),
                  ),
            ),
          );
          allTag.add(result);
        }

        return allManga
            .map(
              (e) => MangaDrift.fromCompanion(
                e.toCompanion(false),
                // TODO: update manga-tags relationship
                [],
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
    final isAllEmpty = [...ids, ...names].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(mangaTagTables)
      ..where(
        (f) => [
          for (final e in ids) f.id.equals(e),
          for (final e in names) f.name.equals(e),
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
