import 'package:json_annotation/json_annotation.dart';

import '../common/identifier.dart';
import '../common/relationship.dart';
import 'cover_art_data_attributes.dart';

part 'cover_art_data.g.dart';

@JsonSerializable()
class CoverArtData extends Identifier {
  final CoverArtDataAttributes? attributes;
  final List<Relationship>? relationships;

  CoverArtData(super.id, super.type, this.attributes, this.relationships);

  factory CoverArtData.fromJson(Map<String, dynamic> json) {
    return _$CoverArtDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CoverArtDataToJson(this);
}