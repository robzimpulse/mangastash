// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagData _$TagDataFromJson(Map<String, dynamic> json) => TagData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : TagDataAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TagDataToJson(TagData instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
    };
