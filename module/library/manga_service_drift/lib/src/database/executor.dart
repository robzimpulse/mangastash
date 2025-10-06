import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../interceptor/log_interceptor.dart';
import '../util/typedef.dart';
import 'adapter/sql_workaround_adapter.dart';

class Executor {
  static QueryExecutor create({LoggerCallback? logger}) {
    return LazyDatabase(() async {
      await sqlWorkaround();

      final executor = driftDatabase(
        name: 'mangastash-local',
        native: DriftNativeOptions(
          databaseDirectory: () async {
            final directory = await getApplicationDocumentsDirectory();
            logger?.call('Database location: $directory', name: 'AppDatabase');
            return directory;
          },
        ),
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
          onResult: (result) {
            if (result.missingFeatures.isEmpty) return;
            logger?.call(
              'Using ${result.chosenImplementation} due to unsupported '
              'browser features: ${result.missingFeatures}',
              name: 'AppDatabase',
            );
          },
        ),
      );

      return executor.interceptWith(LogInterceptor(logger: logger));
    });
  }
}
