import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../../manga_service_drift.dart';
import '../extension/companion_equality.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/nullable_generic.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [TagTables, RelationshipTables])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  SimpleSelectStatement<$TagTablesTable, TagDrift> get _selector {
    return select(tagTables);
  }

  DeleteStatement<$TagTablesTable, TagDrift> get _deleter {
    return delete(tagTables);
  }

  Expression<bool> _filter({
    required $TagTablesTable f,
    List<int> ids = const [],
    List<String> tagIds = const [],
    List<String> names = const [],
    List<String> sources = const [],
  }) {
    return [
      f.id.isIn(ids.distinct),
      f.tagId.isIn(tagIds.nonEmpty.distinct),
      f.name.isIn(names.nonEmpty.distinct),
      f.source.isIn(sources.nonEmpty.distinct),
    ].fold(const Constant(false), (a, b) => a | b);
  }

  @visibleForTesting
  Future<List<TagDrift>> get all => _selector.get();

  Future<List<TagDrift>> search({
    List<int> ids = const [],
    List<String> tagIds = const [],
    List<String> names = const [],
    List<String> sources = const [],
  }) {
    final selector =
        _selector..where(
          (f) => _filter(
            f: f,
            ids: ids,
            tagIds: tagIds,
            names: names,
            sources: sources,
          ),
        );
    return transaction(() => selector.get());
  }

  Future<List<TagDrift>> remove({
    List<int> ids = const [],
    List<String> tagIds = const [],
    List<String> names = const [],
    List<String> sources = const [],
  }) {
    final selector =
        _deleter..where(
          (f) => _filter(
            f: f,
            ids: ids,
            tagIds: tagIds,
            names: names,
            sources: sources,
          ),
        );
    return transaction(() => selector.goAndReturn());
  }

  Future<List<TagDrift>> adds({required List<TagTablesCompanion> values}) {
    return transaction(() async {
      final tags = await search(
        tagIds: [...values.map((e) => e.tagId.valueOrNull).nonNulls],
        names: [...values.map((e) => e.name.valueOrNull).nonNulls],
        sources: [...values.map((e) => e.source.valueOrNull).nonNulls],
      );

      final data = <TagDrift>[];

      for (final entry in values) {
        final byTagId = entry.tagId.valueOrNull?.let(
          (id) => tags.firstWhereOrNull(
            (e) => e.tagId == id && e.source == entry.source.valueOrNull,
          ),
        );
        final byName = entry.name.valueOrNull?.let(
          (name) => tags.firstWhereOrNull(
            (e) => e.name == name && e.source == entry.source.valueOrNull,
          ),
        );

        final tag = (byTagId ?? byName);

        if (tag != null) {
          final companion = tag.toCompanion(true);
          // final id = tag.id;
          // final source = manga.manga?.source;
          if (companion.shouldUpdate(entry) == false) {
            data.add(tag);
            continue;
          }
        }

        final value = entry.copyWith(
          id: Value.absentIfNull(entry.id.valueOrNull ?? tag?.id),
          tagId: Value.absentIfNull(entry.tagId.valueOrNull ?? tag?.tagId),
          name: Value.absentIfNull(entry.name.valueOrNull ?? tag?.name),
        );

        final result = await into(tagTables).insertReturning(
          value,
          mode: InsertMode.insertOrReplace,
          onConflict: DoUpdate(
            (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
          ),
        );

        data.add(result);
      }

      return data;
    });
  }

  Future<List<TagDrift>> reattach({
    required String mangaId,
    String? source,
    List<String> values = const [],
  }) async {
    if (values.isEmpty) return Future.value([]);

    return transaction(() async {
      await detach(mangaId: mangaId);

      final tags = await adds(
        values: [
          for (final name in values)
            TagTablesCompanion.insert(
              name: name,
              source: Value.absentIfNull(source),
            ),
        ],
      );

      for (final tag in tags) {
        await attach(mangaId: mangaId, tagId: tag.id);
      }

      return tags;
    });
  }

  Future<void> attach({required String mangaId, required int tagId}) {
    final value = RelationshipTablesCompanion(
      mangaId: Value(mangaId),
      tagId: Value(tagId),
    );
    return transaction(
      () => into(relationshipTables).insert(
        value.copyWith(
          createdAt: Value(DateTime.timestamp()),
          updatedAt: Value(DateTime.timestamp()),
        ),
        mode: InsertMode.insertOrReplace,
        onConflict: DoUpdate(
          target: [relationshipTables.mangaId, relationshipTables.tagId],
          (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
        ),
      ),
    );
  }

  Future<void> detach({required String mangaId, int? tagId}) async {
    final selector = delete(relationshipTables)..where(
      (f) => [
        f.mangaId.equals(mangaId),
        if (tagId != null) f.tagId.equals(tagId),
      ].reduce((a, b) => a & b),
    );

    return transaction(() => selector.go());
  }
}
