import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../manga_service_drift.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import '../tables/job_tables.dart';
import '../tables/manga_tables.dart';

part 'job_dao.g.dart';

@DriftAccessor(
  tables: [
    JobTables,
    MangaTables,
    ChapterTables,
    ImageTables,
  ],
)
class JobDao extends DatabaseAccessor<AppDatabase> with _$JobDaoMixin {
  JobDao(AppDatabase db) : super(db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return select(jobTables).join(
      [
        leftOuterJoin(
          mangaTables,
          mangaTables.id.equalsExp(jobTables.mangaId),
        ),
        leftOuterJoin(
          chapterTables,
          chapterTables.id.equalsExp(jobTables.chapterId),
        ),
      ],
    );
  }

  List<JobDetail> _parse(List<TypedResult> rows) {
    final data = <JobDetail>[];

    for (final row in rows) {
      final id = row.read(jobTables.id);
      final type = JobTypeEnum.values.firstWhereOrNull(
        (e) => e.name == row.read(jobTables.type),
      );
      if (id != null && type != null) {
        data.add(
          JobDetail(
            id: id,
            type: type,
            manga: row.readTableOrNull(mangaTables),
            chapter: row.readTableOrNull(chapterTables),
            image: row.read(jobTables.imageUrl),
          ),
        );
      }
    }

    return data;
  }

  Stream<List<JobDetail>> get stream {
    return _aggregate.watch().map((e) => _parse(e));
  }

  Future<void> add(JobTablesCompanion value) async {
    await transaction(
      () => into(jobTables).insert(
        value.copyWith(
          createdAt: Value(DateTime.now().toIso8601String()),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
        mode: InsertMode.insertOrIgnore,
      ),
    );
  }

  Future<void> remove(int id) async {
    await transaction(
      () => (delete(jobTables)..where((f) => f.id.equals(id))).go(),
    );
  }
}
