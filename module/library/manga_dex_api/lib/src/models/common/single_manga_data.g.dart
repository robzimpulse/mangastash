// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_manga_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleManga _$SingleMangaFromJson(Map<String, dynamic> json) => SingleManga(
      json['result'] as String?,
      json['response'] as String?,
      json['data'] == null
          ? null
          : SingleMangaData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SingleMangaToJson(SingleManga instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };

SingleMangaData _$SingleMangaDataFromJson(Map<String, dynamic> json) =>
    SingleMangaData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map((e) => Relationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SingleMangaDataToJson(SingleMangaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };
