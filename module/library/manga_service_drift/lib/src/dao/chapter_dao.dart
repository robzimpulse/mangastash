import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/nullable_generic.dart';
import '../extension/value_or_null_extension.dart';
import '../model/chapter_model.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import 'image_dao.dart';

part 'chapter_dao.g.dart';

@DriftAccessor(
  tables: [
    ChapterTables,
    ImageTables,
  ],
)
class ChapterDao extends DatabaseAccessor<AppDatabase> with _$ChapterDaoMixin {
  ChapterDao(AppDatabase db) : super(db);

  late final ImageDao _imageDao = ImageDao(db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return select(chapterTables).join(
      [
        leftOuterJoin(
          imageTables,
          imageTables.chapterId.equalsExp(chapterTables.id),
        ),
      ],
    );
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

  Stream<List<ChapterModel>> get stream => _aggregate.watch().map(_parse);

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
        f.translatedLanguage.isIn(
          translatedLanguages.nonEmpty.distinct,
        ),
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
          (id) => chapters.firstWhereOrNull(
            (e) => e.chapter?.id == id,
          ),
        );

        final byWebUrl = entry.key.webUrl.valueOrNull.let(
          (url) => chapters.firstWhereOrNull(
            (e) => e.chapter?.webUrl == url,
          ),
        );

        final chapter = (byId ?? byWebUrl);

        final oldLastReadAt = chapter?.chapter?.lastReadAt;
        final newLastReadAt = entry.key.lastReadAt.valueOrNull;

        final value = entry.key.copyWith(
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
        );

        final result = await into(chapterTables).insertReturning(
          value,
          mode: InsertMode.insertOrReplace,
          onConflict: DoUpdate(
            (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
          ),
        );

        final List<ImageDrift> images = [];
        await _imageDao.remove(chapterIds: [result.id]);
        List<ImageDrift> existing = await _imageDao.search(
          chapterIds: [result.id],
        );
        for (final (index, image) in entry.value.indexed) {
          final data = existing.isEmpty
              ? const ImageTablesCompanion()
              : existing.removeAt(0).toCompanion(true);

          images.add(
            await _imageDao.add(
              value: data.copyWith(
                chapterId: Value(result.id),
                webUrl: Value(image),
                order: Value(index),
              ),
            ),
          );
        }

        data.add(ChapterModel(chapter: result, images: images));
      }

      return data;
    });
  }

  Future<ChapterModel> add({
    required ChapterTablesCompanion value,
    List<String> images = const [],
  }) {
    return transaction(() async {
      /// if conflict, update chapter otherwise insert chapter
      final chapter = await into(chapterTables).insertReturning(
        value,
        mode: InsertMode.insertOrReplace,
        onConflict: DoUpdate(
          (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
        ),
      );

      /// update existing data with new data until all new data updated
      final List<ImageDrift> updated = [];
      List<ImageDrift> existing = await _imageDao.search(
        chapterIds: [chapter.id],
      );
      for (final (index, image) in images.indexed) {
        final data = existing.isEmpty
            ? const ImageTablesCompanion()
            : existing.removeAt(0).toCompanion(true);

        updated.add(
          await _imageDao.add(
            value: data.copyWith(
              chapterId: Value(chapter.id),
              webUrl: Value(image),
              order: Value(index),
            ),
          ),
        );
      }

      /// remove all existing data that not updated
      await _imageDao.remove(ids: [...existing.map((e) => e.id)]);

      return ChapterModel(
        chapter: chapter,
        images: updated,
      );
    });
  }
}
