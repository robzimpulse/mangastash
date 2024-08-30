import 'package:json_annotation/json_annotation.dart';

import '../common/response.dart';
import 'manga_response.dart';

part 'search_manga_response.g.dart';

///@nodoc
@JsonSerializable()
class SearchMangaResponse extends Response {
  final List<MangaData>? data;
  final int? limit;
  final int? offset;
  final int? total;

  SearchMangaResponse(
    super.result,
    super.response,
    this.data,
    this.limit,
    this.offset,
    this.total,
  );

  factory SearchMangaResponse.fromJson(Map<String, dynamic> json) {
    return _$SearchMangaResponseFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$SearchMangaResponseToJson(this);
}
