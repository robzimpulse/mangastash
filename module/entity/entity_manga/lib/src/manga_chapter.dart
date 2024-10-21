import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manga_chapter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaChapter extends Equatable {
  final String? id;

  final String? mangaId;

  final String? title;

  final String? volume;

  final String? chapter;

  final String? readableAt;

  final String? publishAt;

  final List<String>? images;

  final String? translatedLanguage;

  final String? scanlationGroup;

  late final num? numVolume = num.tryParse(volume ?? '');

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
      ];

  factory MangaChapter.fromJson(Map<String, dynamic> json) {
    return _$MangaChapterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaChapterToJson(this);

  MangaChapter copyWith({
    String? id,
    String? mangaId,
    String? title,
    String? volume,
    String? chapter,
    String? readableAt,
    String? publishAt,
    String? translatedLanguage,
    String? scanlationGroup,
    List<String>? images,
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
    );
  }
}
