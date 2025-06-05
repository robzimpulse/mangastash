import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
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

      await _tagDao.detach(mangaIds: [...results.map((e) => e.id)]);

      final data = <MangaModel>[];
      for (final result in results) {
        final old = olds.firstWhereOrNull((e) => e.manga?.id == result.id);
        data.add(MangaModel(manga: result, tags: [...?old?.tags]));
      }

      return data;
    });
  }

  Future<MangaModel> add({
    required MangaTablesCompanion value,
    List<String> tags = const [],
  }) {
    return transaction(() async {
      /// if conflict, update chapter otherwise insert chapter
      final result = await into(mangaTables).insertReturning(
        value,
        mode: InsertMode.insertOrReplace,
        onConflict: DoUpdate(
          (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
        ),
      );

      /// update existing data with new data until all new data updated
      final List<TagDrift> updated = [];
      List<TagDrift> existing = await _tagDao.search(names: tags);
      for (final tag in tags) {
        final data = existing.isEmpty
            ? const TagTablesCompanion()
            : existing.removeAt(0).toCompanion(true);

        final value = await _tagDao.add(value: data.copyWith(name: Value(tag)));
        await _tagDao.attach(mangaId: result.id, tagId: value.id);
        updated.add(value);
      }

      /// detach all existing data that not added
      await _tagDao.detach(mangaIds: [result.id]);

      return MangaModel(manga: result, tags: updated);
    });
  }
}
