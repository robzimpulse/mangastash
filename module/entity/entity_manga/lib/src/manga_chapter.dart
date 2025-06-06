import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:text_similarity/text_similarity.dart';

part 'manga_chapter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaChapter extends Equatable with SimilarityMixin {
  final String? id;

  final String? mangaId;

  final String? title;

  final String? volume;

  final String? chapter;

  final DateTime? readableAt;

  final DateTime? publishAt;

  final DateTime? lastReadAt;

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
    this.title,
    this.volume,
    this.chapter,
    this.readableAt,
    this.publishAt,
    this.images,
    this.translatedLanguage,
    this.scanlationGroup,
    this.webUrl,
    this.lastReadAt,
  });

  @override
  List<Object?> get props => [
        id,
        mangaId,
        title,
        volume,
        chapter,
        readableAt,
        publishAt,
        images,
        translatedLanguage,
        scanlationGroup,
        webUrl,
        lastReadAt,
      ];

  @override
  List<Object?> get similarProp => props;

  factory MangaChapter.fromDrift(
    ChapterDrift chapter, {
    List<ImageDrift> images = const [],
  }) {
    return MangaChapter(
      id: chapter.id,
      mangaId: chapter.mangaId,
      title: chapter.title,
      volume: chapter.volume,
      chapter: chapter.chapter,
      readableAt: chapter.readableAt,
      publishAt: chapter.publishAt,
      images: images.map((e) => e.webUrl).toList(),
      translatedLanguage: chapter.translatedLanguage,
      scanlationGroup: chapter.scanlationGroup,
      webUrl: chapter.webUrl,
      lastReadAt: chapter.lastReadAt,
    );
  }

  ChapterTablesCompanion get toDrift {
    return ChapterTablesCompanion(
      id: Value.absentIfNull(id),
      mangaId: Value.absentIfNull(mangaId),
      title: Value.absentIfNull(title),
      volume: Value.absentIfNull(volume),
      chapter: Value.absentIfNull(chapter),
      readableAt: Value.absentIfNull(readableAt),
      publishAt: Value.absentIfNull(publishAt),
      translatedLanguage: Value.absentIfNull(translatedLanguage),
      scanlationGroup: Value.absentIfNull(scanlationGroup),
      webUrl: Value.absentIfNull(webUrl),
      lastReadAt: Value.absentIfNull(lastReadAt),
    );
  }

  factory MangaChapter.fromJson(Map<String, dynamic> json) {
    return _$MangaChapterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaChapterToJson(this);

  MangaChapter merge({MangaChapter? other}) {
    return copyWith(
      id: other?.id ?? id,
      mangaId: other?.mangaId ?? mangaId,
      title: other?.title ?? title,
      volume: other?.volume ?? volume,
      chapter: other?.chapter ?? chapter,
      readableAt: other?.readableAt ?? readableAt,
      publishAt: other?.publishAt ?? publishAt,
      images: other?.images ?? images,
      translatedLanguage: other?.translatedLanguage ?? translatedLanguage,
      scanlationGroup: other?.scanlationGroup ?? scanlationGroup,
      webUrl: other?.webUrl ?? webUrl,
      lastReadAt: other?.lastReadAt ?? lastReadAt,
    );
  }

  MangaChapter copyWith({
    String? id,
    String? mangaId,
    String? title,
    String? volume,
    String? chapter,
    DateTime? readableAt,
    DateTime? publishAt,
    DateTime? lastReadAt,
    String? translatedLanguage,
    String? scanlationGroup,
    List<String>? images,
    String? webUrl,
  }) {
    return MangaChapter(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      title: title ?? this.title,
      volume: volume ?? this.volume,
      chapter: chapter ?? this.chapter,
      readableAt: readableAt ?? this.readableAt,
      publishAt: publishAt ?? this.publishAt,
      images: images ?? this.images,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
      scanlationGroup: scanlationGroup ?? this.scanlationGroup,
      webUrl: webUrl ?? this.webUrl,
      lastReadAt: lastReadAt ?? this.lastReadAt,
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
      readableAt: data.attributes?.readableAt?.asDateTime,
      publishAt: data.attributes?.publishAt?.asDateTime,
      scanlationGroup: scanlation is Relationship<ScanlationGroupDataAttributes>
          ? scanlation.attributes?.name
          : null,
    );
  }
}
