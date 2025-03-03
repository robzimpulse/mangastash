// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_manga_chapter_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchMangaChapterParameter _$SearchMangaChapterParameterFromJson(
        Map<String, dynamic> json) =>
    SearchMangaChapterParameter(
      title: json['title'] as String?,
      limit: json['limit'] as num?,
      offset: json['offset'] as String?,
      page: json['page'] as String?,
      orders: (json['orders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry($enumDecode(_$ChapterOrdersEnumMap, k),
            $enumDecode(_$OrderDirectionsEnumMap, e)),
      ),
      status: (json['status'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$MangaStatusEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$SearchMangaChapterParameterToJson(
        SearchMangaChapterParameter instance) =>
    <String, dynamic>{
      'title': instance.title,
      'limit': instance.limit,
      'offset': instance.offset,
      'page': instance.page,
      'orders': instance.orders?.map((k, e) =>
          MapEntry(_$ChapterOrdersEnumMap[k]!, _$OrderDirectionsEnumMap[e]!)),
      'status': instance.status?.map((e) => _$MangaStatusEnumMap[e]!).toList(),
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

const _$MangaStatusEnumMap = {
  MangaStatus.ongoing: 'ongoing',
  MangaStatus.completed: 'completed',
  MangaStatus.haitus: 'haitus',
  MangaStatus.cancelled: 'cancelled',
};
