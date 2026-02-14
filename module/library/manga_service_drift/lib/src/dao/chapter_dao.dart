import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../database/database.dart';
import '../extension/companion_equality.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/nullable_generic.dart';
import '../extension/value_or_null_extension.dart';
import '../model/chapter_model.dart';
import '../tables/chapter_tables.dart';
import '../tables/file_tables.dart';
import '../tables/image_tables.dart';
import '../util/next_chapter_direction_enum.dart';
import 'image_dao.dart';

part 'chapter_dao.g.dart';

@DriftAccessor(tables: [ChapterTables, ImageTables, FileTables])
class ChapterDao extends DatabaseAccessor<AppDatabase> with _$ChapterDaoMixin {
  ChapterDao(super.db);

  late final ImageDao _imageDao = ImageDao(db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return select(chapterTables).join([
      leftOuterJoin(
        imageTables,
        imageTables.chapterId.equalsExp(chapterTables.id),
      ),
    ])..orderBy([OrderingTerm.asc(imageTables.order)]);
  }

  List<ChapterModel> _parse(List<TypedResult> rows) {
    final data = <ChapterModel>[];

    final groups = rows.groupListsBy((e) => e.readTableOrNull(chapterTables));

    for (final key in groups.keys.nonNulls) {
      data.add(
        ChapterModel(
          chapter: key,
          images: [
            ...?groups[key]
                ?.map((e) => e.readTableOrNull(imageTables))
                .nonNulls,
          ],
        ),
      );
    }

    return data;
  }

  @visibleForTesting
  Future<List<ChapterModel>> get all => _aggregate.get().then(_parse);

  Future<List<ChapterModel>> search({
    List<String> ids = const [],
    List<String> mangaIds = const [],
    List<String> titles = const [],
    List<String> volumes = const [],
    List<String> chapters = const [],
    List<String> translatedLanguages = const [],
    List<String> scanlationGroups = const [],
    List<String> webUrls = const [],
  }) {
    final filter = [
      chapterTables.id.isIn(ids.nonEmpty.distinct),
      chapterTables.mangaId.isIn(mangaIds.nonEmpty.distinct),
      chapterTables.title.isIn(titles.nonEmpty.distinct),
      chapterTables.volume.isIn(volumes.nonEmpty.distinct),
      chapterTables.chapter.isIn(chapters.nonEmpty.distinct),
      chapterTables.translatedLanguage.isIn(
        translatedLanguages.nonEmpty.distinct,
      ),
      chapterTables.scanlationGroup.isIn(scanlationGroups.nonEmpty.distinct),
      chapterTables.webUrl.isIn(webUrls.nonEmpty.distinct),
    ].fold<Expression<bool>>(const Constant(false), (a, b) => a | b);

    final selector = _aggregate..where(filter);

    return transaction(() => selector.get().then((e) => _parse(e)));
  }

  Future<List<ChapterModel>> remove({
    List<String> ids = const [],
    List<String> mangaIds = const [],
    List<String> mangaTitles = const [],
    List<String> titles = const [],
    List<String> volumes = const [],
    List<String> chapters = const [],
    List<String> translatedLanguages = const [],
    List<String> scanlationGroups = const [],
    List<String> webUrls = const [],
  }) {
    Expression<bool> filter($ChapterTablesTable f) {
      return [
        f.id.isIn(ids.nonEmpty.distinct),
        f.mangaId.isIn(mangaIds.nonEmpty.distinct),
        f.title.isIn(titles.nonEmpty.distinct),
        f.volume.isIn(volumes.nonEmpty.distinct),
        f.chapter.isIn(chapters.nonEmpty.distinct),
        f.translatedLanguage.isIn(translatedLanguages.nonEmpty.distinct),
        f.scanlationGroup.isIn(scanlationGroups.nonEmpty.distinct),
        f.webUrl.isIn(webUrls.nonEmpty.distinct),
      ].fold(const Constant(false), (a, b) => a | b);
    }

    final a = delete(chapterTables)..where(filter);
    return transaction(() async {
      final chapters = await a.goAndReturn();
      final images = await _imageDao.remove(chapterIds: ids);
      return [
        for (final chapter in chapters)
          ChapterModel(
            chapter: chapter,
            images: [...images.where((e) => e.chapterId == chapter.id)],
          ),
      ];
    });
  }

  Future<List<ChapterModel>> adds({
    required Map<ChapterTablesCompanion, List<String>> values,
  }) {
    return transaction(() async {
      final data = <ChapterModel>[];

      final chapters = await search(
        ids: [...values.keys.map((e) => e.id.valueOrNull).nonNulls],
        webUrls: [...values.keys.map((e) => e.webUrl.valueOrNull).nonNulls],
      );

      for (final entry in values.entries) {
        final byId = entry.key.id.valueOrNull.let(
          (id) => chapters.firstWhereOrNull((e) => e.chapter?.id == id),
        );

        final byWebUrl = entry.key.webUrl.valueOrNull.let(
          (url) => chapters.firstWhereOrNull((e) => e.chapter?.webUrl == url),
        );

        final chapter = (byId ?? byWebUrl);

        if (chapter != null) {
          final companion = chapter.chapter?.toCompanion(true);
          final id = chapter.chapter?.id;
          if (companion?.shouldUpdate(entry.key) == false && id != null) {
            data.add(
              ChapterModel(
                chapter: chapter.chapter,
                images: await _imageDao.adds(id, values: entry.value),
              ),
            );
            continue;
          }
        }

        final oldLastReadAt = chapter?.chapter?.lastReadAt;
        final newLastReadAt = entry.key.lastReadAt.valueOrNull;

        final value = entry.key.copyWith(
          id: Value.absentIfNull(
            entry.key.id.valueOrNull ?? chapter?.chapter?.id,
          ),
          title: Value.absentIfNull(
            entry.key.title.valueOrNull ?? chapter?.chapter?.title,
          ),
          mangaId: Value.absentIfNull(
            entry.key.mangaId.valueOrNull ?? chapter?.chapter?.id,
          ),
          volume: Value.absentIfNull(
            entry.key.volume.valueOrNull ?? chapter?.chapter?.volume,
          ),
          chapter: Value.absentIfNull(
            entry.key.chapter.valueOrNull ?? chapter?.chapter?.chapter,
          ),
          translatedLanguage: Value.absentIfNull(
            entry.key.translatedLanguage.valueOrNull ??
                chapter?.chapter?.translatedLanguage,
          ),
          scanlationGroup: Value.absentIfNull(
            entry.key.scanlationGroup.valueOrNull ??
                chapter?.chapter?.scanlationGroup,
          ),
          webUrl: Value.absentIfNull(
            entry.key.webUrl.valueOrNull ?? chapter?.chapter?.webUrl,
          ),
          readableAt: Value.absentIfNull(
            entry.key.readableAt.valueOrNull ?? chapter?.chapter?.readableAt,
          ),
          publishAt: Value.absentIfNull(
            entry.key.publishAt.valueOrNull ?? chapter?.chapter?.publishAt,
          ),
          lastReadAt: Value.absentIfNull(
            (oldLastReadAt != null && newLastReadAt != null)
                ? oldLastReadAt.isBefore(newLastReadAt)
                    ? newLastReadAt
                    : oldLastReadAt
                : newLastReadAt ?? oldLastReadAt,
          ),
          createdAt: Value.absentIfNull(
            entry.key.createdAt.valueOrNull ?? chapter?.chapter?.createdAt,
          ),
          updatedAt: Value.absentIfNull(
            entry.key.updatedAt.valueOrNull ?? chapter?.chapter?.updatedAt,
          ),
        );

        final result = await into(chapterTables).insertReturning(
          value,
          mode: InsertMode.insertOrReplace,
          onConflict: DoUpdate(
            (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
          ),
        );

        data.add(
          ChapterModel(
            chapter: result,
            images: await _imageDao.adds(result.id, values: entry.value),
          ),
        );
      }

      return data;
    });
  }

  Future<List<ChapterModel>> getNeighbourChapters({
    required String chapterId,
    required int count,
    NextChapterDirection direction = NextChapterDirection.next,
  }) async {
    final a = select(chapterTables)..where((t) => t.id.equals(chapterId));
    final current = await a.getSingle();
    final chapter = current.chapter;
    final mId = current.mangaId;
    final value = double.tryParse(chapter ?? '0') ?? 0;

    if (mId == null) return [];

    final query = select(chapterTables).join([
      leftOuterJoin(
        imageTables,
        imageTables.chapterId.equalsExp(chapterTables.id),
      ),
    ]);

    query.where(chapterTables.mangaId.equals(mId));

    switch (direction) {
      case NextChapterDirection.previous:
        query.where(
          chapterTables.chapter.cast<double>().isSmallerThanValue(value),
        );
        query.orderBy([
          OrderingTerm.desc(chapterTables.chapter.cast<double>()),
          OrderingTerm.asc(imageTables.order),
        ]);
      case NextChapterDirection.next:
        query.where(
          chapterTables.chapter.cast<double>().isBiggerThanValue(value),
        );
        query.orderBy([
          OrderingTerm.asc(chapterTables.chapter.cast<double>()),
          OrderingTerm.asc(imageTables.order),
        ]);
    }

    return query.get().then(_parse).then((e) => [...e.take(count)]);
  }

  Future<List<ChapterDrift>> getDownloadedChapterId({
    required String mangaId,
  }) async {
    // Define the "Fully Downloaded" condition
    final imageCount = imageTables.id.count();
    final fileCount = fileTables.id.count();

    // Define the Subquery (The Logic)
    // This part calculates which IDs are fully downloaded.
    final downloadedIdsQuery =
        selectOnly(chapterTables)
          ..addColumns([chapterTables.id])
          ..join([
            innerJoin(
              imageTables,
              imageTables.chapterId.equalsExp(chapterTables.id),
            ),
            leftOuterJoin(
              fileTables,
              fileTables.webUrl.equalsExp(imageTables.webUrl),
            ),
          ])
          ..where(chapterTables.mangaId.equals(mangaId))
          ..groupBy(
            [chapterTables.id],
            having:
                imageCount.isBiggerThanValue(0) &
                imageCount.equalsExp(fileCount),
          );

    // 2. Define the Main Query (The Fetch)
    // This selects the actual full rows based on the subquery above.
    final query = select(chapterTables)
      ..where((t) => t.id.isInQuery(downloadedIdsQuery));

    return query.get();
  }
}
