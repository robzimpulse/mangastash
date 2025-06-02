import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
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
    return select(imageTables);
  }

  Future<List<ImageDrift>> get all => _selector.get();

  Future<ImageDrift> add({
    String? id,
    required String chapterId,
    required String image,
    required int index,
  }) {
    return transaction(
      () => into(imageTables).insertReturning(
        ImageTablesCompanion(
          chapterId: Value(chapterId),
          webUrl: Value(image),
          order: Value(index),
          id: Value(id ?? const Uuid().v4().toString()),
          createdAt: Value(DateTime.now().toIso8601String()),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
        onConflict: DoUpdate(
          (old) => ImageTablesCompanion(
            chapterId: Value(chapterId),
            webUrl: Value(image),
            order: Value(index),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        ),
      ),
    );
  }
}
