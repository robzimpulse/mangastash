import 'package:json_annotation/json_annotation.dart';

import '../common/response.dart';
import 'chapter_response.dart';

part 'search_chapter_response.g.dart';

///@nodoc
@JsonSerializable()
class SearchChapterResponse extends Response {
  final List<ChapterData>? data;
  SearchChapterResponse(
    super.result,
    super.response,
    this.data,
  );
  factory SearchChapterResponse.fromJson(Map<String, dynamic> json) {
    return _$SearchChapterResponseFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$SearchChapterResponseToJson(this);
}
