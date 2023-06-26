// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_custom_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleCustomListResponse _$SingleCustomListResponseFromJson(
        Map<String, dynamic> json) =>
    SingleCustomListResponse(
      json['result'] as String?,
      json['response'] as String?,
      json['data'] == null
          ? null
          : SingleCustomListResponseData.fromJson(
              json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SingleCustomListResponseToJson(
        SingleCustomListResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };

SingleCustomListResponseData _$SingleCustomListResponseDataFromJson(
        Map<String, dynamic> json) =>
    SingleCustomListResponseData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : SingleCustomListResponseAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map((e) => SingleCustomListResponseRelationship.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SingleCustomListResponseDataToJson(
        SingleCustomListResponseData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };

SingleCustomListResponseAttributes _$SingleCustomListResponseAttributesFromJson(
        Map<String, dynamic> json) =>
    SingleCustomListResponseAttributes(
      json['name'] as String?,
      json['visibility'] as String?,
      json['version'] as int?,
    );

Map<String, dynamic> _$SingleCustomListResponseAttributesToJson(
        SingleCustomListResponseAttributes instance) =>
    <String, dynamic>{
      'name': instance.name,
      'visibility': instance.visibility,
      'version': instance.version,
    };

SingleCustomListResponseRelationship
    _$SingleCustomListResponseRelationshipFromJson(Map<String, dynamic> json) =>
        SingleCustomListResponseRelationship(
          json['id'] as String?,
          json['type'] as String?,
        );

Map<String, dynamic> _$SingleCustomListResponseRelationshipToJson(
        SingleCustomListResponseRelationship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
    };
