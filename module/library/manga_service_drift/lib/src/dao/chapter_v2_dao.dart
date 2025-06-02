import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../extension/value_or_null_extension.dart';
import '../model/chapter_model.dart';
import '../tables/chapter_tables.dart';
import '../tables/image_tables.dart';
import 'image_dao.dart';

part 'chapter_v2_dao.g.dart';

@DriftAccessor(
  tables: [
    ChapterTables,
    ImageTables,
  ],
)
class ChapterV2Dao extends DatabaseAccessor<AppDatabase>
    with _$ChapterV2DaoMixin {
  ChapterV2Dao(AppDatabase db) : super(db);

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

  Stream<List<ChapterModel>> get stream {
    return _aggregate.watch().map((e) => _parse(e));
  }

  Future<List<ChapterModel>> get all {
    return _aggregate.get().then((e) => _parse(e));
  }

  Future<List<ChapterModel>> search({
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

    final  filter = [
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
    ].fold<Expression<bool>>(const Constant(true), (a, b) => a | b);

    final selector = _aggregate..where(filter);

    return transaction(() => selector.get().then((e) => _parse(e)));
  }

  Future<ChapterModel> add({
    required ChapterTablesCompanion value,
    List<String> images = const [],
  }) {
    return transaction(() async {
      final chapter = await into(chapterTables).insertReturning(
        value.copyWith(
          id: Value(value.id.valueOrNull ?? const Uuid().v4().toString()),
          createdAt: Value(DateTime.now().toIso8601String()),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
        onConflict: DoUpdate(
          (old) => value.copyWith(
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        ),
      );

      return ChapterModel(
        chapter: chapter,
        images: [
          for (final (index, image) in images.indexed)
            await _imageDao.add(
              chapterId: chapter.id,
              image: image,
              index: index,
            ),
        ],
      );
    });
  }
}
