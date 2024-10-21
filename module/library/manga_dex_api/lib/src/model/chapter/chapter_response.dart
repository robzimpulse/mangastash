import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';
import '../common/identifier.dart';
import '../common/relationship.dart';
import '../common/response.dart';

part 'chapter_response.g.dart';

///@nodoc
@JsonSerializable()
class ChapterResponse extends Response {
  final ChapterData? data;

  ChapterResponse(
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

@JsonSerializable()
class ChapterData extends Identifier {
  ChapterDataAttributes? attributes;

  @JsonKey(name: 'relationships', fromJson: Relationship.from)
  List<Relationship>? relationships;

  ChapterData(super.id, super.type, this.attributes, this.relationships);

  factory ChapterData.fromJson(Map<String, dynamic> json) {
    return _$ChapterDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChapterDataToJson(this);
}

@JsonSerializable()
class ChapterDataAttributes extends Attribute {
  final String? volume;
  final String? chapter;
  final String? title;
  final String? translatedLanguage;
  final String? externalUrl;
  final String? publishAt;
  final String? readableAt;

  ChapterDataAttributes(
    this.volume,
    this.chapter,
    this.title,
    this.translatedLanguage,
    this.externalUrl,
    this.publishAt,
    this.readableAt,
    super.createdAt,
    super.updatedAt,
    super.version,
  );

  factory ChapterDataAttributes.fromJson(Map<String, dynamic> json) {
    return _$ChapterDataAttributesFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$ChapterDataAttributesToJson(this);
}
