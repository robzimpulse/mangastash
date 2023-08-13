// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_art_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoverArtResponse _$CoverArtResponseFromJson(Map<String, dynamic> json) =>
    CoverArtResponse(
      json['result'] as String?,
      json['response'] as String?,
      json['data'] == null
          ? null
          : CoverArtData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CoverArtResponseToJson(CoverArtResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };

CoverArtData _$CoverArtDataFromJson(Map<String, dynamic> json) => CoverArtData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : CoverArtDataAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map((e) => Relationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CoverArtDataToJson(CoverArtData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };

CoverArtDataAttributes _$CoverArtDataAttributesFromJson(
        Map<String, dynamic> json) =>
    CoverArtDataAttributes(
      json['description'] as String?,
      json['volume'] as String?,
      json['fileName'] as String?,
      json['locale'] as String?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as num?,
    );

Map<String, dynamic> _$CoverArtDataAttributesToJson(
        CoverArtDataAttributes instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
      'description': instance.description,
      'volume': instance.volume,
      'fileName': instance.fileName,
      'locale': instance.locale,
    };
