import 'package:core_environment/core_environment.dart';
import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class MangaChapterDeprecated extends Equatable {
  final String? id;

  final String? chapter;

  final String? title;

  final String? volume;

  final String? readableAt;

  final List<String>? images;

  final List<String>? imagesDataSaver;

  const MangaChapterDeprecated({
    this.id,
    this.chapter,
    this.title,
    this.volume,
    this.readableAt,
    this.images,
    this.imagesDataSaver,
  });

  @override
  List<Object?> get props => [
        id,
        chapter,
        title,
        volume,
        readableAt,
        images,
        imagesDataSaver,
      ];

  MangaChapterDeprecated copyWith({
    String? id,
    String? chapter,
    String? title,
    String? volume,
    String? readableAt,
    List<String>? images,
    List<String>? imagesDataSaver,
  }) {
    return MangaChapterDeprecated(
      id: id ?? this.id,
      chapter: chapter ?? this.chapter,
      title: title ?? this.title,
      volume: volume ?? this.volume,
      readableAt: readableAt ?? this.readableAt,
      images: images ?? this.images,
      imagesDataSaver: imagesDataSaver ?? this.imagesDataSaver,
    );
  }

  String get top {
    List<String> texts = [];
    if (volume != null) texts.add('Vol $volume');
    if (chapter != null) texts.add('Ch $chapter');
    return texts.join(' ');
  }

  String get bottom {
    List<String> texts = [];
    if (readableAt != null) texts.add('${readableAt?.asDateTime?.ddLLLLyy}');
    if (title != null) texts.add('$title');
    return texts.join(' - ');
  }

  factory MangaChapterDeprecated.from(
    ChapterData data, {
    List<String>? images,
    List<String>? imagesDataSaver,
  }) {
    return MangaChapterDeprecated(
      id: data.id,
      chapter: data.attributes?.chapter,
      title: data.attributes?.title,
      volume: data.attributes?.volume,
      readableAt: data.attributes?.readableAt,
      images: images,
      imagesDataSaver: imagesDataSaver,
    );
  }
}
