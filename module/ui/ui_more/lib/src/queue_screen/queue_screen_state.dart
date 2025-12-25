import 'package:core_storage/core_storage.dart';
import 'package:equatable/equatable.dart';

class QueueScreenState extends Equatable {
  final List<JobModel> jobs;
  final int? ongoingJobId;

  const QueueScreenState({this.jobs = const [], this.ongoingJobId});

  @override
  List<Object?> get props => [jobs, ongoingJobId];

  QueueScreenState copyWith({List<JobModel>? jobs, int? ongoingJobId}) {
    return QueueScreenState(
      jobs: jobs ?? this.jobs,
      ongoingJobId: ongoingJobId ?? this.ongoingJobId,
    );
  }
}
