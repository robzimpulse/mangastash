import 'package:core_network/core_network.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:universal_io/universal_io.dart';

class RestoreDatabaseUseCase {
  final AppDatabase _database;
  final Executor _executor;

  const RestoreDatabaseUseCase({
    required AppDatabase database,
    required Executor executor,
  }) : _database = database,
        _executor = executor;

  // Example: https://github.com/simolus3/drift/blob/96b3947fc16de99ffe25bcabc124e3b3a7c69571/examples/app/lib/screens/backup/supported.dart#L47-L68
  Future<Result<void>> execute({required File file}) async {
    return Error(Exception('Unsupported Platform'));
  }
}
