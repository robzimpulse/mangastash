// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_search_manga_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceSearchMangaParameter _$SourceSearchMangaParameterFromJson(
  Map<String, dynamic> json,
) => SourceSearchMangaParameter(
  source: json['source'] as String,
  parameter: SearchMangaParameter.fromJson(
    json['parameter'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SourceSearchMangaParameterToJson(
  SourceSearchMangaParameter instance,
) => <String, dynamic>{
  'source': instance.source,
  'parameter': instance.parameter.toJson(),
};
