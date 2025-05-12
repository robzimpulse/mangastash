import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../model/manga_chapter_drift.dart';
import '../tables/manga_chapter_image_tables.dart';
import '../tables/manga_chapter_tables.dart';

part 'sync_chapters_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaChapterTables,
    MangaChapterImageTables,
  ],
)
class SyncChaptersDao extends DatabaseAccessor<AppDatabase>
    with _$SyncChaptersDaoMixin {
  SyncChaptersDao(AppDatabase db) : super(db);

  Future<List<MangaChapterDrift>> sync(List<MangaChapterDrift> chapters) async {
    if (chapters.isEmpty) return [];

    final existing = await searchChapters(
      mangaIds: chapters.map((e) => e.mangaId).nonNulls.toList(),
    );

    final toUpdateChapters = <(MangaChapterTablesCompanion, List<String>)>[];
    final toInsertChapters = chapters;

    for (final chapter in existing) {
      /// convert existing record to companion
      final comp = chapter.toCompanion(false);

      /// sort by similarity
      toInsertChapters.sort(
        (a, b) {
          final left = comp.similarity(a.toCompanion());
          final right = comp.similarity(b.toCompanion());
          return ((left - right) * 1000).toInt();
        },
      );

      /// pop the first similar
      final result = toInsertChapters.removeAt(0);

      toUpdateChapters.add(
        (
          comp.copyWith(
            title: Value.absentIfNull(result.title),
            volume: Value.absentIfNull(result.volume),
            chapter: Value.absentIfNull(result.chapter),
            translatedLanguage: Value.absentIfNull(result.translatedLanguage),
            scanlationGroup: Value.absentIfNull(result.scanlationGroup),
            webUrl: Value.absentIfNull(result.webUrl),
          ),
          result.images.map((e) => e.webUrl).nonNulls.toList(),
        ),
      );
    }

    return transaction(
      () async {
        final allChapter = <MangaChapterTable>[];
        final allChapterImage = <MangaChapterImageTable>[];

        /// insert chapter
        for (final chapter in toInsertChapters) {
          final images = chapter.images.map((e) => e.toCompanion()).toList();
          final tmp = chapter.toCompanion();
          final result = await into(mangaChapterTables).insertReturning(
            tmp.copyWith(
              id: tmp.id.present ? null : Value(const Uuid().v4().toString()),
              createdAt: Value(DateTime.now().toIso8601String()),
              updatedAt: Value(DateTime.now().toIso8601String()),
            ),
            onConflict: DoUpdate(
              (old) => tmp.copyWith(
                id: Value(const Uuid().v4().toString()),
                createdAt: Value(DateTime.now().toIso8601String()),
                updatedAt: Value(DateTime.now().toIso8601String()),
              ),
            ),
          );

          /// delete existing images for chapter
          await (delete(mangaChapterImageTables)
            ..where((f) => f.chapterId.equals(result.id)))
              .goAndReturn();

          for (final (index, image) in images.indexed) {
            final data = await into(mangaChapterImageTables).insertReturning(
              image.copyWith(
                id: tmp.id.present ? null : Value(const Uuid().v4().toString()),
                createdAt: Value(DateTime.now().toIso8601String()),
                updatedAt: Value(DateTime.now().toIso8601String()),
                order: Value(index),
                chapterId: Value(result.id),
              ),
            );
            allChapterImage.add(data);
          }

          allChapter.add(result);
        }

        /// update chapter
        for (final (chapter, images) in toUpdateChapters) {
          final selector = update(mangaChapterTables)
            ..where((f) => f.id.equals(chapter.id.value));
          final results = await selector.writeReturning(
            chapter.copyWith(
              updatedAt: Value(DateTime.now().toIso8601String()),
            ),
          );
          for (final result in results) {
            /// delete existing images for updated chapter
            await (delete(mangaChapterImageTables)
                  ..where((f) => f.chapterId.equals(chapter.id.value)))
                .go();

            for (final (index, image) in (images).indexed) {
              final data = await into(mangaChapterImageTables).insertReturning(
                MangaChapterImageTablesCompanion.insert(
                  order: index,
                  chapterId: chapter.id.value,
                  webUrl: image,
                  id: const Uuid().v4().toString(),
                  createdAt: Value(DateTime.now().toIso8601String()),
                  updatedAt: Value(DateTime.now().toIso8601String()),
                ),
              );
              allChapterImage.add(data);
            }

            allChapter.add(result);
          }
        }

        return allChapter
            .map(
              (e) => MangaChapterDrift.fromCompanion(
                e.toCompanion(false),
                images: allChapterImage
                    .where((f) => f.chapterId == e.id)
                    .map((e) => e.toCompanion(false))
                    .toList(),
              ),
            )
            .toList();
      },
    );
  }

  Future<List<MangaChapterTable>> searchChapters({
    List<String> mangaIds = const [],
  }) async {
    final isAllEmpty = [
      ...mangaIds.nonEmpty,
    ].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(mangaChapterTables)
      ..where(
        (f) => [
          for (final e in mangaIds.nonEmpty) f.mangaId.equals(e),
        ].reduce((a, b) => a | b),
      );

    return selector.get();
  }

  Future<List<MangaChapterImageTable>> searchChapterImages({
    List<String> chapterIds = const [],
  }) async {
    final isAllEmpty = [
      ...chapterIds.nonEmpty,
    ].isEmpty;

    if (isAllEmpty) return [];

    final selector = select(mangaChapterImageTables)
      ..where(
        (f) => [
          for (final e in chapterIds.nonEmpty) f.chapterId.equals(e),
        ].reduce((a, b) => a | b),
      );

    return selector.get();
  }
}
