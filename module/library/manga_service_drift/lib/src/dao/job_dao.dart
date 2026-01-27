import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/transformers.dart';

import '../database/database.dart';
import '../model/job_model.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import '../tables/job_tables.dart';
import '../tables/manga_tables.dart';
import '../util/job_type_enum.dart';

part 'job_dao.g.dart';

@DriftAccessor(tables: [JobTables, MangaTables, ChapterTables, ImageTables])
class JobDao extends DatabaseAccessor<AppDatabase> with _$JobDaoMixin {
  JobDao(super.db);

  InsertStatement<$JobTablesTable, JobDrift> get _inserter {
    return into(jobTables);
  }

  SimpleSelectStatement<$JobTablesTable, JobDrift> get _selector {
    return select(jobTables);
  }

  DeleteStatement<$JobTablesTable, JobDrift> get _deleter {
    return delete(jobTables);
  }

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return _selector.join([
      leftOuterJoin(mangaTables, mangaTables.id.equalsExp(jobTables.mangaId)),
      leftOuterJoin(
        chapterTables,
        chapterTables.id.equalsExp(jobTables.chapterId),
      ),
    ]);
  }

  List<JobModel> _parse(List<TypedResult> rows) {
    final data = <JobModel>[];

    for (final row in rows) {
      final id = row.read(jobTables.id);
      final type = JobTypeEnum.values.firstWhereOrNull(
        (e) => e.name == row.read(jobTables.type),
      );
      if (id != null && type != null) {
        data.add(
          JobModel(
            id: id,
            type: type,
            manga: row.readTableOrNull(mangaTables),
            chapter: row.readTableOrNull(chapterTables),
            image: row.read(jobTables.imageUrl),
            path: row.read(jobTables.path),
          ),
        );
      }
    }

    return data;
  }

  Stream<List<JobModel>> get streamChapterIds {
    final selector = _aggregate..where(jobTables.chapterId.isNotNull());
    return selector.watch().map(_parse);
  }

  Stream<List<JobModel>> get streamMangaIds {
    final selector = _aggregate..where(jobTables.mangaId.isNotNull());
    return selector.watch().map(_parse);
  }

  Stream<JobModel?> get single {
    final selector = _aggregate..limit(1);
    return selector.watchSingleOrNull().map(
      (e) => _parse([e].nonNulls.toList()).firstOrNull,
    );
  }

  Stream<List<JobModel>> get stream => _aggregate.watch().map(_parse);

  Stream<int> get count {
    final counts = jobTables.id.count();
    final query = selectOnly(jobTables)..addColumns([counts]);
    return query.watchSingle().map((e) => e.read(counts)).whereNotNull();
  }

  Future<void> add(JobTablesCompanion value) {
    return transaction(
      () => _inserter.insert(value, mode: InsertMode.insertOrIgnore),
    );
  }

  Future<void> remove(int id) async {
    await transaction(() => (_deleter..where((f) => f.id.equals(id))).go());
  }
}
