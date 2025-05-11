import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../database/database.dart';
import 'manga_tag_drift.dart';

class MangaDrift extends Equatable {
  final String? id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final String? webUrl;
  final String? source;
  final List<MangaTagDrift> tags;

  const MangaDrift({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.webUrl,
    this.source,
    this.tags = const [],
  });

  factory MangaDrift.fromCompanion(
    MangaTablesCompanion manga,
    List<MangaTagTablesCompanion> tags,
  ) {
    return MangaDrift(
      id: manga.id.value,
      title: manga.title.value,
      coverUrl: manga.coverUrl.value,
      author: manga.author.value,
      status: manga.status.value,
      description: manga.description.value,
      webUrl: manga.webUrl.value,
      source: manga.source.value,
      tags: tags.map((e) => MangaTagDrift.fromCompanion(e)).toList(),
    );
  }

  MangaTablesCompanion toCompanion() {
    return MangaTablesCompanion(
      createdAt: Value(DateTime.now().toIso8601String()),
      updatedAt: Value(DateTime.now().toIso8601String()),
      id: Value.absentIfNull(id),
      title: Value.absentIfNull(title),
      coverUrl: Value.absentIfNull(coverUrl),
      author: Value.absentIfNull(author),
      status: Value.absentIfNull(status),
      description: Value.absentIfNull(description),
      webUrl: Value.absentIfNull(webUrl),
      source: Value.absentIfNull(source),
    );
  }

  @override
  List<Object?> get props => [
        title,
        coverUrl,
        author,
        status,
        description,
        webUrl,
        source,
        tags.map((e) => e.name),
      ];
}
