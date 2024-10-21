// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorResponse _$AuthorResponseFromJson(Map<String, dynamic> json) =>
    AuthorResponse(
      json['result'] as String?,
      json['response'] as String?,
      json['data'] == null
          ? null
          : AuthorData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthorResponseToJson(AuthorResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };
