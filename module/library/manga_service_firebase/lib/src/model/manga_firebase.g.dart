// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaFirebase _$MangaFirebaseFromJson(Map<String, dynamic> json) =>
    MangaFirebase(
      id: json['id'] as String?,
      title: json['title'] as String?,
      coverUrl: json['cover_url'] as String?,
      author: json['author'] as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      tagsId:
          (json['tags_id'] as List<dynamic>?)?.map((e) => e as String).toList(),
      webUrl: json['web_url'] as String?,
      source: json['source'] as String?,
    );

Map<String, dynamic> _$MangaFirebaseToJson(MangaFirebase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'cover_url': instance.coverUrl,
      'author': instance.author,
      'status': instance.status,
      'description': instance.description,
      'tags_id': instance.tagsId,
      'web_url': instance.webUrl,
      'source': instance.source,
    };
