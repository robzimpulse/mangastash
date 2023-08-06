import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';
import '../common/identifier.dart';
import '../common/response.dart';

part 'chapter_response.g.dart';

///@nodoc
@JsonSerializable()
class ChapterResponse extends Response {
  final List<ChapterData>? data;
  final int? limit;
  final int? offset;
  final int? total;
  ChapterResponse(
    super.result,
    super.response,
    this.data,
    this.limit,
    this.offset,
    this.total,
  );
  factory ChapterResponse.fromJson(Map<String, dynamic> json) {
    return _$ChapterResponseFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$ChapterResponseToJson(this);
}

///@nodoc
@JsonSerializable()
class ChapterData extends Identifier {
  ChapterAttributes? attributes;
  List<ChapterRelationship>? relationships;
  ChapterData(super.id, super.type, this.attributes, this.relationships);
  factory ChapterData.fromJson(Map<String, dynamic> json) {
    return _$ChapterDataFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$ChapterDataToJson(this);
}

///@nodoc
@JsonSerializable()
class ChapterRelationship extends Identifier {
  ChapterRelationship(super.id, super.type);
  factory ChapterRelationship.fromJson(Map<String, dynamic> json) {
    return _$ChapterRelationshipFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$ChapterRelationshipToJson(this);
}

///@nodoc
@JsonSerializable()
class ChapterAttributes extends Attribute {
  final String? volume;
  final String? chapter;
  final String? title;
  final String? transLanguage;
  final String? hash;
  final List<String>? chapterData;
  final List<String>? chapterDataSaver;
  final String? publishAt;
  ChapterAttributes(
    this.volume,
    this.chapter,
    this.title,
    this.transLanguage,
    this.hash,
    this.chapterData,
    this.chapterDataSaver,
    this.publishAt,
    super.createdAt,
    super.updatedAt,
    super.version,
  );
  factory ChapterAttributes.fromJson(Map<String, dynamic> json) {
    return _$ChapterAttributesFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$ChapterAttributesToJson(this);
}
