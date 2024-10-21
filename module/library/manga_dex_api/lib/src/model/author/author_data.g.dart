// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorData _$AuthorDataFromJson(Map<String, dynamic> json) => AuthorData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : AuthorDataAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      Relationship.from(json['relationships'] as List),
    );

Map<String, dynamic> _$AuthorDataToJson(AuthorData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships
          ?.map((e) => e.toJson(
                (value) => value,
              ))
          .toList(),
    };
