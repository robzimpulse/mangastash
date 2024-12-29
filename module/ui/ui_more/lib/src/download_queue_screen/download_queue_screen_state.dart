import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class DownloadQueueScreenState extends Equatable {
  final Map<DownloadChapterKey, DownloadChapterProgress> progress;

  const DownloadQueueScreenState({this.progress = const {}});

  @override
  List<Object?> get props => [progress];

  DownloadQueueScreenState copyWith({
    Map<DownloadChapterKey, DownloadChapterProgress>? progress,
  }) {
    return DownloadQueueScreenState(
      progress: progress ?? this.progress,
    );
  }
}
