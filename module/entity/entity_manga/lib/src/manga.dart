import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'manga_tag.dart';

part 'manga.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Manga extends Equatable with EquatableMixin {
  final String? id;

  final String? title;

  final String? coverUrl;

  final String? author;

  final String? status;

  final String? description;

  final List<MangaTag>? tags;

  const Manga({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.tags,
  });

  @override
  List<Object?> get props {
    return [id, title, coverUrl, author, status, description, tags];
  }

  factory Manga.fromJson(Map<String, dynamic> json) {
    return _$MangaFromJson(json);
  }
  Map<String, dynamic> toJson() => _$MangaToJson(this);

  Manga copyWith({
    String? id,
    String? title,
    String? coverUrl,
    String? author,
    String? status,
    String? description,
    List<MangaTag>? tags,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      author: author ?? this.author,
      status: status ?? this.status,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }
}
