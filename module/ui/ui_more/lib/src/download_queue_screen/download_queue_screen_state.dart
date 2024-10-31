import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class DownloadQueueScreenState extends Equatable {
  final Map<DownloadChapter, (int, double)>? progress;

  const DownloadQueueScreenState({this.progress});

  @override
  List<Object?> get props => [progress];

  DownloadQueueScreenState copyWith({
    Map<DownloadChapter, (int, double)>? progress,
  }) {
    return DownloadQueueScreenState(
      progress: progress ?? this.progress,
    );
  }
}
