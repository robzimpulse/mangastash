import 'package:drift/drift.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../tables/image_tables.dart';

part 'image_dao.g.dart';

@DriftAccessor(
  tables: [
    ImageTables,
  ],
)
class ImageDao extends DatabaseAccessor<AppDatabase> with _$ImageDaoMixin {
  ImageDao(super.db);

  List<OrderingTerm Function($ImageTablesTable)> get _clauses {
    return [(o) => OrderingTerm(expression: o.order, mode: OrderingMode.asc)];
  }

  SimpleSelectStatement<$ImageTablesTable, ImageDrift> get _selector {
    return select(imageTables)..orderBy(_clauses);
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

  Future<List<ImageDrift>> get all => _selector.get();

  Future<List<ImageDrift>> search({
    List<String> ids = const [],
    List<String> webUrls = const [],
    List<String> chapterIds = const [],
  }) {
    final a = _selector
      ..where(
        (f) => _filter(
          f: f,
          ids: ids,
          webUrls: webUrls,
          chapterIds: chapterIds,
        ),
      );

    return transaction(() => a.get());
  }

  Future<List<ImageDrift>> remove({
    List<String> ids = const [],
    List<String> webUrls = const [],
    List<String> chapterIds = const [],
  }) {
    final selector = _deleter
      ..where(
        (f) => _filter(
          f: f,
          ids: ids,
          webUrls: webUrls,
          chapterIds: chapterIds,
        ),
      );

    return transaction(() => selector.goAndReturn());
  }

  Future<ImageDrift> add({required ImageTablesCompanion value}) {
    return transaction(
      () => into(imageTables).insertReturning(
        value,
        mode: InsertMode.insertOrReplace,
        onConflict: DoUpdate(
          (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
        ),
      ),
    );
  }

  Future<List<ImageDrift>> adds(
    String chapterId, {
    List<String> values = const [],
  }) {
    if (values.isEmpty) return Future.value([]);

    return transaction(() async {
      List<ImageDrift> existing = await search(chapterIds: [chapterId]);
      List<ImageDrift> results = [];

      for (final (index, image) in values.indexed) {
        final data = existing.isEmpty
            ? const ImageTablesCompanion()
            : existing.removeAt(0).toCompanion(true);

        results.add(
          await add(
            value: data.copyWith(
              chapterId: Value(chapterId),
              webUrl: Value(image),
              order: Value(index),
            ),
          ),
        );
      }

      await remove(ids: [...existing.map((e) => e.id)]);

      return results;
    });
  }
}
