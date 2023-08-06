// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attribute _$AttributeFromJson(Map<String, dynamic> json) => Attribute(
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as num?,
    );

Map<String, dynamic> _$AttributeToJson(Attribute instance) => <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
    };
