import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manga_chapter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaChapter extends Equatable {

  final String? id;

  final String? title;

  final String? volume;

  final String? chapter;

  const MangaChapter({this.id, this.title, this.volume, this.chapter});

  @override
  List<Object?> get props => [id, title, volume, chapter];

  factory MangaChapter.fromJson(Map<String, dynamic> json) {
    return _$MangaChapterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaChapterToJson(this);
}