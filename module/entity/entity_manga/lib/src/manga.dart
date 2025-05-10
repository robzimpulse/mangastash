import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../entity_manga.dart';

part 'manga.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Manga extends Equatable {
  final String? id;

  final String? title;

  final String? coverUrl;

  final String? author;

  final String? status;

  final String? description;

  final List<MangaTag>? tags;

  final String? webUrl;

  final MangaSourceEnum? source;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late final List<String> tagsName;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late final Map<String, MangaTag> mapTagsByName;

  Manga({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.tags,
    this.webUrl,
    this.source,
  }) {
    final Map<String, MangaTag> mapTagsByName = {};
    final List<String> tagsName = [];

    for (final tag in tags ?? <MangaTag>[]) {
      final name = tag.name;
      if (name == null) continue;
      mapTagsByName[name] = tag;
      tagsName.add(name);
    }

    this.mapTagsByName = mapTagsByName;
    this.tagsName = tagsName;
  }

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
      source,
    ];
  }

  factory Manga.fromFirebaseService(
    MangaFirebase manga, {
    List<MangaTagFirebase>? tags,
  }) {
    return Manga(
      id: manga.id,
      title: manga.title,
      coverUrl: manga.coverUrl,
      author: manga.author,
      status: manga.status,
      description: manga.description,
      webUrl: manga.webUrl,
      source:
          manga.source != null ? MangaSourceEnum.fromValue(manga.source) : null,
      tags: tags?.map((e) => MangaTag.fromFirebaseService(e)).toList(),
    );
  }

  MangaFirebase toFirebaseService() {
    return MangaFirebase(
      id: id,
      title: title,
      coverUrl: coverUrl,
      author: author,
      status: status,
      description: description,
      webUrl: webUrl,
      source: source?.value,
      tagsId: tags?.map((e) => e.id).nonNulls.toList(),
    );
  }

  factory Manga.fromDriftService(
    MangaDrift manga, {
    List<MangaTagDrift>? tags,
  }) {
    return Manga(
      id: manga.id,
      title: manga.title,
      coverUrl: manga.coverUrl,
      author: manga.author,
      status: manga.status,
      description: manga.description,
      webUrl: manga.webUrl,
      source:
          manga.source != null ? MangaSourceEnum.fromValue(manga.source) : null,
      tags: tags?.map((e) => MangaTag.fromDriftService(e)).toList(),
    );
  }

  MangaDrift toDriftService() {
    return MangaDrift(id: id,
      title: title,
      coverUrl: coverUrl,
      author: author,
      status: status,
      description: description,
      webUrl: webUrl,
      source: source?.value,
      tags: tags?.map((e) => e.toDriftService()).nonNulls.toList(),);
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
      coverUrl: filename != null
          ? 'https://uploads.mangadex.org/covers/${data.id}/$filename'
          : null,
      status: data.attributes?.status,
      tags: data.attributes?.tags
          ?.map((e) => MangaTag(name: e.attributes?.name?.en, id: e.id))
          .toList(),
      author: data.relationships
          ?.whereType<Relationship<AuthorDataAttributes>>()
          .map((e) => e.attributes?.name)
          .nonNulls
          .join(' | '),
      webUrl: 'https://mangadex.org/title/${data.id}',
    );
  }
}
