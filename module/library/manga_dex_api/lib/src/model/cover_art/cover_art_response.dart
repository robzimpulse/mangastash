import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';
import '../common/identifier.dart';
import '../common/relationship.dart';
import '../common/response.dart';

part 'cover_art_response.g.dart';

///@nodoc
@JsonSerializable()
class CoverArtResponse extends Response {
  final CoverArtData? data;

  CoverArtResponse(super.result, super.response, this.data);

  factory CoverArtResponse.fromJson(Map<String, dynamic> json) {
    return _$CoverArtResponseFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$CoverArtResponseToJson(this);
}

@JsonSerializable()
class CoverArtData extends Identifier {
  final CoverArtDataAttributes? attributes;
  final List<Relationship?>? relationships;
  CoverArtData(super.id, super.type, this.attributes, this.relationships);
  factory CoverArtData.fromJson(Map<String, dynamic> json) {
    return _$CoverArtDataFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$CoverArtDataToJson(this);
}

@JsonSerializable()
class CoverArtDataAttributes extends Attribute {
  final String? description;
  final String? volume;
  final String? fileName;
  final String? locale;
  CoverArtDataAttributes(
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
