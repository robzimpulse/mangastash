// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_source_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaSourceFirebase _$MangaSourceFirebaseFromJson(Map<String, dynamic> json) =>
    MangaSourceFirebase(
      iconUrl: json['icon_url'] as String?,
      name: json['name'] as String?,
      url: json['url'] as String?,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$MangaSourceFirebaseToJson(
  MangaSourceFirebase instance,
) => <String, dynamic>{
  'icon_url': instance.iconUrl,
  'name': instance.name,
  'url': instance.url,
  'id': instance.id,
};
