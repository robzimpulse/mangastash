import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

part 'chapter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Chapter extends Equatable {
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

  final DateTime? createdAt;

  final DateTime? updatedAt;

  const Chapter({
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

  static Chapter? fromDatabase(ChapterModel? model) {
    return model?.chapter?.let(
      (chapter) => Chapter.fromDrift(chapter, images: model.images),
    );
  }

  factory Chapter.fromDrift(
    ChapterDrift chapter, {
    List<ImageDrift> images = const [],
  }) {
    return Chapter(
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
      createdAt: chapter.createdAt,
      updatedAt: chapter.updatedAt,
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
      createdAt: Value.absentIfNull(createdAt),
      updatedAt: Value.absentIfNull(updatedAt),
    );
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return _$ChapterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChapterToJson(this);

  Chapter merge({Chapter? other}) {
    return copyWith(
      id: id ?? other?.id,
      mangaId: mangaId ?? other?.mangaId,
      title: title ?? other?.title,
      volume: volume ?? other?.volume,
      chapter: chapter ?? other?.chapter,
      readableAt: readableAt ?? other?.readableAt,
      publishAt: publishAt ?? other?.publishAt,
      images: images?.isNotEmpty == true ? images : other?.images,
      translatedLanguage: translatedLanguage ?? other?.translatedLanguage,
      scanlationGroup: scanlationGroup ?? other?.scanlationGroup,
      webUrl: webUrl ?? other?.webUrl,
      lastReadAt: lastReadAt ?? other?.lastReadAt,
      createdAt: createdAt ?? other?.createdAt,
      updatedAt: updatedAt ?? other?.updatedAt,
    );
  }

  Chapter copyWith({
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chapter(
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Chapter.from({required ChapterData data}) {
    final scanlation = data.relationships?.firstWhereOrNull(
      (e) => e.type == Include.scanlationGroup.rawValue,
    );

    return Chapter(
      id: data.id,
      title: data.attributes?.title,
      chapter: data.attributes?.chapter,
      volume: data.attributes?.volume,
      scanlationGroup: scanlation is Relationship<ScanlationGroupDataAttributes>
          ? scanlation.attributes?.name
          : null,
    );
  }

  String toJsonString() => json.encode(toJson());

  static Chapter? fromJsonString(String value) {
    try {
      return Chapter.fromJson(
        json.decode(value) as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }
}
