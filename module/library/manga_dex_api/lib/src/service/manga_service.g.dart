// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _MangaService implements MangaService {
  _MangaService(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  }) {
    baseUrl ??= 'https://api.mangadex.org';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<SearchMangaResponse> search({
    String? title,
    int? limit,
    int? offset,
    List<String>? authors,
    List<String>? artists,
    int? year,
    List<String>? includedTags,
    String? includedTagsMode,
    List<String>? excludedTags,
    String? excludedTagsMode,
    List<String>? status,
    List<String>? originalLanguage,
    List<String>? excludedOriginalLanguages,
    List<String>? availableTranslatedLanguage,
    List<String>? publicationDemographic,
    List<String>? ids,
    List<String>? contentRating,
    String? createdAtSince,
    String? updatedAtSince,
    List<String>? includes,
    String? group,
    Map<String, String>? orders,
  }) async {
    final _extra = <String, dynamic>{};
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
      r'excludedOriginalLanguage[]': excludedOriginalLanguages,
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
    final _headers = <String, dynamic>{
      r'Content-Type': 'application/json',
      r'Accept': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<SearchMangaResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
      contentType: 'application/json',
    )
        .compose(
          _dio.options,
          '/manga',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SearchMangaResponse _value;
    try {
      _value = await compute(deserializeSearchMangaResponse, _result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<TagResponse> tags() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{
      r'Content-Type': 'application/json',
      r'Accept': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<TagResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
      contentType: 'application/json',
    )
        .compose(
          _dio.options,
          '/manga/tag',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late TagResponse _value;
    try {
      _value = await compute(deserializeTagResponse, _result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<MangaResponse> detail({
    String? id,
    List<String>? includes,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'includes[]': includes};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Content-Type': 'application/json',
      r'Accept': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<MangaResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
      contentType: 'application/json',
    )
        .compose(
          _dio.options,
          '/manga/${id}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late MangaResponse _value;
    try {
      _value = await compute(deserializeMangaResponse, _result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SearchChapterResponse> feed({
    String? id,
    int? limit,
    int? offset,
    List<String>? translatedLanguage,
    List<String>? originalLanguage,
    List<String>? excludedOriginalLanguage,
    List<String>? contentRating,
    List<String>? excludedGroups,
    List<String>? excludedUploaders,
    String? includeFutureUpdates,
    String? createdAtSince,
    String? updatedAtSince,
    String? publishedAtSince,
    Map<String, String>? orders,
    List<String>? includes,
    int? includeEmptyPages,
    int? includeFuturePublishAt,
    int? includeExternalUrl,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'limit': limit,
      r'offset': offset,
      r'translatedLanguage[]': translatedLanguage,
      r'originalLanguage[]': originalLanguage,
      r'excludedOriginalLanguage[]': excludedOriginalLanguage,
      r'contentRating[]': contentRating,
      r'excludedGroups[]': excludedGroups,
      r'excludedUploaders[]': excludedUploaders,
      r'includeFutureUpdates': includeFutureUpdates,
      r'createdAtSince': createdAtSince,
      r'updatedAtSince': updatedAtSince,
      r'publishedAtSince': publishedAtSince,
      r'order': orders,
      r'includes[]': includes,
      r'includeEmptyPages': includeEmptyPages,
      r'includeFuturePublishAt': includeFuturePublishAt,
      r'includeExternalUrl': includeExternalUrl,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Content-Type': 'application/json',
      r'Accept': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<SearchChapterResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
      contentType: 'application/json',
    )
        .compose(
          _dio.options,
          '/manga/${id}/feed',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SearchChapterResponse _value;
    try {
      _value = await compute(deserializeSearchChapterResponse, _result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
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

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
