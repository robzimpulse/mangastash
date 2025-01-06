// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_manga_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchMangaParameter _$SearchMangaParameterFromJson(
        Map<String, dynamic> json) =>
    SearchMangaParameter(
      title: json['title'] as String?,
      limit: json['limit'] as num?,
      offset: json['offset'] as String?,
      page: json['page'] as String?,
    );

Map<String, dynamic> _$SearchMangaParameterToJson(
        SearchMangaParameter instance) =>
    <String, dynamic>{
      'title': instance.title,
      'limit': instance.limit,
      'offset': instance.offset,
      'page': instance.page,
    };
