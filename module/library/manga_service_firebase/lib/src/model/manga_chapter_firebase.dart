import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manga_chapter_firebase.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaChapterFirebase extends Equatable {
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

  MangaChapterFirebase({
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

  factory MangaChapterFirebase.fromFirebase(
    DocumentSnapshot<Map<String, dynamic>> json,
  ) {
    final data = json.data();
    final object = data == null
        ? MangaChapterFirebase()
        : MangaChapterFirebase.fromJson(data);
    return object.copyWith(id: json.id);
  }

  factory MangaChapterFirebase.fromJson(Map<String, dynamic> json) {
    return _$MangaChapterFirebaseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaChapterFirebaseToJson(this);

  MangaChapterFirebase copyWith({
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
    return MangaChapterFirebase(
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
}
