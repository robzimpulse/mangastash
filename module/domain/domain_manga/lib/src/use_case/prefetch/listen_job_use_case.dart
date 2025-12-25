import 'package:core_storage/core_storage.dart';

abstract class ListenJobUseCase {
  Stream<List<JobModel>> get jobsStream;

  Stream<int?> get ongoingJobId;
}