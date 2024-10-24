import 'package:json_annotation/json_annotation.dart';

import '../common/identifier.dart';
import '../common/relationship.dart';
import 'chapter_data_attributes.dart';

part 'chapter_data.g.dart';

@JsonSerializable()
class ChapterData extends Identifier {
  final ChapterDataAttributes? attributes;

  @JsonKey(name: 'relationships', fromJson: Relationship.from)
  final List<Relationship>? relationships;

  const ChapterData(super.id, super.type, this.attributes, this.relationships);

  factory ChapterData.fromJson(Map<String, dynamic> json) {
    return _$ChapterDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChapterDataToJson(this);
}

