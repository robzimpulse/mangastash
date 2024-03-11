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
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => MangaTag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MangaToJson(Manga instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'cover_url': instance.coverUrl,
      'author': instance.author,
      'status': instance.status,
      'description': instance.description,
      'tags': instance.tags?.map((e) => e.toJson()).toList(),
    };
