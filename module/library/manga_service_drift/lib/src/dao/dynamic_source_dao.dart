import 'package:drift/drift.dart';
import '../database/database.dart';
import '../tables/dynamic_source_tables.dart';

part 'dynamic_source_dao.g.dart';

@DriftAccessor(tables: [DynamicSourceTables])
class DynamicSourceDao extends DatabaseAccessor<AppDatabase> with _$DynamicSourceDaoMixin {
  DynamicSourceDao(super.db);

  Stream<List<DynamicSourceDrift>> watchAll() {
    return select(dynamicSourceTables).watch();
  }

  Future<List<DynamicSourceDrift>> getAll() {
    return select(dynamicSourceTables).get();
  }

  Future<int> insertOrUpdate(DynamicSourceTablesCompanion entry) {
    return into(dynamicSourceTables).insertOnConflictUpdate(entry);
  }

  Future<int> deleteSource(String id) {
    return (delete(dynamicSourceTables)..where((t) => t.id.equals(id))).go();
  }
}
