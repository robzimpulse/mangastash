import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../entity_manga.dart';

class MangaDeprecated extends Equatable {
  final String? id;

  final String? title;

  final String? coverUrl;

  final String? author;

  final String? status;

  final String? description;

  final List<MangaTagDeprecated>? tags;

  final List<MangaChapterDeprecated>? chapters;

  const MangaDeprecated({
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

  MangaDeprecated copyWith({
    String? id,
    String? title,
    String? coverUrl,
    String? author,
    String? status,
    String? description,
    List<MangaTagDeprecated>? tags,
    List<MangaChapterDeprecated>? chapters,
  }) {
    return MangaDeprecated(
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

  factory MangaDeprecated.from(
    MangaData data, {
    String? coverUrl,
    List<String>? author,
  }) {
    return MangaDeprecated(
      id: data.id,
      coverUrl: coverUrl,
      title: data.attributes?.title?.en,
      status: data.attributes?.status,
      description: data.attributes?.description?.en,
      author: author?.join(' | '),
      tags: data.attributes?.tags
          ?.map((e) => MangaTagDeprecated.from(e))
          .toList(),
    );
  }
}
