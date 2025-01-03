import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'download_chapter_progress.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DownloadChapterProgress extends Equatable {
  final Map<String, double> values;

  late final num total = values.length;

  late final num finish = values.entries.whereNot((e) => e.value < 1.0).length;

  late final num remaining = values.entries.where((e) => e.value < 1.0).length;

  late final num progress = values.values.sum / values.length;

  DownloadChapterProgress({required this.values});

  @override
  List<Object?> get props => [total, progress];

  factory DownloadChapterProgress.fromJson(Map<String, dynamic> json) {
    return _$DownloadChapterProgressFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DownloadChapterProgressToJson(this);

  factory DownloadChapterProgress.zero() {
    return DownloadChapterProgress(values: const {});
  }
}
