import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class MangaChapter extends Equatable with EquatableMixin {
  final String? id;

  final String? chapter;

  final String? title;

  final String? volume;

  final String? readableAt;

  const MangaChapter({
    this.id,
    this.chapter,
    this.title,
    this.volume,
    this.readableAt,
  });

  @override
  List<Object?> get props => [id, chapter, title, volume, readableAt];

  MangaChapter copyWith({
    String? id,
    String? chapter,
    String? title,
    String? volume,
    String? readableAt,
  }) {
    return MangaChapter(
      id: id ?? this.id,
      chapter: chapter ?? this.chapter,
      title: title ?? this.title,
      volume: volume ?? this.volume,
      readableAt: readableAt ?? this.readableAt,
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
    if (readableAt != null) texts.add('$readableAt');
    if (title != null) texts.add('$title');
    return texts.join(' - ');
  }

  factory MangaChapter.from(ChapterData data) {
    return MangaChapter(
      id: data.id,
      chapter: data.attributes?.chapter,
      title: data.attributes?.title,
      volume: data.attributes?.volume,
      readableAt: data.attributes?.readableAt,
    );
  }
}
