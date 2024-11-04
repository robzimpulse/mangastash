import 'package:json_annotation/json_annotation.dart';

import '../common/response.dart';
import 'chapter_data.dart';

part 'search_chapter_response.g.dart';

///@nodoc
@JsonSerializable()
class SearchChapterResponse extends Response {
  final List<ChapterData>? data;
  final num? limit;
  final num? offset;
  final num? total;

  const SearchChapterResponse(
    super.result,
    super.response,
    this.data,
    this.limit,
    this.offset,
    this.total,
  );

  factory SearchChapterResponse.fromJson(Map<String, dynamic> json) {
    return _$SearchChapterResponseFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$SearchChapterResponseToJson(this);
}

Map<String, dynamic> serializeSearchChapterResponse(
  SearchChapterResponse object,
) =>
    object.toJson();

SearchChapterResponse deserializeSearchChapterResponse(
  Map<String, dynamic> json,
) =>
    SearchChapterResponse.fromJson(json);
