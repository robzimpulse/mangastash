import 'package:json_annotation/json_annotation.dart';

import '../common/response.dart';
import 'manga_data.dart';

part 'search_manga_response.g.dart';

///@nodoc
@JsonSerializable()
class SearchMangaResponse extends Response {
  final List<MangaData>? data;
  final num? limit;
  final num? offset;
  final num? total;

  const SearchMangaResponse(
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

Map<String, dynamic> serializeSearchMangaResponse(
  SearchMangaResponse object,
) =>
    object.toJson();

SearchMangaResponse deserializeSearchMangaResponse(
  Map<String, dynamic> json,
) =>
    SearchMangaResponse.fromJson(json);
