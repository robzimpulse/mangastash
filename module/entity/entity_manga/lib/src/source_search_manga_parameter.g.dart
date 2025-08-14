// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_search_manga_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceSearchMangaParameter _$SourceSearchMangaParameterFromJson(
  Map<String, dynamic> json,
) => SourceSearchMangaParameter(
  source: $enumDecode(_$SourceEnumEnumMap, json['source']),
  parameter: SearchMangaParameter.fromJson(
    json['parameter'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SourceSearchMangaParameterToJson(
  SourceSearchMangaParameter instance,
) => <String, dynamic>{
  'source': _$SourceEnumEnumMap[instance.source]!,
  'parameter': instance.parameter.toJson(),
};

const _$SourceEnumEnumMap = {
  SourceEnum.mangadex: 'mangadex',
  SourceEnum.mangaclash: 'mangaclash',
  SourceEnum.asurascan: 'asurascan',
};
