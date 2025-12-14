import 'dart:typed_data';

import '../../database.dart';
import '../../executor.dart';

Future<void> restoreDatabase({
  required Uint8List data,
  required AppDatabase database,
  required Executor executor,
}) async {
  throw UnimplementedError('Restore database is not supported');
}