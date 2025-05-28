import 'package:drift/drift.dart';

import '../database/database.dart';
import '../tables/download_job_tables.dart';

part 'download_job_dao.g.dart';

@DriftAccessor(
  tables: [
    DownloadJobTables,
  ],
)
class DownloadJobDao extends DatabaseAccessor<AppDatabase>
    with _$DownloadJobDaoMixin {
  DownloadJobDao(AppDatabase db) : super(db);

  Stream<List<DownloadJobDrift>> listen() {
    return select(downloadJobTables).watch();
  }

  Future<void> add(DownloadJobTablesCompanion value) async {
    await into(downloadJobTables).insert(
      value,
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> remove(DownloadJobTablesCompanion value) async {
    await (delete(downloadJobTables)..whereSamePrimaryKey(value)).go();
  }
}
