import 'package:json_annotation/json_annotation.dart';

import '../common/response.dart';
import 'manga_data.dart';

part 'manga_response.g.dart';

///@nodoc
@JsonSerializable()
class MangaResponse extends Response {
  final MangaData? data;

  const MangaResponse(
    super.result,
    super.response,
    this.data,
  );

  factory MangaResponse.fromJson(Map<String, dynamic> json) {
    return _$MangaResponseFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$MangaResponseToJson(this);
}
