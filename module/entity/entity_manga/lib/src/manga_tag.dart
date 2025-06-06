import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:text_similarity/text_similarity.dart';

part 'manga_tag.g.dart';

// TODO: rename to `Tag`
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaTag extends Equatable with SimilarityMixin {
  final String? name;

  final String? id;

  const MangaTag({
    this.name,
    this.id,
  });

  @override
  List<Object?> get props => [name, id];

  @override
  List<Object?> get similarProp => props;

  factory MangaTag.fromDrift(TagDrift tag) {
    return MangaTag(name: tag.name, id: tag.id);
  }

  TagTablesCompanion get toDrift {
    return TagTablesCompanion(
      name: Value.absentIfNull(name),
      id: Value.absentIfNull(id),
    );
  }

  factory MangaTag.fromJson(Map<String, dynamic> json) {
    return _$MangaTagFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaTagToJson(this);

  MangaTag copyWith({String? name, String? id}) {
    return MangaTag(name: name ?? this.name, id: id ?? this.id);
  }
}
