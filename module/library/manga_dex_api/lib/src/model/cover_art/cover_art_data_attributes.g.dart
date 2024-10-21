// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_art_data_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
