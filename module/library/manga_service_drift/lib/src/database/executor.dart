import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:file/file.dart';
import 'package:log_box_persistent_storage_drift/log_box_persistent_storage_drift.dart';

import 'adapter/filesystem/filesystem_adapter.dart'
    if (dart.library.js_interop) 'adapter/filesystem/filesystem_web.dart'
    if (dart.library.io) 'adapter/filesystem/filesystem_io.dart'
    as fs;
import 'adapter/query_executor/query_executor_adapter.dart'
    if (dart.library.js_interop) 'adapter/query_executor/query_executor_web.dart'
    if (dart.library.io) 'adapter/query_executor/query_executor_io.dart';

class Executor {
  final DriftQueryInterceptor? _interceptor;
  final String _name;

  static Uint8List? _backup;

  static void setBackup(Uint8List backup) {
    _backup = backup;
  }

  static Uint8List? getBackup() {
    final data = _backup;
    _backup = null;
    return data;
  }

  const Executor({DriftQueryInterceptor? interceptor, String name = 'mangastash-local'})
    : _interceptor = interceptor,
      _name = name;

  QueryExecutor build() {
    final executor = queryExecutor(
      name: databaseName,
      restoredDb: getBackup(),
      ioOptions: DriftNativeOptions(
        databaseDirectory: () => databaseDirectory(),
      ),
    );
    final interceptor = _interceptor;
    if (interceptor != null) return executor.interceptWith(interceptor);
    return executor;
  }

  Future<Directory> databaseDirectory() async {
    return (await fs.databaseDirectory()).childDirectory(_name);
  }

  Future<File> databaseFile() async {
    return (await databaseDirectory()).childFile('$_name.sqlite');
  }

  String get databaseName => _name;
}
