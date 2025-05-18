import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/value_or_null_extension.dart';
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
    List<String> ids = const [],
    List<String> mangaIds = const [],
    List<String> mangaTitles = const [],
    List<String> titles = const [],
    List<String> volumes = const [],
    List<String> chapters = const [],
    List<String> translatedLanguages = const [],
    List<String> scanlationGroups = const [],
    List<String> webUrls = const [],
  }) async {
    final isAllEmpty = [
      ...ids.nonEmpty.distinct,
      ...mangaIds.nonEmpty.distinct,
      ...mangaTitles.nonEmpty.distinct,
      ...titles.nonEmpty.distinct,
      ...volumes.nonEmpty.distinct,
      ...chapters.nonEmpty.distinct,
      ...translatedLanguages.nonEmpty.distinct,
      ...scanlationGroups.nonEmpty.distinct,
      ...webUrls.nonEmpty.distinct,
    ].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(mangaChapterTables)
      ..where(
        (f) => [
          f.id.isIn(ids.nonEmpty.distinct),
          f.mangaId.isIn(mangaIds.nonEmpty.distinct),
          for (final e in mangaTitles.nonEmpty.distinct)
            f.mangaTitle.like('%$e%'),
          for (final e in titles.nonEmpty.distinct) f.title.like('%$e%'),
          for (final e in volumes.nonEmpty.distinct) f.volume.like('%$e%'),
          for (final e in chapters.nonEmpty.distinct) f.chapter.like('%$e%'),
          for (final e in translatedLanguages.nonEmpty.distinct)
            f.translatedLanguage.like('%$e%'),
          for (final e in scanlationGroups.nonEmpty.distinct)
            f.scanlationGroup.like('%$e%'),
          for (final e in webUrls.nonEmpty.distinct) f.webUrl.like('%$e%'),
        ].reduce((a, b) => a | b),
      );

    return selector.get();
  }

  Future<List<ChapterDrift>> getChapters(String mangaId) {
    final selector = select(mangaChapterTables)
      ..where((f) => f.mangaId.equals(mangaId));

    return selector.get();
  }

  Future<ChapterDrift?> getChapter(String chapterId) {
    final selector = select(mangaChapterTables)
      ..where((f) => f.id.equals(chapterId));

    return selector.getSingleOrNull();
  }

  Future<ChapterDrift> insertChapter(MangaChapterTablesCompanion data) {
    return transaction(
      () => into(mangaChapterTables).insertReturning(
        data.copyWith(
          id: Value(data.id.valueOrNull ?? const Uuid().v4().toString()),
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
      ),
    );
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
        for (final (index, image) in images.indexed) {
          final data = MangaChapterImageTablesCompanion(
            webUrl: Value(image),
            chapterId: Value(chapterId),
            order: Value(index),
          );
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
