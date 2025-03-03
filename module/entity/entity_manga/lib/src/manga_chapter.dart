import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:text_similarity/text_similarity.dart';

import '../entity_manga.dart';
import 'base/base_model.dart';

part 'manga_chapter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaChapter extends BaseModel {
  final String? id;

  final String? mangaId;

  final String? mangaTitle;

  final String? title;

  final String? volume;

  final String? chapter;

  /// must be in ISO8601 Format (yyyy-MM-ddTHH:mm:ss.mmmuuuZ)
  final String? readableAt;

  /// must be in ISO8601 Format (yyyy-MM-ddTHH:mm:ss.mmmuuuZ)
  final String? publishAt;

  final List<String>? images;

  final String? translatedLanguage;

  final String? scanlationGroup;

  final String? webUrl;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late final num? numVolume = num.tryParse(volume ?? '');

  @JsonKey(includeToJson: false, includeFromJson: false)
  late final num? numChapter = num.tryParse(chapter ?? '');

  MangaChapter({
    this.id,
    this.mangaId,
    this.mangaTitle,
    this.title,
    this.volume,
    this.chapter,
    this.readableAt,
    this.publishAt,
    this.images,
    this.translatedLanguage,
    this.scanlationGroup,
    this.webUrl,
  });

  @override
  List<Object?> get props => [
        id,
        mangaId,
        mangaTitle,
        title,
        volume,
        chapter,
        readableAt,
        publishAt,
        images,
        translatedLanguage,
        scanlationGroup,
        webUrl,
      ];

  factory MangaChapter.fromJson(Map<String, dynamic> json) {
    return _$MangaChapterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaChapterToJson(this);

  MangaChapter copyWith({
    String? id,
    String? mangaId,
    String? mangaTitle,
    String? title,
    String? volume,
    String? chapter,
    String? readableAt,
    String? publishAt,
    String? translatedLanguage,
    String? scanlationGroup,
    List<String>? images,
    String? webUrl,
  }) {
    return MangaChapter(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      title: title ?? this.title,
      volume: volume ?? this.volume,
      chapter: chapter ?? this.chapter,
      readableAt: readableAt ?? this.readableAt,
      publishAt: publishAt ?? this.publishAt,
      images: images ?? this.images,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
      scanlationGroup: scanlationGroup ?? this.scanlationGroup,
      webUrl: webUrl ?? this.webUrl,
    );
  }

  factory MangaChapter.from({required ChapterData data}) {
    final scanlation = data.relationships?.firstWhereOrNull(
      (e) => e.type == Include.scanlationGroup.rawValue,
    );

    return MangaChapter(
      id: data.id,
      title: data.attributes?.title,
      chapter: data.attributes?.chapter,
      volume: data.attributes?.volume,
      readableAt: data.attributes?.readableAt,
      publishAt: data.attributes?.publishAt,
      scanlationGroup: scanlation is Relationship<ScanlationGroupDataAttributes>
          ? scanlation.attributes?.name
          : null,
    );
  }

  @override
  double similarity(other) {
    if (other is! MangaChapter) return 0;

    final matcher = StringMatcher(
      term: TermEnum.char,
      algorithm: const LevenshteinAlgorithm(),
    );

    final score = [
      matcher.similar(mangaId, other.mangaId)?.ratio ?? 0,
      matcher.similar(mangaTitle, other.mangaTitle)?.ratio ?? 0,
      matcher.similar(volume, other.volume)?.ratio ?? 0,
      matcher.similar(chapter, other.chapter)?.ratio ?? 0,
      matcher.similar(readableAt, other.readableAt)?.ratio ?? 0,
      matcher.similar(translatedLanguage, other.translatedLanguage)?.ratio ?? 0,
      matcher.similar(scanlationGroup, scanlationGroup)?.ratio ?? 0,
      matcher.similar(webUrl, webUrl)?.ratio ?? 0,
    ];

    return score.average;
  }

  @override
  MangaChapter merge(other) {
    if (other is! MangaChapter) return this;

    return copyWith(
      id: id ?? other.id,
      mangaId: mangaId ?? other.mangaId,
      mangaTitle: mangaTitle ?? other.mangaTitle,
      volume: volume ?? other.volume,
      chapter: chapter ?? other.chapter,
      readableAt: readableAt ?? other.readableAt,
      publishAt: publishAt ?? other.publishAt,
      images: images ?? other.images,
      translatedLanguage: translatedLanguage ?? other.translatedLanguage,
      scanlationGroup: scanlationGroup ?? other.scanlationGroup,
      webUrl: webUrl ?? other.webUrl,
    );
  }
}
