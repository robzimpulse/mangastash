import 'package:json_annotation/json_annotation.dart';

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
class MangaDataAttributes {
  final Title? title;
  final List<Title?>? altTitle;
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
  final String? createdAt;
  final String? updatedAt;
  final num? version;
  final String? latestUploadedChapter;
  final List<String?>? availableTranslatedLanguages;
  final List<TagData?> tags;
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
    this.createdAt,
    this.updatedAt,
    this.version,
    this.latestUploadedChapter,
    this.availableTranslatedLanguages,
    this.tags,
    this.altTitle,
  );
  factory MangaDataAttributes.fromJson(Map<String, dynamic> json) {
    return _$MangaDataAttributesFromJson(json);
  }
  Map<String, dynamic> toJson() => _$MangaDataAttributesToJson(this);
}