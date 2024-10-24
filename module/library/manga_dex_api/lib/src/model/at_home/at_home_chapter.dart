
import 'package:json_annotation/json_annotation.dart';

part 'at_home_chapter.g.dart';

@JsonSerializable()
class AtHomeChapter {
  final String? hash;
  final List<String>? data;
  final List<String>? dataSaver;

  const AtHomeChapter(this.hash, this.data, this.dataSaver);

  factory AtHomeChapter.fromJson(Map<String, dynamic> json) {
    return _$AtHomeChapterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AtHomeChapterToJson(this);
}
