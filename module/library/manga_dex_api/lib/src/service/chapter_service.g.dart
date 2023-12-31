// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _ChapterService implements ChapterService {
  _ChapterService(
    this._dio, {
    this.baseUrl,
  });

  final Dio _dio;

  String? baseUrl;

  @override
  Future<SearchChapterResponse> search({
    mangaId,
    ids,
    title,
    groups,
    uploader,
    volume,
    chapter,
    translatedLanguage,
    originalLanguage,
    excludedOriginalLanguage,
    contentRating,
    createdAtSince,
    updatedAtSince,
    publishedAtSince,
    includes,
    orders,
    limit,
    offset,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'manga': mangaId,
      r'ids[]': ids,
      r'title': title,
      r'groups[]': groups,
      r'uploader': uploader,
      r'volume': volume,
      r'chapter': chapter,
      r'translatedLanguage[]': translatedLanguage,
      r'originalLanguage[]': originalLanguage,
      r'excludedOriginalLanguage[]': excludedOriginalLanguage,
      r'contentRating[]': contentRating,
      r'createdAtSince': createdAtSince,
      r'updatedAtSince': updatedAtSince,
      r'publishedAtSince': publishedAtSince,
      r'includes[]': includes,
      r'order': orders,
      r'limit': limit,
      r'offset': offset,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<SearchChapterResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/chapter',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = SearchChapterResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ChapterResponse> detail({
    id,
    includes,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'includes[]': includes};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<ChapterResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/chapter/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ChapterResponse.fromJson(_result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
