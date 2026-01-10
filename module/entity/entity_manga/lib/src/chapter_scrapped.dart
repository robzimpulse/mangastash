import 'package:equatable/equatable.dart';

class ChapterScrapped extends Equatable {
  final String? id;

  final String? mangaId;

  final String? title;

  final String? volume;

  final String? chapter;

  final String? readableAtRaw;

  final String? publishAtRaw;

  final String? lastReadAtRaw;

  final List<String>? images;

  final String? translatedLanguage;

  final String? scanlationGroup;

  final String? webUrl;

  final String? createdAtRaw;

  final String? updatedAtRaw;

  const ChapterScrapped({
    this.id,
    this.mangaId,
    this.title,
    this.volume,
    this.chapter,
    this.readableAtRaw,
    this.publishAtRaw,
    this.images,
    this.translatedLanguage,
    this.scanlationGroup,
    this.webUrl,
    this.lastReadAtRaw,
    this.createdAtRaw,
    this.updatedAtRaw,
  });

  @override
  List<Object?> get props => [
    id,
    mangaId,
    title,
    volume,
    chapter,
    readableAtRaw,
    publishAtRaw,
    images,
    translatedLanguage,
    scanlationGroup,
    webUrl,
    lastReadAtRaw,
    createdAtRaw,
    updatedAtRaw,
  ];
}
