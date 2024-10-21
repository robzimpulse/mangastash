// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Relationship<T> _$RelationshipFromJson<T extends Attribute>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    Relationship<T>(
      json['id'] as String?,
      json['type'] as String?,
      json['related'] as String?,
      _$nullableGenericFromJson(json['attributes'], fromJsonT),
    );

Map<String, dynamic> _$RelationshipToJson<T extends Attribute>(
  Relationship<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'related': instance.related,
      'attributes': _$nullableGenericToJson(instance.attributes, toJsonT),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
