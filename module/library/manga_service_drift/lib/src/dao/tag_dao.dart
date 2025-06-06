import 'package:drift/drift.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
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
  }) {
    return [
      f.id.isIn(ids.nonEmpty.distinct),
      f.name.isIn(names.nonEmpty.distinct),
    ].fold(const Constant(false), (a, b) => a | b);
  }

  Future<List<TagDrift>> get all => _selector.get();

  Future<List<TagDrift>> search({
    List<String> ids = const [],
    List<String> names = const [],
  }) {
    final selector = _selector
      ..where(
        (f) => _filter(
          f: f,
          ids: ids,
          names: names,
        ),
      );
    return transaction(() => selector.get());
  }

  Future<List<TagDrift>> remove({
    List<String> ids = const [],
    List<String> names = const [],
  }) {
    final selector = _deleter
      ..where(
        (f) => _filter(
          f: f,
          ids: ids,
          names: names,
        ),
      );
    return transaction(() => selector.goAndReturn());
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
