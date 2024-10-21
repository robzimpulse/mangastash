// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_art_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoverArtResponse _$CoverArtResponseFromJson(Map<String, dynamic> json) =>
    CoverArtResponse(
      json['result'] as String?,
      json['response'] as String?,
      json['data'] == null
          ? null
          : CoverArtData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CoverArtResponseToJson(CoverArtResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };
