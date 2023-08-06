import 'package:equatable/equatable.dart';

class MangaChapter extends Equatable with EquatableMixin {
  final String? id;

  final String? chapter;

  final String? title;

  const MangaChapter({
    this.id,
    this.chapter,
    this.title,
  });

  @override
  List<Object?> get props => [id, chapter, title];

  MangaChapter copyWith({
    String? id,
    String? chapter,
    String? title,
  }) {
    return MangaChapter(
      id: id ?? this.id,
      chapter: chapter ?? this.chapter,
      title: title ?? this.title,
    );
  }

  String get name => '$chapter - $title';
}
