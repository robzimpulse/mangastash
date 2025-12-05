import 'package:universal_io/universal_io.dart';

import '../database.dart';
import '../executor.dart';

Future<void> restoreDatabase({
  required File file,
  required AppDatabase database,
  required Executor executor,
}) {
  return throw UnsupportedError('Cannot implement adapter');
}
