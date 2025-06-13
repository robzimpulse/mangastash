import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../manga_service_drift.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/nullable_generic.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';

part 'tag_dao.g.dart';

@DriftAccessor(
  tables: [
    TagTables,
    RelationshipTables,
  ],
)
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(AppDatabase db) : super(db);

  SimpleSelectStatement<$TagTablesTable, TagDrift> get _selector {
    return select(tagTables);
  }

  DeleteStatement<$TagTablesTable, TagDrift> get _deleter {
    return delete(tagTables);
  }

  Expression<bool> _filter({
    required $TagTablesTable f,
    List<String> ids = const [],
    List<String> names = const [],
    List<String> sources = const [],
  }) {
    return [
      f.id.isIn(ids.nonEmpty.distinct),
      f.name.isIn(names.nonEmpty.distinct),
      f.source.isIn(sources.nonEmpty.distinct),
    ].fold(const Constant(false), (a, b) => a | b);
  }

  Future<List<TagDrift>> get all => _selector.get();

  Future<List<TagDrift>> search({
    List<String> ids = const [],
    List<String> names = const [],
    List<String> sources = const [],
  }) {
    final selector = _selector
      ..where(
        (f) => _filter(
          f: f,
          ids: ids,
          names: names,
          sources: sources,
        ),
      );
    return transaction(() => selector.get());
  }

  Future<List<TagDrift>> remove({
    List<String> ids = const [],
    List<String> names = const [],
    List<String> sources = const [],
  }) {
    final selector = _deleter
      ..where(
        (f) => _filter(
          f: f,
          ids: ids,
          names: names,
          sources: sources,
        ),
      );
    return transaction(() => selector.goAndReturn());
  }

  Future<List<TagDrift>> adds({required List<TagTablesCompanion> values}) {
    return transaction(() async {
      final tags = await search(
        ids: [...values.map((e) => e.id.valueOrNull).nonNulls],
        names: [...values.map((e) => e.name.valueOrNull).nonNulls],
        sources: [...values.map((e) => e.source.valueOrNull).nonNulls],
      );

      final data = <TagDrift>[];

      for (final entry in values) {
        final byId = entry.id.valueOrNull?.let(
          (id) => tags.firstWhereOrNull((e) => e.id == id),
        );
        final byName = entry.name.valueOrNull?.let(
          (name) => tags.firstWhereOrNull((e) => e.name == name),
        );

        final tag = (byId ?? byName);

        final value = entry.copyWith(
          id: Value.absentIfNull(
            entry.id.valueOrNull ?? tag?.id,
          ),
          name: Value.absentIfNull(
            entry.name.valueOrNull ?? tag?.name,
          ),
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

  Future<TagDrift> add({required TagTablesCompanion value}) {
    return transaction(
      () => into(tagTables).insertReturning(
        value.copyWith(
          createdAt: Value(DateTime.timestamp()),
          updatedAt: Value(DateTime.timestamp()),
        ),
        mode: InsertMode.insertOrIgnore,
        onConflict: DoUpdate(
          (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
        ),
      ),
    );
  }

  Future<void> attach({required String mangaId, required String tagId}) {
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

  Future<void> detach({
    required String mangaId,
    String? tagId,
  }) async {
    final selector = delete(relationshipTables)
      ..where(
        (f) => [
          f.mangaId.equals(mangaId),
          if (tagId != null) f.tagId.equals(tagId),
        ].reduce((a, b) => a & b),
      );

    return transaction(() => selector.go());
  }
}
