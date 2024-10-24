import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';
import '../common/title.dart';
import '../tag/tag_data.dart';

part 'manga_data_attributes.g.dart';

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

  const MangaDataAttributes(
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
