import 'package:drift/drift.dart';

import '../database/database.dart';
import '../tables/job_tables.dart';

part 'prefetch_job_dao.g.dart';

@DriftAccessor(
  tables: [
    JobTables,
  ],
)
class PrefetchJobDao extends DatabaseAccessor<AppDatabase>
    with _$PrefetchJobDaoMixin {
  PrefetchJobDao(AppDatabase db) : super(db);

  Stream<List<JobDrift>> listen() {
    return select(jobTables).watch();
  }

  Future<void> add(JobTablesCompanion value) async {
    await into(jobTables).insert(
      value.copyWith(
        createdAt: Value(DateTime.now().toIso8601String()),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> remove(JobTablesCompanion value) async {
    await (delete(jobTables)..whereSamePrimaryKey(value)).go();
  }
}
