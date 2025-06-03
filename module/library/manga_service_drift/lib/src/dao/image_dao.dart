import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../extension/value_or_null_extension.dart';
import '../tables/image_tables.dart';

part 'image_dao.g.dart';

@DriftAccessor(
  tables: [
    ImageTables,
  ],
)
class ImageDao extends DatabaseAccessor<AppDatabase> with _$ImageDaoMixin {
  ImageDao(AppDatabase db) : super(db);

  SimpleSelectStatement<$ImageTablesTable, ImageDrift> get _selector {
    return select(imageTables)
      ..orderBy(
        [
          (o) => OrderingTerm(expression: o.order, mode: OrderingMode.asc),
        ],
      );
  }

  Future<List<ImageDrift>> get all => _selector.get();

  Future<List<ImageDrift>> getBy({String? chapterId}) {
    final selector = _selector;

    if (chapterId != null) {
      selector.where((f) => f.chapterId.equals(chapterId));
    }

    return transaction(() => selector.get());
  }

  Future<int> remove({required List<String> ids}) {
    if (ids.isEmpty) return Future.value(0);
    return transaction(
      () => (delete(imageTables)..where((f) => f.id.isIn(ids))).go(),
    );
  }

  Future<ImageDrift> add({required ImageTablesCompanion value}) {
    return transaction(
      () => into(imageTables).insertReturning(
        value.copyWith(
          id: Value(value.id.valueOrNull ?? const Uuid().v4().toString()),
          createdAt: Value(DateTime.now().toIso8601String()),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
        onConflict: DoUpdate(
          (old) => value.copyWith(
            id: const Value.absent(),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        ),
      ),
    );
  }
}
