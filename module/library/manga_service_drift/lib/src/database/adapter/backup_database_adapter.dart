import 'dart:typed_data';

import '../database.dart';

Future<Uint8List> backupDatabase({
  required String dbName,
  required AppDatabase database,
}) async {
  throw UnimplementedError('Backup database is not supported');
}
