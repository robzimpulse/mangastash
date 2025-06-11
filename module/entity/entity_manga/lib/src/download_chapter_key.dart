import 'dart:convert';

import 'package:core_environment/core_environment.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'chapter.dart';
import 'manga.dart';

part 'download_chapter_key.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DownloadChapterKey extends Equatable {
  final String? mangaId;
  final String? mangaTitle;
  final String? mangaCoverUrl;

  final String? chapterId;
  final num? chapterNumber;
  final String? mangaSource;

  const DownloadChapterKey({
    this.mangaId,
    this.chapterId,
    this.mangaSource,
    this.mangaTitle,
    this.chapterNumber,
    this.mangaCoverUrl,
  });

  @override
  List<Object?> get props => [
        mangaId,
        chapterId,
        mangaSource,
        mangaTitle,
        chapterNumber,
        mangaCoverUrl,
      ];

  factory DownloadChapterKey.fromJson(Map<String, dynamic> json) {
    return _$DownloadChapterKeyFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DownloadChapterKeyToJson(this);

  String toJsonString() => json.encode(toJson());

  factory DownloadChapterKey.create({Manga? manga, Chapter? chapter}) {
    return DownloadChapterKey(
      mangaId: manga?.id,
      mangaSource: manga?.source,
      mangaTitle: manga?.title,
      mangaCoverUrl: manga?.coverUrl,
      chapterId: chapter?.id,
      chapterNumber: chapter?.chapter?.let((e) => num.tryParse(e)),
    );
  }

  static DownloadChapterKey? fromJsonString(String json) {
    try {
      return DownloadChapterKey.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (e) {
      return const DownloadChapterKey();
    }
  }
}
