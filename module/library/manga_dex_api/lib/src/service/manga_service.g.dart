// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _MangaService implements MangaService {
  _MangaService(
    this._dio, {
    this.baseUrl,
  });

  final Dio _dio;

  String? baseUrl;

  @override
  Future<SearchResponse> search({
    title,
    limit,
    offset,
    authors,
    artists,
    year,
    includedTags,
    includedTagsMode,
    excludedTags,
    excludedTagsMode,
    status,
    originalLanguage,
    excludedOriginalLanguages,
    availableTranslatedLanguage,
    publicationDemographic,
    ids,
    contentRating,
    createdAtSince,
    updatedAtSince,
    includes,
    group,
    orders,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'title': title,
      r'limit': limit,
      r'offset': offset,
      r'authors[]': authors,
      r'artists[]': artists,
      r'year': year,
      r'includedTags[]': includedTags,
      r'includedTagsMode': includedTagsMode,
      r'excludedTags[]': excludedTags,
      r'excludedTagsMode': excludedTagsMode,
      r'status[]': status,
      r'originalLanguage[]': originalLanguage,
      r'excludedOriginalLanguages[]': excludedOriginalLanguages,
      r'availableTranslatedLanguage[]': availableTranslatedLanguage,
      r'publicationDemographic[]': publicationDemographic,
      r'ids[]': ids,
      r'contentRating[]': contentRating,
      r'createdAtSince': createdAtSince,
      r'updatedAtSince': updatedAtSince,
      r'includes[]': includes,
      r'group': group,
      r'order': orders,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<SearchResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/manga',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = SearchResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<TagResponse> tags() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<TagResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/manga/tag',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = TagResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<MangaResponse> detail({id}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<MangaResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/manga/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = MangaResponse.fromJson(_result.data!);
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
