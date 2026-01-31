import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../tables/image_tables.dart';

part 'image_dao.g.dart';

@DriftAccessor(tables: [ImageTables])
class ImageDao extends DatabaseAccessor<AppDatabase> with _$ImageDaoMixin {
  ImageDao(super.db);

  SimpleSelectStatement<$ImageTablesTable, ImageDrift> get _selector {
    return select(imageTables)..orderBy([(o) => OrderingTerm.asc(o.order)]);
  }

  DeleteStatement<$ImageTablesTable, ImageDrift> get _deleter {
    return delete(imageTables);
  }

  Expression<bool> _filter({
    required $ImageTablesTable f,
    List<String> ids = const [],
    List<String> webUrls = const [],
    List<String> chapterIds = const [],
  }) {
    return [
      f.id.isIn(ids.nonEmpty.distinct),
      f.webUrl.isIn(webUrls.nonEmpty.distinct),
      f.chapterId.isIn(chapterIds.nonEmpty.distinct),
    ].fold(const Constant(false), (a, b) => a | b);
  }

  @visibleForTesting
  Future<List<ImageDrift>> get all => _selector.get();

  Future<List<ImageDrift>> search({
    List<String> ids = const [],
    List<String> webUrls = const [],
    List<String> chapterIds = const [],
  }) {
    final selector = _selector;
    selector.where(
      (f) => _filter(f: f, ids: ids, webUrls: webUrls, chapterIds: chapterIds),
    );
    return transaction(() => selector.get());
  }

  Future<List<ImageDrift>> remove({
    List<String> ids = const [],
    List<String> webUrls = const [],
    List<String> chapterIds = const [],
  }) {
    final selector = _deleter;
    selector.where(
      (f) => _filter(f: f, ids: ids, webUrls: webUrls, chapterIds: chapterIds),
    );
    return transaction(() => selector.goAndReturn());
  }

  Future<List<ImageDrift>> adds(
    String chapterId, {
    List<String> values = const [],
  }) {
    if (values.isEmpty) return Future.value([]);

    return transaction(() async {
      final existing = await remove(chapterIds: [chapterId]);

      return [
        ...await Future.wait(
          values.mapIndexed((index, value) {
            final old = existing.firstWhereOrNull((e) => e.webUrl == value);
            final data = old?.toCompanion(true) ?? const ImageTablesCompanion();
            final entry = data.copyWith(
              chapterId: Value(chapterId),
              webUrl: Value(value),
              order: Value(index),
            );

            return into(imageTables).insertReturning(
              entry,
              mode: InsertMode.insertOrReplace,
              onConflict: DoUpdate(
                (old) => entry.copyWith(updatedAt: Value(DateTime.timestamp())),
              ),
            );
          }),
        ),
      ];
    });
  }
}
