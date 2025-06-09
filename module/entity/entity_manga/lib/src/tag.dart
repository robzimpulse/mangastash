import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:text_similarity/text_similarity.dart';

part 'tag.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Tag extends Equatable with SimilarityMixin {
  final String? name;

  final String? id;

  const Tag({
    this.name,
    this.id,
  });

  @override
  List<Object?> get props => [name, id];

  @override
  List<Object?> get similarProp => props;

  factory Tag.fromDrift(TagDrift tag) {
    return Tag(name: tag.name, id: tag.id);
  }

  TagTablesCompanion get toDrift {
    return TagTablesCompanion(
      name: Value.absentIfNull(name),
      id: Value.absentIfNull(id),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return _$TagFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TagToJson(this);

  Tag copyWith({String? name, String? id}) {
    return Tag(name: name ?? this.name, id: id ?? this.id);
  }
}
