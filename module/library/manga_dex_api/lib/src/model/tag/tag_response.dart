import 'package:json_annotation/json_annotation.dart';

import '../common/response.dart';
import 'tag_data.dart';

part 'tag_response.g.dart';

@JsonSerializable()
class TagResponse extends Response {
  final List<TagData>? data;
  final num? limit;
  final num? offset;
  final num? total;

  const TagResponse(
    super.result,
    super.response,
    this.data,
    this.limit,
    this.offset,
    this.total,
  );

  factory TagResponse.fromJson(Map<String, dynamic> json) {
    return _$TagResponseFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$TagResponseToJson(this);
}



