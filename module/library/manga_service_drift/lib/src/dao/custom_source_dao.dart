import 'package:drift/drift.dart';
import '../database/database.dart';
import '../tables/custom_source_tables.dart';

part 'custom_source_dao.g.dart';

@DriftAccessor(tables: [CustomSourceTables])
class CustomSourceDao extends DatabaseAccessor<AppDatabase> with _$CustomSourceDaoMixin {
  CustomSourceDao(super.attachedDatabase);

  Future<List<CustomSourceDrift>> getAllSources() => select(customSourceTables).get();

  Future<int> insertSource(CustomSourceTablesCompanion source) =>
      into(customSourceTables).insert(source, mode: InsertMode.insertOrReplace);

  Future<int> deleteSource(int id) =>
      (delete(customSourceTables)..where((t) => t.id.equals(id))).go();
}
