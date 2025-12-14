import 'package:flutter/foundation.dart';

import '../../database.dart';
import '../../executor.dart';

Future<void> restoreDatabase({
  required Uint8List data,
  required AppDatabase database,
  required Executor executor,
}) async {
  if (kIsWasm) {
    throw UnimplementedError('Restore database is not supported web wasm');
  } else {
    throw UnimplementedError('Restore database is not supported web');
  }
}
