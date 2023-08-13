import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';
import '../common/identifier.dart';
import '../common/relationship.dart';
import '../common/response.dart';
import '../common/title.dart';
import '../tag/tag_response.dart';

part 'manga_response.g.dart';

///@nodoc
@JsonSerializable()
class MangaResponse extends Response {
  final MangaData? data;
  MangaResponse(
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

@JsonSerializable()
class MangaData extends Identifier {
  final MangaDataAttributes? attributes;
  final List<Relationship>? relationships;
  MangaData(super.id, super.type, this.attributes, this.relationships);
  factory MangaData.fromJson(Map<String, dynamic> json) {
    return _$MangaDataFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$MangaDataToJson(this);
}

@JsonSerializable()
class MangaDataAttributes extends Attribute {
  final Title? title;
  final List<Title>? altTitle;
  final Title? description;
  final bool? isLocked;
  final String? originalLanguage;
  final String? lastVolume;
  final String? lastChapter;
  final String? publicationDemographic;
  final String? status;
  final num? year;
  final String? contentRating;
  final String? state;
  final bool chapterNumbersResetOnNewVolume;
  final String? latestUploadedChapter;
  /// cast to [String?] since server return list of string with null element
  final List<String?>? availableTranslatedLanguages;
  final List<TagData>? tags;
  MangaDataAttributes(
    this.title,
    this.description,
    this.isLocked,
    this.originalLanguage,
    this.lastVolume,
    this.lastChapter,
    this.publicationDemographic,
    this.status,
    this.year,
    this.contentRating,
    this.state,
    this.chapterNumbersResetOnNewVolume,
    super.createdAt,
    super.updatedAt,
    super.version,
    this.latestUploadedChapter,
    this.availableTranslatedLanguages,
    this.tags,
    this.altTitle,
  );
  factory MangaDataAttributes.fromJson(Map<String, dynamic> json) {
    return _$MangaDataAttributesFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$MangaDataAttributesToJson(this);
}