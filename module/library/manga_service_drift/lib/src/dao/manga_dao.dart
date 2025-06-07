import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/nullable_generic.dart';
import '../extension/value_or_null_extension.dart';
import '../model/manga_model.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';
import 'tag_dao.dart';

part 'manga_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    TagTables,
    RelationshipTables,
  ],
)
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  MangaDao(AppDatabase db) : super(db);

  late final TagDao _tagDao = TagDao(db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return select(mangaTables).join(
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

  Stream<List<MangaModel>> get stream => _aggregate.watch().map(_parse);

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
    return transaction(() async {
      final mangas = await search(
        ids: [...values.keys.map((e) => e.id.valueOrNull).nonNulls],
        webUrls: [...values.keys.map((e) => e.webUrl.valueOrNull).nonNulls],
      );

      final data = <MangaModel>[];

      for (final entry in values.entries) {
        final byId = entry.key.id.valueOrNull?.let(
          (id) => mangas.firstWhereOrNull((e) => e.manga?.id == id),
        );
        final byWebUrl = entry.key.webUrl.valueOrNull?.let(
          (webUrl) => mangas.firstWhereOrNull((e) => e.manga?.webUrl == webUrl),
        );

        final manga = (byId ?? byWebUrl);

        final value = entry.key.copyWith(
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
        );

        final result = await into(mangaTables).insertReturning(
          value,
          mode: InsertMode.insertOrReplace,
          onConflict: DoUpdate(
            (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
          ),
        );

        final names = {
          ...entry.value,
          ...?manga?.tags.map((e) => e.name).nonNulls,
        };

        final tags = <TagDrift>[];
        await _tagDao.detach(mangaId: result.id);
        for (final name in names) {
          final tag = await _tagDao.add(
            value: TagTablesCompanion.insert(name: name),
          );
          await _tagDao.attach(mangaId: result.id, tagId: tag.id);
          tags.add(tag);
        }

        data.add(MangaModel(manga: result, tags: tags));
      }

      return data;
    });
  }
}
