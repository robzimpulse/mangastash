import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../database/database.dart';
import '../extension/companion_equality.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/nullable_generic.dart';
import '../extension/value_or_null_extension.dart';
import '../model/manga_model.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';
import 'tag_dao.dart';

part 'manga_dao.g.dart';

@DriftAccessor(tables: [MangaTables, TagTables, RelationshipTables])
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  MangaDao(super.db);

  late final TagDao _tagDao = TagDao(db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return select(mangaTables).join([
      leftOuterJoin(
        relationshipTables,
        relationshipTables.mangaId.equalsExp(mangaTables.id),
      ),
      leftOuterJoin(
        tagTables,
        relationshipTables.tagId.equalsExp(tagTables.id),
      ),
    ]);
  }

  List<MangaModel> _parse(List<TypedResult> rows) {
    final data = <MangaModel>[];

    final groups = rows.groupListsBy((e) => e.readTableOrNull(mangaTables));

    for (final key in groups.keys.nonNulls) {
      data.add(
        MangaModel(
          manga: key,
          tags: [
            ...?groups[key]?.map((e) => e.readTableOrNull(tagTables)).nonNulls,
          ],
        ),
      );
    }

    return data;
  }

  @visibleForTesting
  Future<List<MangaModel>> get all => _aggregate.get().then(_parse);

  Future<List<MangaModel>> search({
    List<String> ids = const [],
    List<String> titles = const [],
    List<String> coverUrls = const [],
    List<String> authors = const [],
    List<String> statuses = const [],
    List<String> descriptions = const [],
    List<String> webUrls = const [],
    List<String> sources = const [],
    List<String> tags = const [],
  }) {
    final filter = [
      mangaTables.id.isIn(ids.nonEmpty.distinct),
      mangaTables.title.isIn(titles.nonEmpty.distinct),
      mangaTables.coverUrl.isIn(coverUrls.nonEmpty.distinct),
      mangaTables.author.isIn(authors.nonEmpty.distinct),
      mangaTables.status.isIn(statuses.nonEmpty.distinct),
      mangaTables.description.isIn(descriptions.nonEmpty.distinct),
      mangaTables.webUrl.isIn(webUrls.nonEmpty.distinct),
      mangaTables.source.isIn(sources.nonEmpty.distinct),
      tagTables.name.isIn(tags.nonEmpty.distinct),
    ].fold<Expression<bool>>(const Constant(false), (a, b) => a | b);

    final selector = _aggregate..where(filter);

    return transaction(() => selector.get().then((e) => _parse(e)));
  }

  Future<List<MangaModel>> remove({
    List<String> ids = const [],
    List<String> titles = const [],
    List<String> coverUrls = const [],
    List<String> authors = const [],
    List<String> statuses = const [],
    List<String> descriptions = const [],
    List<String> webUrls = const [],
    List<String> sources = const [],
  }) {
    Expression<bool> filter($MangaTablesTable f) {
      return [
        f.id.isIn(ids.nonEmpty.distinct),
        f.title.isIn(titles.nonEmpty.distinct),
        f.coverUrl.isIn(coverUrls.nonEmpty.distinct),
        f.author.isIn(authors.nonEmpty.distinct),
        f.status.isIn(statuses.nonEmpty.distinct),
        f.description.isIn(descriptions.nonEmpty.distinct),
        f.webUrl.isIn(webUrls.nonEmpty.distinct),
        f.source.isIn(sources.nonEmpty.distinct),
      ].fold(const Constant(false), (a, b) => a | b);
    }

    final selector = delete(mangaTables)..where(filter);

    return transaction(() async {
      final olds = await search(
        ids: ids,
        titles: titles,
        coverUrls: coverUrls,
        authors: authors,
        statuses: statuses,
        descriptions: descriptions,
        webUrls: webUrls,
        sources: sources,
      );

      final results = await selector.goAndReturn();

      final data = <MangaModel>[];
      for (final result in results) {
        await _tagDao.detach(mangaId: result.id);
        final old = olds.firstWhereOrNull((e) => e.manga?.id == result.id);
        data.add(MangaModel(manga: result, tags: [...?old?.tags]));
      }

      return data;
    });
  }

  Future<List<MangaModel>> adds({
    required Map<MangaTablesCompanion, List<String>> values,
  }) {
    if (values.isEmpty) return Future.value([]);

    return transaction(() async {
      final ids = values.keys.map((e) => e.id.valueOrNull).nonNulls.toList();
      final webUrls =
          values.keys.map((e) => e.webUrl.valueOrNull).nonNulls.toList();
      final titles =
          values.keys.map((e) => e.title.valueOrNull).nonNulls.toList();
      final sources =
          values.keys.map((e) => e.source.valueOrNull).nonNulls.toList();

      final mangas = await search(
        ids: ids,
        webUrls: webUrls,
        titles: titles,
        sources: sources,
      );

      final toInsert = <MangaTablesCompanion>[];
      final tagReattaches = <String, List<String>>{};

      for (final entry in values.entries) {
        final byId = entry.key.id.valueOrNull?.let(
          (id) => mangas.firstWhereOrNull((e) => e.manga?.id == id),
        );
        final byWebUrl = entry.key.webUrl.valueOrNull?.let(
          (webUrl) => mangas.firstWhereOrNull((e) => e.manga?.webUrl == webUrl),
        );
        final byTitleAndSource = entry.key.title.valueOrNull?.let(
          (title) => entry.key.source.valueOrNull?.let(
            (source) => mangas.firstWhereOrNull(
              (e) => e.manga?.title == title && e.manga?.source == source,
            ),
          ),
        );

        final manga = (byId ?? byWebUrl ?? byTitleAndSource);

        if (manga != null) {
          final companion = manga.manga?.toCompanion(true);
          final id = manga.manga?.id;
          final source = manga.manga?.source;
          final shouldUpdate = companion?.shouldUpdate(entry.key) == true;

          if (!shouldUpdate && id != null && source != null) {
            tagReattaches[id] = [
              ...{...entry.value, ...manga.tags.map((e) => e.name).nonNulls},
            ];
            continue;
          }
        }

        final mangaId = entry.key.id.valueOrNull ?? manga?.manga?.id;
        if (mangaId == null) continue;

        final value = entry.key.copyWith(
          id: Value(mangaId),
          title: Value.absentIfNull(
            entry.key.title.valueOrNull ?? manga?.manga?.title,
          ),
          coverUrl: Value.absentIfNull(
            entry.key.coverUrl.valueOrNull ?? manga?.manga?.coverUrl,
          ),
          author: Value.absentIfNull(
            entry.key.author.valueOrNull ?? manga?.manga?.author,
          ),
          status: Value.absentIfNull(
            entry.key.status.valueOrNull ?? manga?.manga?.status,
          ),
          description: Value.absentIfNull(
            entry.key.description.valueOrNull ?? manga?.manga?.description,
          ),
          webUrl: Value.absentIfNull(
            entry.key.webUrl.valueOrNull ?? manga?.manga?.webUrl,
          ),
          source: Value.absentIfNull(
            entry.key.source.valueOrNull ?? manga?.manga?.source,
          ),
          createdAt: Value.absentIfNull(
            entry.key.createdAt.valueOrNull ?? manga?.manga?.createdAt,
          ),
          updatedAt: Value.absentIfNull(
            entry.key.updatedAt.valueOrNull ?? manga?.manga?.updatedAt,
          ),
        );

        toInsert.add(value);
        tagReattaches[mangaId] = [
          ...{...entry.value, ...?manga?.tags.map((e) => e.name).nonNulls},
        ];
      }

      if (toInsert.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            mangaTables,
            toInsert,
            mode: InsertMode.insertOrReplace,
          );
        });
      }

      if (tagReattaches.isNotEmpty) {
        await _tagDao.reattachMultiple(
          values: tagReattaches.map(
            (key, value) => MapEntry(key, (
              source:
                  values.keys
                      .firstWhereOrNull((e) => e.id.valueOrNull == key)
                      ?.source
                      .valueOrNull,
              tags: value,
            )),
          ),
        );
      }

      return search(
        ids: ids,
        webUrls: webUrls,
        titles: titles,
        sources: sources,
      );
    });
  }
}
