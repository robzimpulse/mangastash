import 'package:core_storage/core_storage.dart';

abstract class ListenJobUseCase {
  Stream<(List<JobModel>, int)> get jobsStream;

  Stream<int?> get ongoingJobId;
}