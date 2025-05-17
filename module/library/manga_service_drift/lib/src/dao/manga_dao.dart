import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/value_or_null_extension.dart';
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
  MangaDao(AppDatabase db) : super(db);

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

  Future<MangaDrift?> getManga(String id) {
    final selector = select(mangaTables)
      ..whereSamePrimaryKey(MangaTablesCompanion.insert(id: id));

    return selector.getSingleOrNull();
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

  Future<List<TagDrift>> getTags(String mangaId) async {
    final selector = select(mangaTagRelationshipTables).join(
      [
        innerJoin(
          mangaTagTables,
          mangaTagTables.id.equalsExp(
            mangaTagRelationshipTables.mangaId,
          ),
        ),
      ],
    );

    final values = await selector.get();

    return values
        .map((e) => e.readTableOrNull(mangaTagTables))
        .nonNulls
        .toList();
  }

  Future<List<TagDrift>> updateTag(MangaTagTablesCompanion data) {
    final selector = update(mangaTagTables)..whereSamePrimaryKey(data);

    return transaction(
      () => selector.writeReturning(
        data.copyWith(updatedAt: Value(DateTime.now().toIso8601String())),
      ),
    );
  }

  Future<TagDrift> insertTag(MangaTagTablesCompanion data) {
    return transaction(
      () => into(mangaTagTables).insertReturning(
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
    final selector = delete(mangaTagRelationshipTables)
      ..where((f) => f.mangaId.equals(mangaId));

    return transaction(() => selector.go());
  }

  Future<void> linkTagToManga(String mangaId, Iterable<String> tagIds) {
    return transaction(
      () async {
        for (final tagId in tagIds) {
          await into(mangaTagRelationshipTables).insert(
            MangaTagRelationshipTablesCompanion.insert(
              tagId: tagId,
              mangaId: mangaId,
            ),
          );
        }
      },
    );
  }
}
