import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';
import '../common/title.dart';

part 'tag_data_attributes.g.dart';

@JsonSerializable()
class TagDataAttributes extends Attribute {
  final Title? name;
  final String? group;

  const TagDataAttributes(
    this.name,
    this.group,
    super.createdAt,
    super.updatedAt,
    super.version,
  );

  factory TagDataAttributes.fromJson(Map<String, dynamic> json) {
    return _$TagDataAttributesFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$TagDataAttributesToJson(this);
}
