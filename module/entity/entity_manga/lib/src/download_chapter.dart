import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../entity_manga.dart';

part 'download_chapter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DownloadChapter extends Equatable {

  final Manga? manga;

  final MangaChapter? chapter;

  const DownloadChapter({this.manga, this.chapter});

  @override
  List<Object?> get props => [manga, chapter];

  factory DownloadChapter.fromJson(Map<String, dynamic> json) {
    return _$DownloadChapterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DownloadChapterToJson(this);

  String toJsonString() => json.encode(toJson());

  factory DownloadChapter.fromJsonString(String json) {
    try {
      return DownloadChapter.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      return const DownloadChapter();
    }
  }
}