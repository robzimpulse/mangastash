import 'package:equatable/equatable.dart';

class MangaChapter extends Equatable with EquatableMixin {
  final String? id;

  final String? chapter;

  final String? title;

  final String? volume;

  const MangaChapter({
    this.id,
    this.chapter,
    this.title,
    this.volume,
  });

  @override
  List<Object?> get props => [id, chapter, title, volume];

  MangaChapter copyWith({
    String? id,
    String? chapter,
    String? title,
    String? volume,
  }) {
    return MangaChapter(
      id: id ?? this.id,
      chapter: chapter ?? this.chapter,
      title: title ?? this.title,
      volume: volume ?? this.volume,
    );
  }

  String get name {
    List<String> texts = [];
    if (volume != null) texts.add('Vol $volume');
    if (chapter != null) texts.add('Ch $chapter');
    return texts.join(' ');
  }
}
