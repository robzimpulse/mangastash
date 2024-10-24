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
