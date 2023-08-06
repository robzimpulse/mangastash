// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Relationship _$RelationshipFromJson(Map<String, dynamic> json) => Relationship(
      json['id'] as String?,
      json['type'] as String?,
      json['related'] as String?,
    );

Map<String, dynamic> _$RelationshipToJson(Relationship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'related': instance.related,
    };
