import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../database/database.dart';
import '../extension/value_or_null_extension.dart';
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
  final String? createdAt;
  final String? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  factory MangaDrift.fromCompanion(
    MangaTablesCompanion manga,
    List<MangaTagTablesCompanion> tags,
  ) {
    return MangaDrift(
      id: manga.id.valueOrNull,
      title: manga.title.valueOrNull,
      coverUrl: manga.coverUrl.valueOrNull,
      author: manga.author.valueOrNull,
      status: manga.status.valueOrNull,
      description: manga.description.valueOrNull,
      webUrl: manga.webUrl.valueOrNull,
      source: manga.source.valueOrNull,
      tags: tags.map((e) => MangaTagDrift.fromCompanion(e)).toList(),
      createdAt: manga.createdAt.valueOrNull,
      updatedAt: manga.updatedAt.valueOrNull,
    );
  }

  MangaTablesCompanion toCompanion() {
    return MangaTablesCompanion(
      createdAt: Value.absentIfNull(createdAt),
      updatedAt: Value.absentIfNull(updatedAt),
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
    createdAt,
    updatedAt,
      ];
}
