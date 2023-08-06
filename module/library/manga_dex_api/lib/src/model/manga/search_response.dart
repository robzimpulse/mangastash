import 'package:json_annotation/json_annotation.dart';

import '../common/response.dart';
import 'manga_response.dart';

part 'search_response.g.dart';

///@nodoc
@JsonSerializable()
class SearchResponse extends Response {
  final List<MangaData>? data;
  final int? limit;
  final int? offset;
  final int? total;
  SearchResponse(
    super.result,
    super.response,
    this.data,
    this.limit,
    this.offset,
    this.total,
  );
  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return _$SearchResponseFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);
}