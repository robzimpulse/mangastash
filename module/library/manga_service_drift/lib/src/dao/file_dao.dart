import 'package:drift/drift.dart';
import 'package:file/file.dart';
import 'package:uuid/uuid.dart';

import '../database/adapter/filesystem/filesystem_adapter.dart'
    if (dart.library.js_interop) '../database/adapter/filesystem/filesystem_web.dart'
    if (dart.library.io) '../database/adapter/filesystem/filesystem_io.dart';
import '../database/database.dart';
import '../extension/file_system_entity_extension.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../tables/file_tables.dart';

part 'file_dao.g.dart';

@DriftAccessor(tables: [FileTables])
class FileDao extends DatabaseAccessor<AppDatabase> with _$FileDaoMixin {
  FileDao(super.db);

  List<OrderingTerm Function($FileTablesTable)> get _clauses {
    return [(o) => OrderingTerm(expression: o.id, mode: OrderingMode.asc)];
  }

  SimpleSelectStatement<$FileTablesTable, FileDrift> get _selector {
    return select(fileTables)..orderBy(_clauses);
  }

  DeleteStatement<$FileTablesTable, FileDrift> get _deleter {
    return delete(fileTables);
  }

  Expression<bool> _filter({
    required $FileTablesTable f,
    List<String> ids = const [],
    List<String> webUrls = const [],
  }) {
    return [
      f.id.isIn(ids.nonEmpty.distinct),
      f.webUrl.isIn(webUrls.nonEmpty.distinct),
    ].fold(const Constant(false), (a, b) => a | b);
  }

  Future<List<FileDrift>> get all => _selector.get();

  Future<List<FileDrift>> search({
    List<String> ids = const [],
    List<String> webUrls = const [],
  }) {
    final selector = _selector;
    selector.where((f) => _filter(f: f, ids: ids, webUrls: webUrls));
    return transaction(() => selector.get());
  }

  Future<FileDrift> add({required String webUrl, required File file}) async {
    return transaction(() async {
      if (!await file.exists()) {
        throw FileSystemException('File not found', file.path);
      }

      final directory = await databaseDirectory();
      final filename = '${Uuid().v4()}.${file.extension}';
      final dest = await directory.childFile(filename).create(recursive: true);
      await dest.openWrite().addStream(file.openRead());

      final value = FileTablesCompanion.insert(
        webUrl: webUrl,
        relativePath: Value.absentIfNull(filename),
      );

      return into(fileTables).insertReturning(
        value,
        mode: InsertMode.insertOrReplace,
        onConflict: DoUpdate(
          (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
        ),
      );
    });
  }

  Future<List<FileDrift>> remove({
    List<String> ids = const [],
    List<String> webUrls = const [],
  }) {
    final selector = _deleter;
    selector.where((f) => _filter(f: f, ids: ids, webUrls: webUrls));
    return transaction(() => selector.goAndReturn());
  }
}
