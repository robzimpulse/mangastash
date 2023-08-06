// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Relationship _$RelationshipFromJson(Map<String, dynamic> json) => Relationship(
      json['id'] as String?,
      json['type'] as String?,
      json['related'] as String?,
      json['attributes'] == null
          ? null
          : RelationshipAttribute.fromJson(
              json['attributes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RelationshipToJson(Relationship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'related': instance.related,
      'attributes': instance.attributes,
    };

RelationshipAttribute _$RelationshipAttributeFromJson(
        Map<String, dynamic> json) =>
    RelationshipAttribute(
      json['description'] as String?,
      json['volume'] as String?,
      json['fileName'] as String?,
      json['locale'] as String?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as int?,
    );

Map<String, dynamic> _$RelationshipAttributeToJson(
        RelationshipAttribute instance) =>
    <String, dynamic>{
      'description': instance.description,
      'volume': instance.volume,
      'fileName': instance.fileName,
      'locale': instance.locale,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
    };
