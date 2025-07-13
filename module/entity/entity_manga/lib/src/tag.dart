import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

part 'tag.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Tag extends Equatable {
  final String? id;

  final String? name;

  final String? source;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  const Tag({
    this.id,
    this.name,
    this.source,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, source, createdAt, updatedAt];

  factory Tag.fromDrift(TagDrift tag) {
    return Tag(
      id: tag.tagId,
      name: tag.name,
      source: tag.source,
      createdAt: tag.createdAt,
      updatedAt: tag.updatedAt,
    );
  }

  TagTablesCompanion get toDrift {
    return TagTablesCompanion(
      tagId: Value.absentIfNull(id),
      name: Value.absentIfNull(name),
      source: Value.absentIfNull(source),
      createdAt: Value.absentIfNull(createdAt),
      updatedAt: Value.absentIfNull(updatedAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return _$TagFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TagToJson(this);

  Tag copyWith({
    String? id,
    String? name,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Tag.from({required TagData data}) {
    return Tag(
      id: data.id,
      name: data.attributes?.name?.en,
    );
  }

  String toJsonString() => json.encode(toJson());

  static Tag? fromJsonString(String value) {
    try {
      return Tag.fromJson(
        json.decode(value) as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }
}
