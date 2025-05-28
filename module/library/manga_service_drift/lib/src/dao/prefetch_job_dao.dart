import 'package:drift/drift.dart';

import '../database/database.dart';
import '../tables/prefetch_job_tables.dart';

part 'prefetch_job_dao.g.dart';

@DriftAccessor(
  tables: [
    PrefetchJobTables,
  ],
)
class PrefetchJobDao extends DatabaseAccessor<AppDatabase>
    with _$PrefetchJobDaoMixin {
  PrefetchJobDao(AppDatabase db) : super(db);

  Stream<List<PrefetchJobDrift>> listen() {
    return select(prefetchJobTables).watch();
  }

  Future<void> add(PrefetchJobTablesCompanion value) async {
    await into(prefetchJobTables).insert(
      value.copyWith(
        createdAt: Value(DateTime.now().toIso8601String()),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> remove(PrefetchJobTablesCompanion value) async {
    await (delete(prefetchJobTables)..whereSamePrimaryKey(value)).go();
  }
}
