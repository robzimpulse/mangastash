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

  Stream<Map<String, List<ChapterModel>>> get unread {
    final selector = _aggregate..where(chapterTables.lastReadAt.isNull());
    return selector.watch().map((e) {
      final groups = _parse(e).groupListsBy((e) => e.chapter?.mangaId);
      return {
        for (final key in groups.keys.nonNulls) key: [...?groups[key]],
      };
    });
  }

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
          (old) => ChapterTablesCompanion.custom(
            createdAt: value.createdAt.valueOrNull?.let((e) => Constant(e)),
            updatedAt: Constant(DateTime.timestamp()),
            id: value.id.valueOrNull?.let((e) => Constant(e)),
            mangaId: value.mangaId.valueOrNull?.let((e) => Constant(e)),
            title: value.title.valueOrNull?.let((e) => Constant(e)),
            volume: value.volume.valueOrNull?.let((e) => Constant(e)),
            chapter: value.chapter.valueOrNull?.let((e) => Constant(e)),
            translatedLanguage: value.translatedLanguage.valueOrNull?.let(
              (e) => Constant(e),
            ),
            scanlationGroup: value.scanlationGroup.valueOrNull?.let(
              (e) => Constant(e),
            ),
            webUrl: value.webUrl.valueOrNull?.let((e) => Constant(e)),
            readableAt: value.readableAt.valueOrNull?.let((e) => Constant(e)),
            publishAt: value.publishAt.valueOrNull?.let((e) => Constant(e)),
            lastReadAt: CaseWhenExpression(
              cases: [
                CaseWhen(
                  old.lastReadAt.isNull(),
                  then: Constant(value.lastReadAt.valueOrNull),
                ),
              ],
              orElse: old.lastReadAt,
            ),
          ),
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
