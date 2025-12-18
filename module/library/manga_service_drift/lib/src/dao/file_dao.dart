import 'package:drift/drift.dart';
import 'package:file/file.dart';
import 'package:uuid/uuid.dart';

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
    List<String> relativePaths = const [],
  }) {
    return [
      f.id.isIn(ids.nonEmpty.distinct),
      f.webUrl.isIn(webUrls.nonEmpty.distinct),
      f.relativePath.isIn(relativePaths.nonEmpty.distinct),
    ].fold(const Constant(false), (a, b) => a | b);
  }

  Future<List<FileDrift>> get all => _selector.get();

  Future<List<FileDrift>> search({
    List<String> ids = const [],
    List<String> webUrls = const [],
    List<String> relativePaths = const [],
  }) {
    final selector = _selector;
    selector.where(
      (f) => _filter(
        f: f,
        ids: ids,
        webUrls: webUrls,
        relativePaths: relativePaths,
      ),
    );
    return transaction(() => selector.get());
  }

  Future<FileDrift> add({
    required String webUrl,
    required Uint8List data,
    String? extension,
  }) async {
    return transaction(() async {
      final filename = '${Uuid().v4()}.$extension';
      final destination = (await directory()).childFile(filename);
      await destination.create(recursive: true);
      await destination.writeAsBytes(data);

      final value = FileTablesCompanion.insert(
        webUrl: webUrl,
        relativePath: filename,
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

  Future<Directory> directory() async {
    final root = await attachedDatabase.databaseDirectory();
    return root.childDirectory('file').create();
  }

  Future<File> file(FileDrift data) async {
    return (await directory()).childFile(data.relativePath);
  }

  Future<void> sync() async {
    /// remove [FileDrift] record that file not exists on storage
    await remove(
      ids: [
        for (final result in await all)
          if (!(await file(result).then((e) => e.exists()))) result.id,
      ],
    );

    /// remove [File] that do not exists on database
    final files = await directory().then((e) => e.list().toList());
    final existing = await search(
      relativePaths: [
        ...[for (final file in files) file.filename].nonNulls,
      ],
    );
    for (final file in files) {
      if (!existing.any((e) => e.relativePath == file.filename)) {
        await file.delete();
      }
    }
  }

  Future<List<FileDrift>> remove({
    List<String> ids = const [],
    List<String> webUrls = const [],
    List<String> relativePaths = const [],
  }) {
    final selector = _deleter;
    selector.where(
      (f) => _filter(
        f: f,
        ids: ids,
        webUrls: webUrls,
        relativePaths: relativePaths,
      ),
    );
    return transaction(() => selector.goAndReturn());
  }
}
