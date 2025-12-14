import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/universal_io.dart';

import '../interceptor/log_interceptor.dart';
import '../util/typedef.dart';
import 'adapter/query_executor/query_executor_adapter.dart'
    if (dart.library.js_interop) 'adapter/query_executor/query_executor_web.dart'
    if (dart.library.io) 'adapter/query_executor/query_executor_io.dart';

class Executor {
  final LoggerCallback? _logger;
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

  const Executor({LoggerCallback? logger, String name = 'mangastash-local'})
    : _logger = logger,
      _name = name;

  QueryExecutor build() {
    return queryExecutor(
      name: databaseName,
      restoredDb: getBackup(),
      ioOptions: DriftNativeOptions(
        databaseDirectory: () async {
          final directory = await databaseDirectory();
          _logger?.call(
            'Database location: $directory',
            name: runtimeType.toString(),
          );
          return directory;
        },
      ),
    ).interceptWith(LogInterceptor(logger: _logger));
  }

  Future<Directory> databaseDirectory() => getApplicationDocumentsDirectory();

  Future<File> databaseFile() async {
    return File(join((await databaseDirectory()).path, '$databaseName.sqlite'));
  }

  String get databaseName => _name;
}
