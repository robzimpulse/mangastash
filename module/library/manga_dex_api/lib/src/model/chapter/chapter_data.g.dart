// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterData _$ChapterDataFromJson(Map<String, dynamic> json) => ChapterData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : ChapterDataAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      Relationship.from(json['relationships'] as List),
    );

Map<String, dynamic> _$ChapterDataToJson(ChapterData instance) =>
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
