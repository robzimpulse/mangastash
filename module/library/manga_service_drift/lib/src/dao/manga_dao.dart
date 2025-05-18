import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/value_or_null_extension.dart';
import '../tables/manga_library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/manga_tag_relationship_tables.dart';
import '../tables/manga_tag_tables.dart';

part 'manga_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    MangaTagTables,
    MangaTagRelationshipTables,
    MangaLibraryTables,
  ],
)
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  MangaDao(AppDatabase db) : super(db);

  Stream<Iterable<MangaDrift>> listenLibrary() {
    final selector = select(mangaLibraryTables).join(
      [
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(mangaLibraryTables.mangaId),
        ),
      ],
    );

    final stream = selector.watch();

    return stream.map(
      (rows) => rows.map((row) => row.readTableOrNull(mangaTables)).nonNulls,
    );
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
    final isAllEmpty = [
      ...ids.nonEmpty.distinct,
      ...names.nonEmpty.distinct,
    ].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(mangaTagTables)
      ..where(
        (f) => [
          f.id.isIn(ids.nonEmpty.distinct),
          f.name.isIn(names.nonEmpty.distinct),
        ].reduce((a, b) => a | b),
      );

    return selector.get();
  }

  Future<List<TagDrift>> getTags(String mangaId) async {
    final selector = select(mangaTagRelationshipTables)
      ..where((f) => f.mangaId.equals(mangaId));

    final tagIds = await selector.get();

    final result = select(mangaTagTables)
      ..where((f) => f.id.isIn(tagIds.map((e) => e.tagId)));

    return result.get();
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
