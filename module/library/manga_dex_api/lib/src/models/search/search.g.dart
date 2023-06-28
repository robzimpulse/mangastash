// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Search _$SearchFromJson(Map<String, dynamic> json) => Search(
      (json['data'] as List<dynamic>?)
          ?.map((e) => SearchData.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['limit'] as int?,
      json['offset'] as int?,
      json['total'] as int?,
      json['result'] as String?,
      json['response'] as String?,
    );

Map<String, dynamic> _$SearchToJson(Search instance) => <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
    };

SearchData _$SearchDataFromJson(Map<String, dynamic> json) => SearchData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map((e) => SearchRelationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchDataToJson(SearchData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };

SearchRelationship _$SearchRelationshipFromJson(Map<String, dynamic> json) =>
    SearchRelationship(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : SearchAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchRelationshipToJson(SearchRelationship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
    };

SearchAttributes _$SearchAttributesFromJson(Map<String, dynamic> json) =>
    SearchAttributes(
      json['description'] as String?,
      json['volume'] as String?,
      json['fileName'] as String?,
      json['locale'] as String?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as int?,
    );

Map<String, dynamic> _$SearchAttributesToJson(SearchAttributes instance) =>
    <String, dynamic>{
      'description': instance.description,
      'volume': instance.volume,
      'fileName': instance.fileName,
      'locale': instance.locale,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
    };
