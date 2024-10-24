import 'package:json_annotation/json_annotation.dart';

import '../common/identifier.dart';
import '../common/relationship.dart';
import 'manga_data_attributes.dart';

part 'manga_data.g.dart';

@JsonSerializable()
class MangaData extends Identifier {
  final MangaDataAttributes? attributes;

  @JsonKey(name: 'relationships', fromJson: Relationship.from)
  final List<Relationship>? relationships;

  const MangaData(super.id, super.type, this.attributes, this.relationships);

  factory MangaData.fromJson(Map<String, dynamic> json) {
    return _$MangaDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaDataToJson(this);
}