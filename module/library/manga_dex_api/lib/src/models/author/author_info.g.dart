// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorInfo _$AuthorInfoFromJson(Map<String, dynamic> json) => AuthorInfo(
      json['result'] as String?,
      json['response'] as String?,
      json['data'] == null
          ? null
          : AuthorInfoData.fromJson(json['data'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map(
              (e) => AuthorInfoRelationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AuthorInfoToJson(AuthorInfo instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
      'relationships': instance.relationships,
    };

AuthorInfoData _$AuthorInfoDataFromJson(Map<String, dynamic> json) =>
    AuthorInfoData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : AuthorInfoAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthorInfoDataToJson(AuthorInfoData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
    };

AuthorInfoAttributes _$AuthorInfoAttributesFromJson(
        Map<String, dynamic> json) =>
    AuthorInfoAttributes(
      json['name'] as String?,
      json['imageUrl'] as String?,
      json['twitter'] as String?,
      json['pixiv'] as String?,
      json['melonBook'] as String?,
      json['fanBox'] as String?,
      json['booth'] as String?,
      json['nicoVideo'] as String?,
      json['skeb'] as String?,
      json['fantia'] as String?,
      json['tumblr'] as String?,
      json['youtube'] as String?,
      json['weibo'] as String?,
      json['naver'] as String?,
      json['website'] as String?,
      json['createdAt'] as String?,
      json['updateAt'] as String?,
      json['version'] as int?,
    );

Map<String, dynamic> _$AuthorInfoAttributesToJson(
        AuthorInfoAttributes instance) =>
    <String, dynamic>{
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'twitter': instance.twitter,
      'pixiv': instance.pixiv,
      'melonBook': instance.melonBook,
      'fanBox': instance.fanBox,
      'booth': instance.booth,
      'nicoVideo': instance.nicoVideo,
      'skeb': instance.skeb,
      'fantia': instance.fantia,
      'tumblr': instance.tumblr,
      'youtube': instance.youtube,
      'weibo': instance.weibo,
      'naver': instance.naver,
      'website': instance.website,
      'createdAt': instance.createdAt,
      'updateAt': instance.updateAt,
      'version': instance.version,
    };

AuthorInfoRelationship _$AuthorInfoRelationshipFromJson(
        Map<String, dynamic> json) =>
    AuthorInfoRelationship(
      json['id'] as String?,
      json['type'] as String?,
    );

Map<String, dynamic> _$AuthorInfoRelationshipToJson(
        AuthorInfoRelationship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
    };
