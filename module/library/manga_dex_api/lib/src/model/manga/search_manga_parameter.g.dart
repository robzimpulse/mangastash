// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_manga_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchMangaParameter _$SearchMangaParameterFromJson(
        Map<String, dynamic> json) =>
    SearchMangaParameter(
      limit: (json['limit'] as num?)?.toInt(),
      offset: (json['offset'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
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
      title: json['title'] as String?,
      authors:
          (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      artists:
          (json['artists'] as List<dynamic>?)?.map((e) => e as String).toList(),
      year: (json['year'] as num?)?.toInt(),
      includedTags: (json['includedTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      includedTagsMode:
          $enumDecodeNullable(_$TagsModeEnumMap, json['includedTagsMode']) ??
              TagsMode.or,
      excludedTags: (json['excludedTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludedTagsMode:
          $enumDecodeNullable(_$TagsModeEnumMap, json['excludedTagsMode']) ??
              TagsMode.or,
      status: (json['status'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$MangaStatusEnumMap, e))
          .toList(),
      availableTranslatedLanguage:
          (json['availableTranslatedLanguage'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$LanguageCodesEnumMap, e))
              .toList(),
      publicationDemographic: (json['publicationDemographic'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PublicDemographicEnumMap, e))
          .toList(),
      group: json['group'] as String?,
      orders: (json['orders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry($enumDecode(_$SearchOrdersEnumMap, k),
            $enumDecode(_$OrderDirectionsEnumMap, e)),
      ),
    );

Map<String, dynamic> _$SearchMangaParameterToJson(
        SearchMangaParameter instance) =>
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
      'title': instance.title,
      'authors': instance.authors,
      'artists': instance.artists,
      'year': instance.year,
      'includedTags': instance.includedTags,
      'includedTagsMode': _$TagsModeEnumMap[instance.includedTagsMode]!,
      'excludedTags': instance.excludedTags,
      'excludedTagsMode': _$TagsModeEnumMap[instance.excludedTagsMode]!,
      'status': instance.status?.map((e) => _$MangaStatusEnumMap[e]!).toList(),
      'availableTranslatedLanguage': instance.availableTranslatedLanguage
          ?.map((e) => _$LanguageCodesEnumMap[e]!)
          .toList(),
      'publicationDemographic': instance.publicationDemographic
          ?.map((e) => _$PublicDemographicEnumMap[e]!)
          .toList(),
      'group': instance.group,
      'orders': instance.orders?.map((k, e) =>
          MapEntry(_$SearchOrdersEnumMap[k]!, _$OrderDirectionsEnumMap[e]!)),
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

const _$TagsModeEnumMap = {
  TagsMode.or: 'or',
  TagsMode.and: 'and',
};

const _$MangaStatusEnumMap = {
  MangaStatus.ongoing: 'ongoing',
  MangaStatus.completed: 'completed',
  MangaStatus.hiatus: 'hiatus',
  MangaStatus.cancelled: 'cancelled',
};

const _$PublicDemographicEnumMap = {
  PublicDemographic.shounen: 'shounen',
  PublicDemographic.shoujo: 'shoujo',
  PublicDemographic.josei: 'josei',
  PublicDemographic.seinen: 'seinen',
  PublicDemographic.none: 'none',
};

const _$OrderDirectionsEnumMap = {
  OrderDirections.ascending: 'ascending',
  OrderDirections.descending: 'descending',
};

const _$SearchOrdersEnumMap = {
  SearchOrders.title: 'title',
  SearchOrders.year: 'year',
  SearchOrders.createdAt: 'createdAt',
  SearchOrders.updatedAt: 'updatedAt',
  SearchOrders.latestUploadedChapter: 'latestUploadedChapter',
  SearchOrders.followedCount: 'followedCount',
  SearchOrders.relevance: 'relevance',
  SearchOrders.rating: 'rating',
};
