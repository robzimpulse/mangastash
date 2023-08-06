import 'package:equatable/equatable.dart';

import '../entity_manga.dart';

class Manga extends Equatable with EquatableMixin {
  final String? id;

  final String? title;

  final String? coverUrl;

  final String? author;

  final String? status;

  final String? description;

  final List<MangaTag>? tags;

  final List<MangaChapter>? chapters;

  const Manga({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.tags,
    this.chapters,
  });

  @override
  List<Object?> get props {
    return [id, title, coverUrl, author, status, description, tags, chapters];
  }

  Manga copyWith({
    String? id,
    String? title,
    String? coverUrl,
    String? author,
    String? status,
    String? description,
    List<MangaTag>? tags,
    List<MangaChapter>? chapters,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      author: author ?? this.author,
      status: status ?? this.status,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      chapters: chapters ?? this.chapters,
    );
  }
}
