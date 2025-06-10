import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../tag.dart';

part 'metadata.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Metadata extends Equatable {

  const Metadata({this.tags = const []});

  final List<Tag>? tags;

  @override
  List<Object?> get props => [tags];

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return _$MetadataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MetadataToJson(this);
}