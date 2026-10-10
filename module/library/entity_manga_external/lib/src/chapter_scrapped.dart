import 'package:equatable/equatable.dart';

import 'json_fields.dart';

/// A chapter as scraped from an external source.
///
/// Created by Dart source parsers directly, or by
/// `ChapterScrapped.fromJson(map)` from the JSON returned by a scripted
/// source. Unknown JSON keys are ignored; a field with the wrong type throws a
/// [FormatException] naming the field.
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

  factory ChapterScrapped.fromJson(Map<String, dynamic> json) {
    return ChapterScrapped(
      id: optionalString(json, 'id'),
      mangaId: optionalString(json, 'mangaId'),
      title: optionalString(json, 'title'),
      volume: optionalString(json, 'volume'),
      chapter: optionalString(json, 'chapter'),
      readableAt: optionalString(json, 'readableAt'),
      publishAt: optionalString(json, 'publishAt'),
      images: optionalStringList(json, 'images'),
      translatedLanguage: optionalString(json, 'translatedLanguage'),
      scanlationGroup: optionalString(json, 'scanlationGroup'),
      webUrl: optionalString(json, 'webUrl'),
      lastReadAt: optionalString(json, 'lastReadAt'),
      createdAt: optionalString(json, 'createdAt'),
      updatedAt: optionalString(json, 'updatedAt'),
    );
  }

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
