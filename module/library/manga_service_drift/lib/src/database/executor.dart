import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/universal_io.dart';

import '../interceptor/log_interceptor.dart';
import '../util/typedef.dart';
import 'adapter/sql_workaround_adapter.dart'
    if (dart.library.io) 'adapter/sql_workaround_io.dart'
    if (dart.library.js) 'adapter/sql_workaround_web.dart';

class Executor {
  final LoggerCallback? _logger;
  final String _name;

  const Executor({LoggerCallback? logger, String name = 'mangastash-local'})
    : _logger = logger,
      _name = name;

  QueryExecutor build() {
    return LazyDatabase(() async {
      await sqlWorkaround();

      final executor = driftDatabase(
        name: _name,
        native: DriftNativeOptions(
          databaseDirectory: () async {
            final directory = await databaseDirectory();
            _logger?.call(
              'Database location: $directory',
              name: runtimeType.toString(),
            );
            return directory;
          },
        ),
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
          onResult: (result) {
            if (result.missingFeatures.isEmpty) return;
            _logger?.call(
              'Using ${result.chosenImplementation} due to unsupported '
              'browser features: ${result.missingFeatures}',
              name: runtimeType.toString(),
            );
          },
        ),
      );

      return executor.interceptWith(LogInterceptor(logger: _logger));
    });
  }

  Future<Directory> databaseDirectory() => getApplicationDocumentsDirectory();

  Future<File> databaseFile() async {
    return File(
      path.join((await databaseDirectory()).path, '$databaseName.sqlite'),
    );
  }

  String get databaseName => _name;
}
