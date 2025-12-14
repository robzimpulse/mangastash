import 'package:drift/drift.dart';

import '../database/database.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../tables/image_byte_tables.dart';

part 'image_byte_dao.g.dart';

@DriftAccessor(tables: [ImageByteTables])
class ImageByteDao extends DatabaseAccessor<AppDatabase>
    with _$ImageByteDaoMixin {
  ImageByteDao(super.db);

  List<OrderingTerm Function($ImageByteTablesTable)> get _clauses {
    return [(o) => OrderingTerm(expression: o.id, mode: OrderingMode.asc)];
  }

  SimpleSelectStatement<$ImageByteTablesTable, ImageByteDrift> get _selector {
    return select(imageByteTables)..orderBy(_clauses);
  }

  DeleteStatement<$ImageByteTablesTable, ImageByteDrift> get _deleter {
    return delete(imageByteTables);
  }

  Expression<bool> _filter({
    required $ImageByteTablesTable f,
    List<String> ids = const [],
    List<String> webUrls = const [],
  }) {
    return [
      f.id.isIn(ids.nonEmpty.distinct),
      f.webUrl.isIn(webUrls.nonEmpty.distinct),
    ].fold(const Constant(false), (a, b) => a | b);
  }

  Future<List<ImageByteDrift>> get all => _selector.get();

  Future<List<ImageByteDrift>> search({
    List<String> ids = const [],
    List<String> webUrls = const [],
  }) {
    final selector = _selector;
    selector.where((f) => _filter(f: f, ids: ids, webUrls: webUrls));
    return transaction(() => selector.get());
  }

  Future<ImageByteDrift> add({required String webUrl, Uint8List? data}) {
    final value = ImageByteTablesCompanion.insert(
      webUrl: webUrl,
      byte: Value.absentIfNull(data),
    );

    return transaction(
      () => into(imageByteTables).insertReturning(
        value,
        mode: InsertMode.insertOrReplace,
        onConflict: DoUpdate(
          (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
        ),
      ),
    );
  }

  Future<List<ImageByteDrift>> remove({
    List<String> ids = const [],
    List<String> webUrls = const [],
    List<String> chapterIds = const [],
  }) {
    final selector = _deleter;
    selector.where((f) => _filter(f: f, ids: ids, webUrls: webUrls));
    return transaction(() => selector.goAndReturn());
  }
}
