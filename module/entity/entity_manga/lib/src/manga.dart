import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';
import 'package:text_similarity/text_similarity.dart';

import '../entity_manga.dart';

part 'manga.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Manga extends BaseModel {
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

  factory Manga.fromFirebaseService(MangaFirebase manga, {List<MangaTag>? tags,}) {
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
      tags: tags,
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
      tagsId: tags?.map((e) => e.id).whereNotNull().toList(),
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
          .whereNotNull()
          .join(' | '),
      webUrl: 'https://mangadex.org/title/${data.id}',
    );
  }

  @override
  double similarity(other) {
    if (other is! Manga) return 0;

    final matcher = StringMatcher(
      term: TermEnum.char,
      algorithm: const LevenshteinAlgorithm(),
    );

    final score = [
      matcher.similar(title, other.title)?.ratio ?? 0,
      matcher.similar(coverUrl, other.coverUrl)?.ratio ?? 0,
      matcher.similar(author, other.author)?.ratio ?? 0,
      matcher.similar(status, other.status)?.ratio ?? 0,
      matcher.similar(description, other.description)?.ratio ?? 0,
      matcher.similar(webUrl, other.webUrl)?.ratio ?? 0,
      matcher.similar(source?.name, other.source?.name)?.ratio ?? 0,
    ];

    return score.average;
  }

  @override
  Manga merge(other) {
    if (other is! Manga) return this;

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
