///@nodoc
import 'package:json_annotation/json_annotation.dart';

part 'at_home_response.g.dart';

///@nodoc
@JsonSerializable()
class AtHomeResponse {
  final String? result;
  final String? baseUrl;
  final AtHomeChapter? chapter;
  AtHomeResponse(this.result, this.baseUrl, this.chapter);
  factory AtHomeResponse.fromJson(Map<String, dynamic> json) {
    return _$AtHomeResponseFromJson(json);
  }
  Map<String, dynamic> toJson() => _$AtHomeResponseToJson(this);
}

///@nodoc
@JsonSerializable()
class AtHomeChapter {
  final String? hash;
  final List<String>? data;
  final List<String>? dataSaver;
  AtHomeChapter(this.hash, this.data, this.dataSaver);
  factory AtHomeChapter.fromJson(Map<String, dynamic> json) {
    return _$AtHomeChapterFromJson(json);
  }
  Map<String, dynamic> toJson() => _$AtHomeChapterToJson(this);
}