// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_data_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagDataAttributes _$TagDataAttributesFromJson(Map<String, dynamic> json) =>
    TagDataAttributes(
      json['name'] == null
          ? null
          : Title.fromJson(json['name'] as Map<String, dynamic>),
      json['group'] as String?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as num?,
    );

Map<String, dynamic> _$TagDataAttributesToJson(TagDataAttributes instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
      'name': instance.name,
      'group': instance.group,
    };
