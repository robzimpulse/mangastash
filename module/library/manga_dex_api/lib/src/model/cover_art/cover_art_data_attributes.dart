import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';

part 'cover_art_data_attributes.g.dart';

@JsonSerializable()
class CoverArtDataAttributes extends Attribute {
  final String? description;
  final String? volume;
  final String? fileName;
  final String? locale;

  const CoverArtDataAttributes(
    this.description,
    this.volume,
    this.fileName,
    this.locale,
    super.createdAt,
    super.updatedAt,
    super.version,
  );

  factory CoverArtDataAttributes.fromJson(Map<String, dynamic> json) {
    return _$CoverArtDataAttributesFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$CoverArtDataAttributesToJson(this);
}
