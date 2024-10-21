// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaData _$MangaDataFromJson(Map<String, dynamic> json) => MangaData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : MangaDataAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map((e) => Relationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MangaDataToJson(MangaData instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };
