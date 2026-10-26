/// Data access for `source_script_tables` (issue #115).
///
/// Provides observe/list/get/upsert/remove for user-editable JavaScript
/// source scripts.
///
/// Usage: obtain through the locator (`locator<SourceScriptDao>()`, registered
/// by `core_storage`) or construct with an [AppDatabase]. `upsert` replaces
/// the row with the same `id`; a row that reuses another script's `name`
/// throws a `SqliteException` (unique constraint), it never overwrites it.
library;

import 'package:drift/drift.dart';

import '../database/database.dart';
import '../tables/source_script_tables.dart';

part 'source_script_dao.g.dart';

@DriftAccessor(tables: [SourceScriptTables])
class SourceScriptDao extends DatabaseAccessor<AppDatabase>
    with _$SourceScriptDaoMixin {
  SourceScriptDao(super.db);

  SimpleSelectStatement<$SourceScriptTablesTable, SourceScriptDrift>
  get _ordered {
    return select(sourceScriptTables)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
  }

  Stream<List<SourceScriptDrift>> watchAll() => _ordered.watch();

  Future<List<SourceScriptDrift>> getAll() => _ordered.get();

  Future<SourceScriptDrift?> get(String id) {
    return (select(
      sourceScriptTables,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Inserts [row], or replaces the existing row with the same `id`.
  ///
  /// The conflict target is the primary key only, so a clash on `name` with a
  /// different id still throws instead of silently rewriting that row.
  Future<void> upsert(SourceScriptTablesCompanion row) async {
    final update = row.updatedAt.present
        ? row
        : row.copyWith(updatedAt: Value(DateTime.timestamp()));
    await into(sourceScriptTables).insert(
      row,
      onConflict: DoUpdate((_) => update, target: [sourceScriptTables.id]),
    );
  }

  Future<void> remove(String id) async {
    await (delete(sourceScriptTables)..where((t) => t.id.equals(id))).go();
  }
}
