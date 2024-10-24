import 'package:json_annotation/json_annotation.dart';

part 'attribute.g.dart';

@JsonSerializable()
class Attribute {
  final String? createdAt;
  final String? updatedAt;
  final num? version;

  const Attribute(
    this.createdAt,
    this.updatedAt,
    this.version,
  );

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return _$AttributeFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AttributeToJson(this);
}
