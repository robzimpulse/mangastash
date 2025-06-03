import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/value_or_null_extension.dart';
import '../tables/tag_tables.dart';

part 'tag_dao.g.dart';

@DriftAccessor(
  tables: [
    TagTables,
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
          id: Value(value.id.valueOrNull ?? const Uuid().v4().toString()),
          createdAt: Value(DateTime.now().toIso8601String()),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
        onConflict: DoUpdate(
          (old) => value.copyWith(
            id: const Value.absent(),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        ),
      ),
    );
  }
}
