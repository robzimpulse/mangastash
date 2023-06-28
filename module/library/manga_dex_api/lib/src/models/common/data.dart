///@nodoc
import 'package:json_annotation/json_annotation.dart';

import 'attributes.dart';
import 'relationships.dart';

part 'data.g.dart';

///@nodoc
@JsonSerializable()
class Data {
  final String? id;
  final String? type;
  Data(this.id, this.type);
  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
  Map<String, dynamic> toJson() => _$DataToJson(this);
}
