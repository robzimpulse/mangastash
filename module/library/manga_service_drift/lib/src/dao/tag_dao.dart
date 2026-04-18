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
    if (values.isEmpty) return Future.value([]);

    return transaction(() async {
      final tagIds = values.map((e) => e.tagId.valueOrNull).nonNulls.toList();
      final names = values.map((e) => e.name.valueOrNull).nonNulls.toList();
      final sources = values.map((e) => e.source.valueOrNull).nonNulls.toList();

      final tags = await search(
        tagIds: tagIds,
        names: names,
        sources: sources,
      );

      final toInsert = <TagTablesCompanion>[];

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
          final shouldUpdate = companion.shouldUpdate(entry) == true;
          if (!shouldUpdate) {
            continue;
          }
        }

        toInsert.add(
          entry.copyWith(
            id: Value.absentIfNull(entry.id.valueOrNull ?? tag?.id),
            tagId: Value.absentIfNull(entry.tagId.valueOrNull ?? tag?.tagId),
            name: Value.absentIfNull(entry.name.valueOrNull ?? tag?.name),
          ),
        );
      }

      if (toInsert.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            tagTables,
            toInsert,
            mode: InsertMode.insertOrReplace,
          );
        });
      }

      return search(tagIds: tagIds, names: names, sources: sources);
    });
  }

  Future<void> reattachMultiple({
    required Map<String, ({String? source, List<String> tags})> values,
  }) async {
    if (values.isEmpty) return;

    return transaction(() async {
      final mangaIds = values.keys.toList();
      await detachMultiple(mangaIds: mangaIds);

      final toAdd = <({String? source, String name})>{};
      for (final entry in values.values) {
        for (final name in entry.tags) {
          toAdd.add((source: entry.source, name: name));
        }
      }

      final tags = await adds(
        values: [
          for (final item in toAdd)
            TagTablesCompanion.insert(
              name: item.name,
              source: Value.absentIfNull(item.source),
            ),
        ],
      );

      final tagMap = <({String? source, String name}), int>{};
      for (final t in tags) {
        tagMap[(source: t.source, name: t.name)] = t.id;
      }

      await batch((batch) {
        for (final entry in values.entries) {
          final mangaId = entry.key;
          final source = entry.value.source;
          for (final tagName in entry.value.tags) {
            final tagId = tagMap[(source: source, name: tagName)];
            if (tagId != null) {
              batch.insert(
                relationshipTables,
                RelationshipTablesCompanion.insert(
                  mangaId: mangaId,
                  tagId: tagId,
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        }
      });
    });
  }

  Future<List<TagDrift>> reattach({
    required String mangaId,
    String? source,
    List<String> values = const [],
  }) async {
    await reattachMultiple(
      values: {
        mangaId: (source: source, tags: values),
      },
    );
    return search(names: values, sources: [if (source != null) source]);
  }

  Future<void> attach({required String mangaId, required int tagId}) {
    return transaction(() {
      final value = RelationshipTablesCompanion(
        mangaId: Value(mangaId),
        tagId: Value(tagId),
      );

      final clause = into(relationshipTables);

      return clause.insert(value, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> detach({required String mangaId, int? tagId}) async {
    return detachMultiple(mangaId: mangaId, tagId: tagId);
  }

  Future<void> detachMultiple({
    String? mangaId,
    List<String> mangaIds = const [],
    int? tagId,
  }) async {
    final selector =
        delete(relationshipTables)..where(
          (f) => [
            if (mangaId != null) f.mangaId.equals(mangaId),
            if (mangaIds.isNotEmpty) f.mangaId.isIn(mangaIds),
            if (tagId != null) f.tagId.equals(tagId),
          ].reduce((a, b) => a & b),
        );

    return transaction(() => selector.go());
  }
}
