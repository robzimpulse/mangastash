// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_followed_manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserFollowedManga _$UserFollowedMangaFromJson(Map<String, dynamic> json) =>
    UserFollowedManga(
      (json['data'] as List<dynamic>?)
          ?.map(
              (e) => UserFollowedMangaData.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['limit'] as int?,
      json['offset'] as int?,
      json['total'] as int?,
    );

Map<String, dynamic> _$UserFollowedMangaToJson(UserFollowedManga instance) =>
    <String, dynamic>{
      'data': instance.data,
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
    };

UserFollowedMangaData _$UserFollowedMangaDataFromJson(
        Map<String, dynamic> json) =>
    UserFollowedMangaData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map((e) => Relationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserFollowedMangaDataToJson(
        UserFollowedMangaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };
