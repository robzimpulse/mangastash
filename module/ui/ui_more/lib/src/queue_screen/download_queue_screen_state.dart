import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class DownloadQueueScreenState extends Equatable {
  final Map<DownloadChapterKey, DownloadChapterProgress> progress;
  final Map<String, String> filenames;

  const DownloadQueueScreenState({
    this.progress = const {},
    this.filenames = const {},
  });

  @override
  List<Object?> get props => [progress, filenames];

  DownloadQueueScreenState copyWith({
    Map<DownloadChapterKey, DownloadChapterProgress>? progress,
    Map<String, String>? filenames,
  }) {
    return DownloadQueueScreenState(
      progress: progress ?? this.progress,
      filenames: filenames ?? this.filenames,
    );
  }
}
