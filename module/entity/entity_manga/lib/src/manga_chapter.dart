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

  String get top {
    List<String> texts = [];
    if (volume != null) texts.add('Vol $volume');
    if (chapter != null) texts.add('Ch $chapter');
    return texts.join(' ');
  }

  String get bottom {
    List<String> texts = [];
    // if (readableAt != null) texts.add('${readableAt?.asDateTime?.ddLLLLyy}');
    if (title != null) texts.add('$title');
    return texts.join(' - ');
  }

}