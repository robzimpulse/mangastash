import 'package:json_annotation/json_annotation.dart';

part 'attributes.g.dart';

@JsonSerializable()
class Attributes {
  Attributes();
  factory Attributes.fromJson(Map<String, dynamic> json) {
    return _$AttributesFromJson(json);
  }
  Map<String, dynamic> toJson() => _$AttributesToJson(this);
}
