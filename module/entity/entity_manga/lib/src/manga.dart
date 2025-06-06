import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:text_similarity/text_similarity.dart';

import '../entity_manga.dart';

part 'manga.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Manga extends Equatable with SimilarityMixin {
  final String? id;

  final String? title;

  final String? coverUrl;

  final String? author;

  final String? status;

  final String? description;

  final List<MangaTag>? tags;

  final String? webUrl;

  final MangaSourceEnum? source;

  const Manga({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.tags,
    this.webUrl,
    this.source,
  });

  @override
  List<Object?> get props {
    return [
      id,
      title,
      coverUrl,
      author,
      status,
      description,
      tags,
      webUrl,
      source?.value,
    ];
  }

  @override
  List<Object?> get similarProp => [id, webUrl, source, title];

  static Manga? fromDatabase(MangaModel? model) {
    return model?.manga?.let(
      (manga) => Manga.fromDrift(manga, tags: model.tags),
    );
  }

  factory Manga.fromDrift(MangaDrift manga, {List<TagDrift> tags = const []}) {
    return Manga(
      id: manga.id,
      title: manga.title,
      coverUrl: manga.coverUrl,
      author: manga.author,
      status: manga.status,
      description: manga.description,
      webUrl: manga.webUrl,
      source: manga.source?.let((source) => MangaSourceEnum.fromValue(source)),
      tags: tags.map((e) => MangaTag.fromDrift(e)).toList(),
    );
  }

  MangaTablesCompanion get toDrift {
    return MangaTablesCompanion(
      id: Value.absentIfNull(id),
      title: Value.absentIfNull(title),
      coverUrl: Value.absentIfNull(coverUrl),
      author: Value.absentIfNull(author),
      status: Value.absentIfNull(status),
      description: Value.absentIfNull(description),
      webUrl: Value.absentIfNull(webUrl),
      source: Value.absentIfNull(source?.value),
    );
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
    String? webUrl,
    MangaSourceEnum? source,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      author: author ?? this.author,
      status: status ?? this.status,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      webUrl: webUrl ?? this.webUrl,
      source: source ?? this.source,
    );
  }

  factory Manga.from({required MangaData data}) {
    final filename = data.relationships
        ?.whereType<Relationship<CoverArtDataAttributes>>()
        .firstOrNull
        ?.attributes
        ?.fileName;

    return Manga(
      id: data.id,
      title: data.attributes?.title?.en,
      description: data.attributes?.description?.en,
      coverUrl: filename?.let<String?>(
        (filename) => data.id?.let(
          (id) => 'https://uploads.mangadex.org/covers/$id/$filename',
        ),
      ),
      status: data.attributes?.status,
      tags: data.attributes?.tags
          ?.map((e) => MangaTag(name: e.attributes?.name?.en, id: e.id))
          .toList(),
      author: data.relationships
          ?.whereType<Relationship<AuthorDataAttributes>>()
          .map((e) => e.attributes?.name)
          .nonNulls
          .join(' | '),
      webUrl: data.id?.let((id) => 'https://mangadex.org/title/$id'),
    );
  }

  Manga merge(Manga other) {
    return copyWith(
      id: id ?? other.id,
      title: title ?? other.title,
      coverUrl: coverUrl ?? other.coverUrl,
      author: author ?? other.author,
      status: status ?? other.status,
      description: description ?? other.description,
      tags: tags ?? other.tags,
      webUrl: webUrl ?? other.webUrl,
      source: source ?? other.source,
    );
  }
}
