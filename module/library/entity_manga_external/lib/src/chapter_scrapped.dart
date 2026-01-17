import 'package:equatable/equatable.dart';
import 'package:eval_annotation/eval_annotation.dart';

@Bind()
class ChapterScrapped extends Equatable {
  final String? id;

  final String? mangaId;

  final String? title;

  final String? volume;

  final String? chapter;

  final String? readableAt;

  final String? publishAt;

  final String? lastReadAt;

  final List<String>? images;

  final String? translatedLanguage;

  final String? scanlationGroup;

  final String? webUrl;

  final String? createdAt;

  final String? updatedAt;

  const ChapterScrapped({
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
    this.createdAt,
    this.updatedAt,
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
    createdAt,
    updatedAt,
  ];
}
