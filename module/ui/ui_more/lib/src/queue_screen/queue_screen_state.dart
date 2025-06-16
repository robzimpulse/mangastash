import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class QueueScreenState extends Equatable {
  final Map<DownloadChapterKey, DownloadChapterProgress> progress;
  final Map<String, String> filenames;

  const QueueScreenState({
    this.progress = const {},
    this.filenames = const {},
  });

  @override
  List<Object?> get props => [progress, filenames];

  QueueScreenState copyWith({
    Map<DownloadChapterKey, DownloadChapterProgress>? progress,
    Map<String, String>? filenames,
  }) {
    return QueueScreenState(
      progress: progress ?? this.progress,
      filenames: filenames ?? this.filenames,
    );
  }
}
