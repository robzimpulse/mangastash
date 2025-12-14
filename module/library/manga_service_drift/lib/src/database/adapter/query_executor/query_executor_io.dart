import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor queryExecutor({
  required String name,
  required DriftNativeOptions ioOptions,
  Uint8List? restoredDb,
}) {
  return LazyDatabase(() => driftDatabase(name: name, native: ioOptions));
}
