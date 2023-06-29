import 'package:json_annotation/json_annotation.dart';

part 'relationship.g.dart';

///@nodoc
@JsonSerializable()
class Relationship {
  final String? id;
  final String? type;
  Relationship(this.id, this.type);
  factory Relationship.fromJson(Map<String, dynamic> json) {
    return _$RelationshipFromJson(json);
  }
  Map<String, dynamic> toJson() => _$RelationshipToJson(this);
}