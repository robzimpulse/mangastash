// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagResponse _$TagResponseFromJson(Map<String, dynamic> json) => TagResponse(
      (json['data'] as List<dynamic>?)
          ?.map((e) => TagData.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['result'] as String?,
      json['response'] as String?,
      json['limit'] as int?,
      json['offset'] as int?,
      json['total'] as int?,
    );

Map<String, dynamic> _$TagResponseToJson(TagResponse instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
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
      json['id'] as String?,
      json['type'] as String?,
      json['name'] == null
          ? null
          : Title.fromJson(json['name'] as Map<String, dynamic>),
      json['group'] as String?,
      json['version'] as int?,
    );

Map<String, dynamic> _$TagAttributesToJson(TagAttributes instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'group': instance.group,
      'version': instance.version,
    };