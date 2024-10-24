import 'package:json_annotation/json_annotation.dart';

import '../common/identifier.dart';
import 'tag_data_attributes.dart';

part 'tag_data.g.dart';

@JsonSerializable()
class TagData extends Identifier {
  final TagDataAttributes? attributes;

  const TagData(super.id, super.type, this.attributes);

  factory TagData.fromJson(Map<String, dynamic> json) {
    return _$TagDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TagDataToJson(this);
}
