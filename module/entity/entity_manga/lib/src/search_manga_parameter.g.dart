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
      orders: (json['orders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry($enumDecode(_$SearchOrdersEnumMap, k),
            $enumDecode(_$OrderDirectionsEnumMap, e)),
      ),
    );

Map<String, dynamic> _$SearchMangaParameterToJson(
        SearchMangaParameter instance) =>
    <String, dynamic>{
      'title': instance.title,
      'limit': instance.limit,
      'offset': instance.offset,
      'page': instance.page,
      'orders': instance.orders?.map((k, e) =>
          MapEntry(_$SearchOrdersEnumMap[k]!, _$OrderDirectionsEnumMap[e]!)),
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
