import 'package:json_annotation/json_annotation.dart';

import 'identifier.dart';

part 'relationship.g.dart';

@JsonSerializable()
class Relationship extends Identifier {
  final String? related;
  final RelationshipAttribute? attributes;
  Relationship(super.id, super.type, this.related, this.attributes);
  factory Relationship.fromJson(Map<String, dynamic> json) {
    return _$RelationshipFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$RelationshipToJson(this);
}

@JsonSerializable()
class RelationshipAttribute {
  final String? description;
  final String? volume;
  final String? fileName;
  final String? locale;
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  RelationshipAttribute(
    this.description,
    this.volume,
    this.fileName,
    this.locale,
    this.createdAt,
    this.updatedAt,
    this.version,
  );
  factory RelationshipAttribute.fromJson(Map<String, dynamic> json) {
    return _$RelationshipAttributeFromJson(json);
  }
  Map<String, dynamic> toJson() => _$RelationshipAttributeToJson(this);
}
