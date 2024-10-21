// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaResponse _$MangaResponseFromJson(Map<String, dynamic> json) =>
    MangaResponse(
      json['result'] as String?,
      json['response'] as String?,
      json['data'] == null
          ? null
          : MangaData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MangaResponseToJson(MangaResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };
