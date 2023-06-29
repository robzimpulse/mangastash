import 'package:json_annotation/json_annotation.dart';

import '../common/identifier.dart';
import '../common/pagination.dart';

part 'chapter_response.g.dart';

///@nodoc
@JsonSerializable()
class ChapterResponse extends Pagination {
  final String? result;
  final String? response;
  final List<ChapterData>? data;
  ChapterResponse(
    this.result,
    this.response,
    this.data,
    super.limit,
    super.offset,
    super.total,
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
class ChapterAttributes extends Identifier {
  final String? volume;
  final String? chapter;
  final String? title;
  final String? transdLanguage;
  final String? hash;
  final List<String>? chapterData;
  final List<String>? chapterDataSaver;
  final String? publishAt;
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  ChapterAttributes(
    super.id,
    super.type,
    this.volume,
    this.chapter,
    this.title,
    this.transdLanguage,
    this.hash,
    this.chapterData,
    this.chapterDataSaver,
    this.publishAt,
    this.createdAt,
    this.updatedAt,
    this.version,
  );
  factory ChapterAttributes.fromJson(Map<String, dynamic> json) {
    return _$ChapterAttributesFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$ChapterAttributesToJson(this);
}
