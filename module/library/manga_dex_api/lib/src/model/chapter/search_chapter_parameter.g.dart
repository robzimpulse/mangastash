// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_chapter_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchChapterParameter _$SearchChapterParameterFromJson(
        Map<String, dynamic> json) =>
    SearchChapterParameter(
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      updatedAtSince: json['updatedAtSince'] as String?,
      includes: (json['includes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$IncludeEnumMap, e))
          .toList(),
      contentRating: (json['contentRating'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ContentRatingEnumMap, e))
          .toList(),
      originalLanguage: (json['originalLanguage'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$LanguageCodesEnumMap, e))
          .toList(),
      excludedOriginalLanguages:
          (json['excludedOriginalLanguages'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$LanguageCodesEnumMap, e))
              .toList(),
      createdAtSince: json['createdAtSince'] as String?,
      ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
      groups:
          (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList(),
      uploader: json['uploader'] as String?,
      volume: json['volume'] as String?,
      chapter: json['chapter'] as String?,
      translatedLanguage: (json['translatedLanguage'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$LanguageCodesEnumMap, e))
          .toList(),
      publishedAtSince: json['publishedAtSince'] as String?,
      orders: (json['orders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry($enumDecode(_$ChapterOrdersEnumMap, k),
            $enumDecode(_$OrderDirectionsEnumMap, e)),
      ),
      excludedGroups: (json['excludedGroups'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludedUploaders: (json['excludedUploaders'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SearchChapterParameterToJson(
        SearchChapterParameter instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'offset': instance.offset,
      'page': instance.page,
      'updatedAtSince': instance.updatedAtSince,
      'includes': instance.includes?.map((e) => _$IncludeEnumMap[e]!).toList(),
      'contentRating': instance.contentRating
          ?.map((e) => _$ContentRatingEnumMap[e]!)
          .toList(),
      'originalLanguage': instance.originalLanguage
          ?.map((e) => _$LanguageCodesEnumMap[e]!)
          .toList(),
      'excludedOriginalLanguages': instance.excludedOriginalLanguages
          ?.map((e) => _$LanguageCodesEnumMap[e]!)
          .toList(),
      'createdAtSince': instance.createdAtSince,
      'ids': instance.ids,
      'groups': instance.groups,
      'uploader': instance.uploader,
      'volume': instance.volume,
      'chapter': instance.chapter,
      'translatedLanguage': instance.translatedLanguage
          ?.map((e) => _$LanguageCodesEnumMap[e]!)
          .toList(),
      'publishedAtSince': instance.publishedAtSince,
      'orders': instance.orders?.map((k, e) =>
          MapEntry(_$ChapterOrdersEnumMap[k]!, _$OrderDirectionsEnumMap[e]!)),
      'excludedGroups': instance.excludedGroups,
      'excludedUploaders': instance.excludedUploaders,
    };

const _$IncludeEnumMap = {
  Include.coverArt: 'coverArt',
  Include.author: 'author',
  Include.artist: 'artist',
  Include.tag: 'tag',
  Include.creator: 'creator',
  Include.scanlationGroup: 'scanlationGroup',
  Include.manga: 'manga',
  Include.user: 'user',
};

const _$ContentRatingEnumMap = {
  ContentRating.safe: 'safe',
  ContentRating.suggestive: 'suggestive',
  ContentRating.erotica: 'erotica',
  ContentRating.pornographic: 'pornographic',
};

const _$LanguageCodesEnumMap = {
  LanguageCodes.english: 'english',
  LanguageCodes.simplifiedChinese: 'simplifiedChinese',
  LanguageCodes.traditionalChinese: 'traditionalChinese',
  LanguageCodes.brazillianPortugese: 'brazillianPortugese',
  LanguageCodes.castilianSpanish: 'castilianSpanish',
  LanguageCodes.latinAmericaSpanish: 'latinAmericaSpanish',
  LanguageCodes.romanizedJapanese: 'romanizedJapanese',
  LanguageCodes.romanizedKorean: 'romanizedKorean',
  LanguageCodes.romanizedChinese: 'romanizedChinese',
};

const _$OrderDirectionsEnumMap = {
  OrderDirections.ascending: 'ascending',
  OrderDirections.descending: 'descending',
};

const _$ChapterOrdersEnumMap = {
  ChapterOrders.createdAt: 'createdAt',
  ChapterOrders.updatedAt: 'updatedAt',
  ChapterOrders.publishAt: 'publishAt',
  ChapterOrders.readableAt: 'readableAt',
  ChapterOrders.volume: 'volume',
  ChapterOrders.chapter: 'chapter',
};
