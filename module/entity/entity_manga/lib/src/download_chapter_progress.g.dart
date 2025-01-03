// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_chapter_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadChapterProgress _$DownloadChapterProgressFromJson(
        Map<String, dynamic> json) =>
    DownloadChapterProgress(
      values: (json['values'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$DownloadChapterProgressToJson(
        DownloadChapterProgress instance) =>
    <String, dynamic>{
      'values': instance.values,
    };
