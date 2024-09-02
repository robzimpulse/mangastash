// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_manga_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchMangaResponse _$SearchMangaResponseFromJson(Map<String, dynamic> json) =>
    SearchMangaResponse(
      json['result'] as String?,
      json['response'] as String?,
      (json['data'] as List<dynamic>?)
          ?.map((e) => MangaData.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['limit'] as num?,
      json['offset'] as num?,
      json['total'] as num?,
    );

Map<String, dynamic> _$SearchMangaResponseToJson(
        SearchMangaResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
    };
