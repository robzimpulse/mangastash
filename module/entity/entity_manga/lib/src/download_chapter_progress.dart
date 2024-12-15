import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'download_chapter_progress.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DownloadChapterProgress extends Equatable {
  final num? total;

  final num? progress;

  const DownloadChapterProgress({this.total, this.progress});

  @override
  List<Object?> get props => [total, progress];

  factory DownloadChapterProgress.fromJson(Map<String, dynamic> json) {
    return _$DownloadChapterProgressFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DownloadChapterProgressToJson(this);

  DownloadChapterProgress copyWith({
    num? total,
    num? progress,
  }) {
    return DownloadChapterProgress(
      total: total,
      progress: progress,
    );
  }

  factory DownloadChapterProgress.zero() {
    return const DownloadChapterProgress(total: 0, progress: 0);
  }
}
