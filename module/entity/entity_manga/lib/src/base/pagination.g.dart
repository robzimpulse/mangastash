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
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      offset: (json['offset'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      hasNextPage: json['has_next_page'] as bool?,
      sourceUrl: json['source_url'] as String?,
      metadata: json['metadata'] == null
          ? null
          : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
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
      'metadata': instance.metadata?.toJson(),
      'source_url': instance.sourceUrl,
    };
