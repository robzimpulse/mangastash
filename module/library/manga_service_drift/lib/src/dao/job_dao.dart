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
    ])..orderBy([OrderingTerm.asc(jobTables.id)]);
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

  /// Inserts [value], skipping the row when an identical one is still in
  /// the queue (same type plus equal payload columns, NULL == NULL).
  ///
  /// Rows leave the table only in `JobManager`'s `finally`, so a live row
  /// may be queued or mid-execution — either suppresses a re-enqueue. The
  /// check and insert are atomic because drift serializes `transaction()`s
  /// on the single [AppDatabase] connection; moving the SELECT outside the
  /// transaction or introducing a second connection/isolate would let two
  /// concurrent `add`s of the same payload both pass the check.
  ///
  /// The dedup is row-based, not in-flight: once the executor picks a job up
  /// and its row is removed, a re-enqueue of the same payload inserts again
  /// and may duplicate the work. The downstream layers already tolerate a
  /// double-run (webview fetch de-dupes by URL; `FileDao.addFromFile` writes
  /// a fresh UUID destination), so the residual cost is one orphan file
  /// until `sync()` — a known boundary, not a correctness bug.
  Future<void> add(JobTablesCompanion value) async {
    await transaction(() async {
      final type = value.type.present ? value.type.value : null;
      if (type == null) {
        await _inserter.insert(value, mode: InsertMode.insertOrIgnore);
        return;
      }

      final selector = _selector
        ..where(
          (f) =>
              f.type.equals(type.name) &
              _nullableEquals(f.source, _read(value.source)) &
              _nullableEquals(f.mangaId, _read(value.mangaId)) &
              _nullableEquals(f.chapterId, _read(value.chapterId)) &
              _nullableEquals(f.imageUrl, _read(value.imageUrl)) &
              _nullableEquals(f.path, _read(value.path)),
        )
        ..limit(1);

      final existing = await selector.get();
      if (existing.isNotEmpty) return;

      await _inserter.insert(value, mode: InsertMode.insertOrIgnore);
    });
  }

  String? _read(Value<String?> field) => field.present ? field.value : null;

  Expression<bool> _nullableEquals(Column<String> column, String? value) {
    return value == null ? column.isNull() : column.equals(value);
  }

  Future<void> remove(int id) async {
    await transaction(() => (_deleter..where((f) => f.id.equals(id))).go());
  }
}
