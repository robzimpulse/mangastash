import 'package:core_storage/core_storage.dart';

abstract class ListenJobUseCase {
  Stream<List<JobModel>> get jobs;

  Stream<int> get jobLength;

  Stream<int> get upcomingJobLength;

  Stream<int?> get ongoingJobId;
}
