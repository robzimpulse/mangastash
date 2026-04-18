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
    return addsMultiple({
      chapterId: values,
    }).then((map) => map[chapterId] ?? []);
  }

  Future<Map<String, List<ImageDrift>>> addsMultiple(
    Map<String, List<String>> values,
  ) {
    if (values.isEmpty) return Future.value({});

    return transaction(() async {
      final chapterIds = values.keys.toList();
      await (delete(imageTables)
        ..where((t) => t.chapterId.isIn(chapterIds))).go();

      final companions = <ImageTablesCompanion>[];
      for (final entry in values.entries) {
        final chapterId = entry.key;
        final images = entry.value;
        for (var i = 0; i < images.length; i++) {
          companions.add(
            ImageTablesCompanion.insert(
              chapterId: chapterId,
              webUrl: images[i],
              order: i,
            ),
          );
        }
      }

      await batch((batch) {
        batch.insertAll(
          imageTables,
          companions,
          mode: InsertMode.insertOrReplace,
        );
      });

      final results =
          await (select(imageTables)
            ..where((t) => t.chapterId.isIn(chapterIds))).get();

      return results.groupListsBy((e) => e.chapterId);
    });
  }
}
