import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../entity_manga.dart';

part 'download_chapter_key.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DownloadChapterKey extends Equatable {

  final Manga? manga;

  final MangaChapter? chapter;

  const DownloadChapterKey({this.manga, this.chapter});

  @override
  List<Object?> get props => [manga, chapter];

  factory DownloadChapterKey.fromJson(Map<String, dynamic> json) {
    return _$DownloadChapterKeyFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DownloadChapterKeyToJson(this);

  String toJsonString() => json.encode(toJson());

  factory DownloadChapterKey.fromJsonString(String json) {
    try {
      return DownloadChapterKey.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      return const DownloadChapterKey();
    }
  }
}