import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class QueueScreenState extends Equatable {
  final Map<DownloadChapterKey, DownloadChapterProgress> progress;
  final Map<String, String> filenames;
  final List<JobModel> jobs;

  const QueueScreenState({
    this.progress = const {},
    this.filenames = const {},
    this.jobs = const [],
  });

  @override
  List<Object?> get props => [progress, filenames, jobs];

  QueueScreenState copyWith({
    Map<DownloadChapterKey, DownloadChapterProgress>? progress,
    Map<String, String>? filenames,
    List<JobModel>? jobs,
  }) {
    return QueueScreenState(
      progress: progress ?? this.progress,
      filenames: filenames ?? this.filenames,
      jobs: jobs ?? this.jobs,
    );
  }
}
