///@nodoc
import 'package:json_annotation/json_annotation.dart';

import 'alt_titles.dart';
import 'description.dart';
import 'tags.dart';
import 'title.dart';

part 'attributes.g.dart';

///@nodoc
@JsonSerializable()
class Attributes {
  final Title? title;
  final List<AltTitles>? altTitles;
  final Description? description;
  final bool? isLocked;
  final String? originalLanguage;
  final String? lastVolume;
  final String? lastChapter;
  final String? publicationDemographic;
  final String? status;
  final int? year;
  final String? contentRating;
  final List<Tags>? tags;
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  Attributes(
    this.title,
    this.altTitles,
    this.description,
    this.isLocked,
    this.originalLanguage,
    this.lastVolume,
    this.lastChapter,
    this.publicationDemographic,
    this.status,
    this.year,
    this.contentRating,
    this.tags,
    this.createdAt,
    this.updatedAt,
    this.version,
  );

  factory Attributes.fromJson(Map<String, dynamic> json) =>
      _$AttributesFromJson(json);

  Map<String, dynamic> toJson() => _$AttributesToJson(this);
}
