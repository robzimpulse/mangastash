import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';

part 'chapter_data_attributes.g.dart';

@JsonSerializable()
class ChapterDataAttributes extends Attribute {
  final String? volume;
  final String? chapter;
  final String? title;
  final String? translatedLanguage;
  final String? externalUrl;
  final String? publishAt;
  final String? readableAt;

  const ChapterDataAttributes(
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
