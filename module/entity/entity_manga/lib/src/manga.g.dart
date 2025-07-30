// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Manga _$MangaFromJson(Map<String, dynamic> json) => Manga(
  id: json['id'] as String?,
  title: json['title'] as String?,
  coverUrl: json['cover_url'] as String?,
  author: json['author'] as String?,
  status: json['status'] as String?,
  description: json['description'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
  webUrl: json['web_url'] as String?,
  source: json['source'] as String?,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MangaToJson(Manga instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'cover_url': instance.coverUrl,
  'author': instance.author,
  'status': instance.status,
  'description': instance.description,
  'tags': instance.tags?.map((e) => e.toJson()).toList(),
  'web_url': instance.webUrl,
  'source': instance.source,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
