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
      json['limit'] as num?,
      json['offset'] as num?,
      json['total'] as num?,
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
