import 'package:json_annotation/json_annotation.dart';

import 'identifier.dart';

part 'relationship.g.dart';

@JsonSerializable()
class Relationship extends Identifier {
  final String? related;

  Relationship(super.id, super.type, this.related);

  factory Relationship.fromJson(Map<String, dynamic> json) {
    return _$RelationshipFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$RelationshipToJson(this);
}
