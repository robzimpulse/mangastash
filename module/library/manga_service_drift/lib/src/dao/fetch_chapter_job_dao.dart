import 'package:drift/drift.dart';

import '../database/database.dart';
import '../tables/fetch_chapter_job_tables.dart';

part 'fetch_chapter_job_dao.g.dart';

@DriftAccessor(
  tables: [
    FetchChapterJobTables,
  ],
)
class FetchChapterJobDao extends DatabaseAccessor<AppDatabase>
    with _$FetchChapterJobDaoMixin {
  FetchChapterJobDao(AppDatabase db) : super(db);

  Stream<List<FetchChapterJobDrift>> listen() {
    return select(fetchChapterJobTables).watch();
  }

  Future<void> add(FetchChapterJobTablesCompanion value) async {
    await into(fetchChapterJobTables).insert(
      value,
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> remove(FetchChapterJobTablesCompanion value) async {
    await (delete(fetchChapterJobTables)..whereSamePrimaryKey(value)).go();
  }
}
