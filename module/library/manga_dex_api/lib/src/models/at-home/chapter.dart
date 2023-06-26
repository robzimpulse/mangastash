import 'package:json_annotation/json_annotation.dart';
part 'chapter.g.dart';

///@nodoc
@JsonSerializable()
class MultipleChapterData {
  final String? hash;
  final List<String>? data;
  final List<String>? dataSaver;
  MultipleChapterData(this.hash, this.data, this.dataSaver);
  factory MultipleChapterData.fromJson(Map<String, dynamic> json) =>
      _$MultipleChapterDataFromJson(json);

  Map<String, dynamic> toJson() => _$MultipleChapterDataToJson(this);
}
