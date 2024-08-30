import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manga_tag.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaTag extends Equatable {
  final String? name;

  final String? id;

  const MangaTag({
    required this.name,
    required this.id,
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
}
