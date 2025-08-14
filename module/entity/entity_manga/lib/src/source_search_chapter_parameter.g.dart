// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_search_chapter_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceSearchChapterParameter _$SourceSearchChapterParameterFromJson(
  Map<String, dynamic> json,
) => SourceSearchChapterParameter(
  source: $enumDecodeNullable(_$SourceEnumEnumMap, json['source']),
  parameter:
      json['parameter'] == null
          ? null
          : SearchChapterParameter.fromJson(
            json['parameter'] as Map<String, dynamic>,
          ),
  mangaId: json['manga_id'] as String?,
);

Map<String, dynamic> _$SourceSearchChapterParameterToJson(
  SourceSearchChapterParameter instance,
) => <String, dynamic>{
  'source': _$SourceEnumEnumMap[instance.source],
  'manga_id': instance.mangaId,
  'parameter': instance.parameter?.toJson(),
};

const _$SourceEnumEnumMap = {
  SourceEnum.mangadex: 'mangadex',
  SourceEnum.mangaclash: 'mangaclash',
  SourceEnum.asurascan: 'asurascan',
};
