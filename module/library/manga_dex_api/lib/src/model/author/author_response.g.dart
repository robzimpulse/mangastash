// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorResponse _$AuthorResponseFromJson(Map<String, dynamic> json) =>
    AuthorResponse(
      json['result'] as String?,
      json['response'] as String?,
      (json['data'] as List<dynamic>?)
          ?.map((e) => AuthorData.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['limit'] as int?,
      json['offset'] as int?,
      json['total'] as int?,
    );

Map<String, dynamic> _$AuthorResponseToJson(AuthorResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
    };

AuthorData _$AuthorDataFromJson(Map<String, dynamic> json) => AuthorData(
      json['id'] as String?,
      json['type'] as String?,
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
      json['version'] as int?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['attributes'] == null
          ? null
          : AuthorDataAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>)
          .map((e) => Relationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AuthorDataToJson(AuthorData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
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
      'version': instance.version,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };

AuthorDataAttributes _$AuthorDataAttributesFromJson(
        Map<String, dynamic> json) =>
    AuthorDataAttributes(
      json['name'] as String?,
      json['imageUrl'] as String?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as num?,
    );

Map<String, dynamic> _$AuthorDataAttributesToJson(
        AuthorDataAttributes instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };
