// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Source _$SourceFromJson(Map<String, dynamic> json) => Source(
      iconUrl: json['icon_url'] as String?,
      name: $enumDecodeNullable(_$MangaSourceEnumEnumMap, json['name']),
      url: json['url'] as String?,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$SourceToJson(Source instance) => <String, dynamic>{
      'icon_url': instance.iconUrl,
      'name': _$MangaSourceEnumEnumMap[instance.name],
      'url': instance.url,
      'id': instance.id,
    };

const _$MangaSourceEnumEnumMap = {
  MangaSourceEnum.mangadex: 'Manga Dex',
  MangaSourceEnum.asurascan: 'Asura Scans',
  MangaSourceEnum.mangaclash: 'Manga Clash',
};
