// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_art_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
