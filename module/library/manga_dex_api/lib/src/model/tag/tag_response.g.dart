// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagResponse _$TagResponseFromJson(Map<String, dynamic> json) => TagResponse(
      json['result'] as String?,
      json['response'] as String?,
      (json['data'] as List<dynamic>?)
          ?.map((e) => TagData.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['limit'] as int?,
      json['offset'] as int?,
      json['total'] as int?,
    );

Map<String, dynamic> _$TagResponseToJson(TagResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
    };

TagData _$TagDataFromJson(Map<String, dynamic> json) => TagData(
      json['id'] as String?,
      json['type'] as String?,
      TagAttributes.fromJson(json['attributes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TagDataToJson(TagData instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
    };

TagAttributes _$TagAttributesFromJson(Map<String, dynamic> json) =>
    TagAttributes(
      json['name'] == null
          ? null
          : Title.fromJson(json['name'] as Map<String, dynamic>),
      json['group'] as String?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as num?,
    );

Map<String, dynamic> _$TagAttributesToJson(TagAttributes instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
      'name': instance.name,
      'group': instance.group,
    };
