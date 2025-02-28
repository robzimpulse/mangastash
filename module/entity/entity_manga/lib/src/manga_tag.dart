import 'package:json_annotation/json_annotation.dart';
import 'package:text_similarity/text_similarity.dart';

import 'base/base_model.dart';

part 'manga_tag.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaTag extends BaseModel {
  final String? name;

  final String? id;

  const MangaTag({
    this.name,
    this.id,
  });

  @override
  List<Object?> get props => [name, id];

  factory MangaTag.fromJson(Map<String, dynamic> json) {
    return _$MangaTagFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaTagToJson(this);

  MangaTag copyWith({String? name, String? id}) {
    return MangaTag(name: name ?? this.name, id: id ?? this.id);
  }

  @override
  double similarity(other) {
    if (other is! MangaTag) return 0;

    final matcher = StringMatcher(
      term: TermEnum.char,
      algorithm: const LevenshteinAlgorithm(),
    );

    return matcher.similar(name, other.name)?.ratio ?? 0;
  }

  @override
  MangaTag merge(other) {
    if (other is! MangaTag) return this;

    return copyWith(
      id: id ?? other.id,
      name: name ?? other.name,
    );
  }
}
