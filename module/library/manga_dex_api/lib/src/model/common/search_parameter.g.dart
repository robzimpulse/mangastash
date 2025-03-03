// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchParameter _$SearchParameterFromJson(Map<String, dynamic> json) =>
    SearchParameter(
      title: json['title'] as String?,
      limit: json['limit'] as num?,
      offset: json['offset'] as String?,
      page: json['page'] as String?,
    );

Map<String, dynamic> _$SearchParameterToJson(SearchParameter instance) =>
    <String, dynamic>{
      'title': instance.title,
      'limit': instance.limit,
      'offset': instance.offset,
      'page': instance.page,
    };
