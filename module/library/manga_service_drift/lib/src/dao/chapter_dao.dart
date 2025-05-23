import 'package:collection/collection.dart';
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

  Future<Map<ChapterDrift, List<ImageDrift>>> sync(
    Map<MangaChapterTablesCompanion, List<String>> values,
  ) async {
    final chapters = values.keys;

    final existing = await searchChapters(
      ids: [...chapters.map((e) => e.id.valueOrNull).nonNulls],
      mangaIds: [...chapters.map((e) => e.mangaId.valueOrNull).nonNulls],
      mangaTitles: [...chapters.map((e) => e.mangaTitle.valueOrNull).nonNulls],
      titles: [...chapters.map((e) => e.title.valueOrNull).nonNulls],
      volumes: [...chapters.map((e) => e.volume.valueOrNull).nonNulls],
      chapters: [...chapters.map((e) => e.chapter.valueOrNull).nonNulls],
      translatedLanguages: [
        ...chapters.map((e) => e.translatedLanguage.valueOrNull).nonNulls,
      ],
      scanlationGroups: [
        ...chapters.map((e) => e.scanlationGroup.valueOrNull).nonNulls,
      ],
      webUrls: [...chapters.map((e) => e.webUrl.valueOrNull).nonNulls],
    );

    return transaction(() async {
      final results = <ChapterDrift, List<ImageDrift>>{};
      for (final entry in values.entries) {
        final chapterId = entry.key.id.valueOrNull;

        final matchChapter = existing.firstWhereOrNull(
          (e) => [
            if (chapterId != null) ...[
              e.id == chapterId,
            ] else ...[
              e.mangaTitle == entry.key.mangaTitle.valueOrNull,
              e.mangaId == entry.key.mangaId.valueOrNull,
              e.webUrl == entry.key.webUrl.valueOrNull,
            ],
          ].every((isTrue) => isTrue),
        );

        final updatesChapter = matchChapter != null
            ? await updateChapter(
                entry.key.copyWith(id: Value(matchChapter.id)),
              )
            : [await insertChapter(entry.key)];

        if (updatesChapter.length > 1) {
          throw Exception(
            'Multiple chapter updated on title ${entry.key.mangaTitle}',
          );
        }

        final updatedChapter = updatesChapter.firstOrNull;

        if (updatedChapter == null) {
          throw Exception(
            'No Chapter updated on title ${entry.key.mangaTitle}',
          );
        }

        final images = await setImages(updatedChapter.id, entry.value);

        results.update(updatedChapter, (old) => images, ifAbsent: () => images);
      }

      return results;
    });
  }

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

  Future<Map<ChapterDrift, List<ImageDrift>>> getChapters({
    required String mangaId,
  }) async {
    return transaction(() async {
      final selector = select(mangaChapterTables).join(
        [
          leftOuterJoin(
            mangaChapterImageTables,
            mangaChapterImageTables.chapterId.equalsExp(mangaChapterTables.id),
          ),
        ],
      )..where(mangaChapterTables.mangaId.equals(mangaId));

      final results = await selector.get();

      if (results.isEmpty) {
        final selector = select(mangaChapterTables)
          ..where((f) => f.mangaId.equals(mangaId));
        final results = await selector.get();
        return {for (final e in results) e: <ImageDrift>[]};
      }

      final groups = results
          .groupListsBy((e) => e.readTableOrNull(mangaChapterTables))
          .map(
            (key, images) => MapEntry(
              key,
              images
                  .map((e) => e.readTableOrNull(mangaChapterImageTables))
                  .nonNulls
                  .toList(),
            ),
          );

      return {
        for (final key in groups.keys.nonNulls)
          key: groups[key] ?? <ImageDrift>[],
      };
    });
  }

  Future<(ChapterDrift, List<ImageDrift>)?> getChapter({
    required String chapterId,
  }) async {
    return transaction(() async {
      final selector = select(mangaChapterTables).join(
        [
          leftOuterJoin(
            mangaChapterImageTables,
            mangaChapterImageTables.chapterId.equalsExp(mangaChapterTables.id),
          ),
        ],
      )..where(mangaChapterTables.id.equals(chapterId));

      final results = await selector.get();

      if (results.isEmpty) {
        final selector = select(mangaChapterTables)
          ..where((f) => f.id.equals(chapterId));
        final result = await selector.getSingleOrNull();
        if (result == null) return null;
        return (result, <ImageDrift>[]);
      }

      final groups = results
          .groupListsBy((e) => e.readTableOrNull(mangaChapterTables))
          .map(
            (key, value) => MapEntry(
              key,
              value
                  .map((e) => e.readTableOrNull(mangaChapterImageTables))
                  .nonNulls
                  .sortedBy<num>((e) => e.order)
                  .toList(),
            ),
          );

      final data = [
        for (final key in groups.keys.nonNulls)
          (key, groups[key] ?? <ImageDrift>[]),
      ];

      return data.firstOrNull;
    });
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
