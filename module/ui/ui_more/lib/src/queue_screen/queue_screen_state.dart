import 'package:core_storage/core_storage.dart';
import 'package:equatable/equatable.dart';

class QueueScreenState extends Equatable {
  final List<JobModel> jobs;

  const QueueScreenState({
    this.jobs = const [],
  });

  @override
  List<Object?> get props => [jobs];

  QueueScreenState copyWith({
    List<JobModel>? jobs,
  }) {
    return QueueScreenState(
      jobs: jobs ?? this.jobs,
    );
  }
}
