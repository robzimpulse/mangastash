import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../tables/manga_chapter_image_tables.dart';
import '../tables/manga_chapter_tables.dart';

part 'chapter_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaChapterTables,
    MangaChapterImageTables,
  ],
)
class ChapterDao extends DatabaseAccessor<AppDatabase> with _$ChapterDaoMixin {
  ChapterDao(AppDatabase db) : super(db);

  Future<List<ChapterDrift>> searchChapters({
    List<String> mangaIds = const [],
  }) async {
    if (mangaIds.nonEmpty.isNotEmpty) return [];

    final selector = select(mangaChapterTables)
      ..where(
        (f) => [
          for (final e in mangaIds.nonEmpty) f.mangaId.equals(e),
        ].reduce((a, b) => a | b),
      );

    return selector.get();
  }

  Future<List<ChapterDrift>> getChapters(String mangaId) {
    final selector = select(mangaChapterTables)
      ..where((f) => f.mangaId.equals(mangaId));

    return selector.get();
  }

  Future<List<ChapterDrift>> updateChapter(MangaChapterTablesCompanion data) {
    final selector = update(mangaChapterTables)..whereSamePrimaryKey(data);

    return transaction(
      () => selector.writeReturning(
        data.copyWith(
          id: const Value.absent(),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
      ),
    );
  }

  Future<List<ImageDrift>> getImages(String chapterId) {
    final selector = select(mangaChapterImageTables)
      ..where((f) => f.chapterId.equals(chapterId))
      ..orderBy([(f) => OrderingTerm(expression: f.id)]);

    return selector.get();
  }

  Future<List<ImageDrift>> setImages(String chapterId, List<String> images) {
    final selector = delete(mangaChapterImageTables)
      ..where((f) => f.chapterId.equals(chapterId));

    return transaction(
      () async {
        await selector.go();

        final datas = <ImageDrift>[];
        for (final image in images) {
          final data = MangaChapterImageTablesCompanion(webUrl: Value(image));
          final result = await into(mangaChapterImageTables).insertReturning(
            data.copyWith(
              id: Value(const Uuid().v4().toString()),
              createdAt: Value(DateTime.now().toIso8601String()),
              updatedAt: Value(DateTime.now().toIso8601String()),
            ),
            onConflict: DoUpdate(
              (old) => data.copyWith(
                id: Value(const Uuid().v4().toString()),
                createdAt: Value(DateTime.now().toIso8601String()),
                updatedAt: Value(DateTime.now().toIso8601String()),
              ),
            ),
          );
          datas.add(result);
        }
        return datas;
      },
    );
  }
}
