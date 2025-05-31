import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/value_or_null_extension.dart';
import '../tables/library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';

part 'manga_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    TagTables,
    RelationshipTables,
    LibraryTables,
  ],
)
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  MangaDao(AppDatabase db) : super(db);

  Future<Map<MangaDrift, List<TagDrift>>> sync(
    Map<MangaTablesCompanion, List<TagTablesCompanion>> values,
  ) async {
    final tags = values.values.expand((e) => e);
    final mangas = values.keys;

    final existingMangas = await searchMangas(
      ids: mangas.map((e) => e.id.valueOrNull).nonNulls.toList(),
      titles: mangas.map((e) => e.title.valueOrNull).nonNulls.toList(),
      webUrls: mangas.map((e) => e.webUrl.valueOrNull).nonNulls.toList(),
      sources: mangas.map((e) => e.source.valueOrNull).nonNulls.toList(),
    );

    final existingTags = await searchTags(
      ids: tags.map((e) => e.id.valueOrNull).nonNulls.toList(),
      names: tags.map((e) => e.name.valueOrNull).nonNulls.toList(),
    );

    return transaction(() async {
      final results = <MangaDrift, List<TagDrift>>{};
      for (final entry in values.entries) {
        final mangaId = entry.key.id.valueOrNull;

        final matchManga = existingMangas.firstWhereOrNull(
          (e) => [
            if (mangaId != null) ...[
              e.id == mangaId,
            ] else ...[
              e.title == entry.key.title.valueOrNull,
              e.webUrl == entry.key.webUrl.valueOrNull,
              e.source == entry.key.source.valueOrNull,
            ],
          ].every((isTrue) => isTrue),
        );

        final updatesManga = matchManga != null
            ? await updateManga(entry.key.copyWith(id: Value(matchManga.id)))
            : [await insertManga(entry.key)];

        if (updatesManga.length > 1) {
          throw Exception(
            'Multiple mangas updated on title ${entry.key.title}',
          );
        }

        final updatedManga = updatesManga.firstOrNull;

        if (updatedManga == null) {
          throw Exception(
            'No mangas updated on title ${entry.key.title}',
          );
        }

        results.update(updatedManga, (old) => [], ifAbsent: () => []);

        for (final tag in entry.value) {
          final tagId = tag.id.valueOrNull;
          final matchTag = existingTags.firstWhereOrNull(
            (e) => [
              if (tagId != null) ...[
                e.id == tagId,
              ] else ...[
                e.name == tag.name.valueOrNull,
              ],
            ].every((isTrue) => isTrue),
          );

          final updatesTag = matchTag != null
              ? await updateTag(tag.copyWith(id: Value(matchTag.id)))
              : [await insertTag(tag)];

          if (updatesTag.length > 1) {
            throw Exception(
              'Multiple tag updated on tag name ${tag.name.valueOrNull}',
            );
          }

          final updatedTag = updatesTag.firstOrNull;

          if (updatedTag == null) {
            throw Exception(
              'No manga updated on tag ${tag.name.valueOrNull}',
            );
          }

          results.update(
            updatedManga,
            (old) => [...old, updatedTag],
            ifAbsent: () => [updatedTag],
          );
        }

        await unlinkAllTagFromManga(updatedManga.id);

        final tagIds = results[updatedManga]?.map((e) => e.id);
        if (tagIds != null) {
          await linkTagToManga(updatedManga.id, tagIds);
        }
      }

      return results;
    });
  }

  Future<List<MangaDrift>> searchMangas({
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
      ...ids.nonEmpty.distinct,
      ...titles.nonEmpty.distinct,
      ...coverUrls.nonEmpty.distinct,
      ...authors.nonEmpty.distinct,
      ...statuses.nonEmpty.distinct,
      ...descriptions.nonEmpty.distinct,
      ...webUrls.nonEmpty.distinct,
      ...sources.nonEmpty.distinct,
    ].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(mangaTables)
      ..where(
        (f) => [
          f.id.isIn(ids.nonEmpty.distinct),
          for (final e in titles.nonEmpty.distinct) f.title.like('%$e%'),
          for (final e in coverUrls.nonEmpty.distinct) f.coverUrl.like('%$e%'),
          for (final e in authors.nonEmpty.distinct) f.author.like('%$e%'),
          for (final e in statuses.nonEmpty.distinct) f.status.like('%$e%'),
          for (final e in descriptions.nonEmpty.distinct)
            f.description.like('%$e%'),
          for (final e in webUrls.nonEmpty.distinct) f.webUrl.like('%$e%'),
          for (final e in sources.nonEmpty.distinct) f.source.like('%$e%'),
        ].reduce((a, b) => a | b),
      );

    return transaction(() => selector.get());
  }

  Future<(MangaDrift, List<TagDrift>)?> getManga(String mangaId) async {
    return transaction(() async {
      final selector = select(mangaTables).join(
        [
          leftOuterJoin(
            relationshipTables,
            relationshipTables.mangaId.equalsExp(
              mangaTables.id,
            ),
          ),
          leftOuterJoin(
            tagTables,
            relationshipTables.tagId.equalsExp(tagTables.id),
          ),
        ],
      );

      final results = await selector.get();

      final groups =
          results.groupListsBy((e) => e.readTableOrNull(mangaTables)).map(
                (key, value) => MapEntry(
                  key,
                  [...value.map((e) => e.readTableOrNull(tagTables)).nonNulls],
                ),
              );

      final data = [
        for (final key in groups.keys.nonNulls)
          (key, groups[key] ?? <TagDrift>[]),
      ];

      return data.firstOrNull;
    });
  }

  Future<List<MangaDrift>> updateManga(MangaTablesCompanion data) {
    final selector = update(mangaTables)..whereSamePrimaryKey(data);

    return transaction(
      () => selector.writeReturning(
        data.copyWith(
          id: const Value.absent(),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
      ),
    );
  }

  Future<MangaDrift> insertManga(MangaTablesCompanion data) {
    return transaction(
      () => into(mangaTables).insertReturning(
        data.copyWith(
          id: Value(data.id.valueOrNull ?? const Uuid().v4().toString()),
          createdAt: Value(DateTime.now().toIso8601String()),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
        onConflict: DoUpdate(
          (old) => data.copyWith(
            id: Value(const Uuid().v4().toString()),
            createdAt: Value(DateTime.now().toIso8601String()),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        ),
      ),
    );
  }

  Future<List<TagDrift>> searchTags({
    List<String> ids = const [],
    List<String> names = const [],
  }) async {
    final isAllEmpty = [
      ...ids.nonEmpty.distinct,
      ...names.nonEmpty.distinct,
    ].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(tagTables)
      ..where(
        (f) => [
          f.id.isIn(ids.nonEmpty.distinct),
          f.name.isIn(names.nonEmpty.distinct),
        ].reduce((a, b) => a | b),
      );

    return transaction(() => selector.get());
  }

  Future<List<TagDrift>> updateTag(TagTablesCompanion data) {
    final selector = update(tagTables)..whereSamePrimaryKey(data);

    return transaction(
      () => selector.writeReturning(
        data.copyWith(updatedAt: Value(DateTime.now().toIso8601String())),
      ),
    );
  }

  Future<TagDrift> insertTag(TagTablesCompanion data) {
    return transaction(
      () => into(tagTables).insertReturning(
        data.copyWith(
          id: Value(data.id.valueOrNull ?? const Uuid().v4().toString()),
          createdAt: Value(DateTime.now().toIso8601String()),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
        onConflict: DoUpdate(
          (old) => data.copyWith(
            id: Value(const Uuid().v4().toString()),
            createdAt: Value(DateTime.now().toIso8601String()),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        ),
      ),
    );
  }

  Future<void> unlinkAllTagFromManga(String mangaId) {
    final selector = delete(relationshipTables)
      ..where((f) => f.mangaId.equals(mangaId));

    return transaction(() => selector.go());
  }

  Future<void> linkTagToManga(String mangaId, Iterable<String> tagIds) {
    return transaction(
      () async {
        for (final tagId in tagIds) {
          await into(relationshipTables).insert(
            RelationshipTablesCompanion.insert(
              tagId: tagId,
              mangaId: mangaId,
            ),
          );
        }
      },
    );
  }
}
