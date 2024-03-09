import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../entity_manga.dart';

class Manga extends Equatable with EquatableMixin {
  final String? id;

  final String? title;

  final String? coverUrl;

  final String? author;

  final String? status;

  final String? description;

  final List<MangaTagDeprecated>? tags;

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
    List<MangaTagDeprecated>? tags,
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

  factory Manga.from(MangaData data, {String? coverUrl, List<String>? author}) {
    return Manga(
      id: data.id,
      coverUrl: coverUrl,
      title: data.attributes?.title?.en,
      status: data.attributes?.status,
      description: data.attributes?.description?.en,
      author: author?.join(' | '),
      tags: data.attributes?.tags?.map((e) => MangaTagDeprecated.from(e)).toList(),
    );
  }
}
