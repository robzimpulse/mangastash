import 'package:json_annotation/json_annotation.dart';

import '../common/response.dart';
import 'cover_art_data.dart';

part 'cover_art_response.g.dart';

///@nodoc
@JsonSerializable()
class CoverArtResponse extends Response {
  final CoverArtData? data;

  CoverArtResponse(super.result, super.response, this.data);

  factory CoverArtResponse.fromJson(Map<String, dynamic> json) {
    return _$CoverArtResponseFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$CoverArtResponseToJson(this);
}




