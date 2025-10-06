import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../interceptor/log_interceptor.dart';
import '../util/typedef.dart';
import 'adapter/sql_workaround_adapter.dart'
    if (dart.library.io) 'adapter/sql_workaround_native.dart'
    if (dart.library.js) 'adapter/sql_workaround_web.dart';

class Executor {
  final LoggerCallback? _logger;

  const Executor({LoggerCallback? logger}) : _logger = logger;

  QueryExecutor buildForTesting() {
    return DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    );
  }

  QueryExecutor build() {
    return LazyDatabase(() async {
      await sqlWorkaround();

      final executor = driftDatabase(
        name: 'mangastash-local',
        native: DriftNativeOptions(
          databaseDirectory: () async {
            final directory = await getApplicationDocumentsDirectory();
            _logger?.call('Database location: $directory', name: 'AppDatabase');
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
              name: 'AppDatabase',
            );
          },
        ),
      );

      return executor.interceptWith(LogInterceptor(logger: _logger));
    });
  }
}
