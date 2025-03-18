import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:text_similarity/text_similarity.dart';

import 'base_model.dart';

part 'manga_firebase.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaFirebase extends BaseModel {
  final String? id;

  final String? title;

  final String? coverUrl;

  final String? author;

  final String? status;

  final String? description;

  final List<String>? tagsId;

  final String? webUrl;

  final String? source;

  const MangaFirebase({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.tagsId,
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
      tagsId,
      webUrl,
      source,
    ];
  }

  factory MangaFirebase.fromJson(Map<String, dynamic> json) {
    return _$MangaFirebaseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaFirebaseToJson(this);

  MangaFirebase copyWith({
    String? id,
    String? title,
    String? coverUrl,
    String? author,
    String? status,
    String? description,
    List<String>? tagsId,
    String? webUrl,
    String? source,
  }) {
    return MangaFirebase(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      author: author ?? this.author,
      status: status ?? this.status,
      description: description ?? this.description,
      tagsId: tagsId ?? this.tagsId,
      webUrl: webUrl ?? this.webUrl,
      source: source ?? this.source,
    );
  }

  @override
  double similarity(other) {
    if (other is! MangaFirebase) return 0;

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
      matcher.similar(source, other.source)?.ratio ?? 0,
    ];

    return score.average;
  }

  @override
  MangaFirebase merge(other) {
    if (other is! MangaFirebase) return this;

    return copyWith(
      id: id ?? other.id,
      title: title ?? other.title,
      coverUrl: coverUrl ?? other.coverUrl,
      author: author ?? other.author,
      status: status ?? other.status,
      description: description ?? other.description,
      tagsId: tagsId ?? other.tagsId,
      webUrl: webUrl ?? other.webUrl,
      source: source ?? other.source,
    );
  }
}
