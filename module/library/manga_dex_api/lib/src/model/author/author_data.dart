import 'package:json_annotation/json_annotation.dart';

import '../common/identifier.dart';
import '../common/relationship.dart';
import 'author_data_attributes.dart';

part 'author_data.g.dart';

@JsonSerializable()
class AuthorData extends Identifier {
  final AuthorDataAttributes? attributes;
  final List<Relationship>? relationships;

  AuthorData(super.id, super.type, this.attributes, this.relationships);

  factory AuthorData.fromJson(Map<String, dynamic> json) {
    return _$AuthorDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AuthorDataToJson(this);
}
