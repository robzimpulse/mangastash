// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination<T> _$PaginationFromJson<T extends Equatable>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    Pagination<T>(
      data: (json['data'] as List<dynamic>?)?.map(fromJsonT).toList(),
      page: json['page'] as String?,
      limit: (json['limit'] as num?)?.toInt(),
      offset: json['offset'] as String?,
      total: (json['total'] as num?)?.toInt(),
      hasNextPage: json['has_next_page'] as bool?,
      sourceUrl: json['source_url'] as String?,
    );

Map<String, dynamic> _$PaginationToJson<T extends Equatable>(
  Pagination<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': instance.data?.map(toJsonT).toList(),
      'page': instance.page,
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
      'has_next_page': instance.hasNextPage,
      'source_url': instance.sourceUrl,
    };
