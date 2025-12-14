import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor queryExecutor({
  required String name,
  required DriftNativeOptions ioOptions,
  Uint8List? restoredDb,
}) {
  return LazyDatabase(() async {
    final probeResult = await WasmDatabase.probe(
      databaseName: name,
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    // If Database exist -> Delete it
    for (final database in probeResult.existingDatabases) {
      if (database.$1 == WebStorageApi.indexedDb && database.$2 == name) {
        probeResult.deleteDatabase(database);
        break;
      }
    }

    // MAKE NEW DB
    if (!probeResult.availableStorages.contains(
      WasmStorageImplementation.sharedIndexedDb,
    )) {
      throw Exception('IndexedDB is not supported in this environment.');
    }

    return probeResult.open(
      WasmStorageImplementation.sharedIndexedDb,
      name,
      initializeDatabase: () => restoredDb,
    );
  });
}
