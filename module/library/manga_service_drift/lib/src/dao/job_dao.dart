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

  Stream<List<JobDetail>> listen() {
    final selector = select(jobTables).join(
      [
        leftOuterJoin(
          mangaTables,
          mangaTables.id.equalsExp(jobTables.mangaId),
        ),
        leftOuterJoin(
          chapterTables,
          chapterTables.id.equalsExp(jobTables.chapterId),
        ),
        leftOuterJoin(
          imageTables,
          imageTables.chapterId.equalsExp(jobTables.imageId),
        ),
      ],
    );

    final stream = selector.watch();

    return stream.map(
      (events) {
        final data = <JobDetail>[];
        for (final event in events) {
          final id = event.read(jobTables.id);
          final type = JobTypeEnum.values.firstWhereOrNull(
            (e) => e.name == event.read(jobTables.type),
          );
          if (id != null && type != null) {
            data.add(
              JobDetail(
                id: id,
                type: type,
                manga: event.readTableOrNull(mangaTables),
                chapter: event.readTableOrNull(chapterTables),
                image: event.readTableOrNull(imageTables),
              ),
            );
          }
        }
        return data;
      },
    );

    // return select(jobTables).watch();
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

  Future<List<ImageDrift>> getImageIds(List<String> urls) async {
    if (urls.isEmpty) return [];
    final selector = select(imageTables)..where((f) => f.webUrl.isIn(urls));
    return transaction(() => selector.get());
  }
}
