import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

part 'tag.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Tag extends Equatable {
  final String? name;

  final String? id;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  const Tag({
    this.name,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [name, id, createdAt, updatedAt];

  factory Tag.fromDrift(TagDrift tag) {
    return Tag(
      name: tag.name,
      id: tag.id,
      createdAt: tag.createdAt,
      updatedAt: tag.updatedAt,
    );
  }

  TagTablesCompanion get toDrift {
    return TagTablesCompanion(
      name: Value.absentIfNull(name),
      id: Value.absentIfNull(id),
      createdAt: Value.absentIfNull(createdAt),
      updatedAt: Value.absentIfNull(updatedAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return _$TagFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TagToJson(this);

  Tag copyWith({
    String? name,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tag(
      name: name ?? this.name,
      id: id ?? this.id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory Tag.from({required TagData data}) {
    return Tag(
      id: data.id,
      name: data.attributes?.name?.en,
    );
  }
}
