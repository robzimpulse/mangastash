import 'package:json_annotation/json_annotation.dart';

part 'identifier.g.dart';

@JsonSerializable()
class Identifier {
  final String? id;
  final String? type;
  Identifier(this.id, this.type);
  factory Identifier.fromJson(Map<String, dynamic> json) {
    return _$IdentifierFromJson(json);
  }
  Map<String, dynamic> toJson() => _$IdentifierToJson(this);
}