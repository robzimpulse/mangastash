import 'package:json_annotation/json_annotation.dart';

import '../common/response.dart';
import 'chapter_data.dart';

part 'chapter_response.g.dart';

///@nodoc
@JsonSerializable()
class ChapterResponse extends Response {
  final ChapterData? data;

  const ChapterResponse(
    super.result,
    super.response,
    this.data,
  );

  factory ChapterResponse.fromJson(Map<String, dynamic> json) {
    return _$ChapterResponseFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$ChapterResponseToJson(this);
}
