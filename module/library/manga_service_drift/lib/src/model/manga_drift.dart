import '../database/database.dart';
import 'manga_tag_drift.dart';

class MangaDrift {
  final String id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final String? webUrl;
  final String? source;
  final String createdAt;
  final String updatedAt;
  final List<MangaTagDrift>? tags;

  const MangaDrift({
    required this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.webUrl,
    this.source,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
  });

  factory MangaDrift.fromDb({
    required MangaTable manga,
    List<MangaTagTable>? tags,
  }) {
    return MangaDrift(
      id: manga.id,
      title: manga.title,
      coverUrl: manga.coverUrl,
      author: manga.author,
      status: manga.status,
      description: manga.description,
      webUrl: manga.webUrl,
      source: manga.source,
      createdAt: manga.createdAt,
      updatedAt: manga.updatedAt,
      tags: tags?.map((e) => MangaTagDrift.fromDb(tag: e)).toList(),
    );
  }

  MangaTable toDb() {
    return MangaTable(
      id: id,
      title: title,
      coverUrl: coverUrl,
      author: author,
      status: status,
      description: description,
      webUrl: webUrl,
      source: source,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
