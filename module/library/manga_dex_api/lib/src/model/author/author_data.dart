import 'package:json_annotation/json_annotation.dart';

import '../common/identifier.dart';
import '../common/relationship.dart';
import 'author_data_attributes.dart';

part 'author_data.g.dart';

@JsonSerializable()
class AuthorData extends Identifier {
  final AuthorDataAttributes? attributes;

  @JsonKey(name: 'relationships', fromJson: Relationship.from)
  final List<Relationship>? relationships;

  const AuthorData(super.id, super.type, this.attributes, this.relationships);

  factory AuthorData.fromJson(Map<String, dynamic> json) {
    return _$AuthorDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AuthorDataToJson(this);
}
