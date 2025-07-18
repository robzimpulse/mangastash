import 'dart:convert';

import 'package:dio/dio.dart';

import '../model/network_entry.dart';
import 'storage.dart';

class NetworkInterceptor extends Interceptor {
  final Storage _storage;

  NetworkInterceptor({required Storage storage}) : _storage = storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final mergedQueryParameters = <String, dynamic>{};

    for (final entry in options.queryParameters.entries) {
      if (mergedQueryParameters.containsKey(entry.key)) {
        final values = [
          mergedQueryParameters[entry],
          entry.value,
        ].expand((e) => e is List ? e : [e]);
        mergedQueryParameters[entry.key] = [...values];
      } else {
        mergedQueryParameters[entry.key] = entry.value;
      }
    }

    for (final entry in options.queryParameters.entries) {
      if (!mergedQueryParameters.containsKey(entry.key)) {
        mergedQueryParameters[entry.key] = entry.value;
      }
    }

    final dynamic data = options.data;
    final fields = <FormDataFieldModel>[];
    final fieldsJson = <String, String>{};
    final files = <FormDataFileModel>[];

    if (data is FormData) {
      if (data.fields.isNotEmpty) {
        for (var entry in data.fields) {
          fields.add(FormDataFieldModel(name: entry.key, value: entry.value));
          fieldsJson[entry.key] = entry.value;
        }
      }

      if (data.files.isNotEmpty) {
        for (final entry in data.files) {
          files.add(
            FormDataFileModel(
              fileName: entry.value.filename,
              contentType: entry.value.contentType.toString(),
              length: entry.value.length,
            ),
          );
        }
      }
    }

    _storage.add(
      log: NetworkEntry(
        id: options.hashCode.toString(),
        client: 'Dio',
        secure: options.uri.scheme == 'https',
        method: options.method,
        endpoint: options.uri.path.isEmpty ? '/' : options.uri.path,
        server: options.uri.host,
        uri: options.uri.toString(),
        request: HttpRequestModel.create(
          queryParameters: mergedQueryParameters,
          headers: _rawJson(options.headers),
          contentType: options.contentType.toString(),
          size: data == null ? 0 : utf8.encode(data.toString()).length,
          body:
              fieldsJson.isNotEmpty
                  ? jsonEncode(fieldsJson)
                  : data is FormData
                  ? _rawJson(data)
                  : null,
          formDataFiles: files.isEmpty ? null : files,
          formDataFields: fields.isEmpty ? null : fields,
        ),
      ),
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    _storage.add(
      log: NetworkEntry(
        id: response.requestOptions.hashCode.toString(),
        loading: false,
        response: HttpResponseModel.create(
          status: response.statusCode,
          headers: response.headers.map,
          body: _rawJson(data),
          size: data == null ? 0 : utf8.encode(response.data.toString()).length,
        ),
      ),
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final dynamic data = response?.data;

    _storage.add(
      log: NetworkEntry(
        id: err.requestOptions.hashCode.toString(),
        loading: false,
        error: HttpErrorModel(
          error: err.toString(),
          stackTrace: err.stackTrace,
        ),
        response: HttpResponseModel.create(
          status: response == null ? -1 : response.statusCode,
          headers: err.response?.headers.map,
          size: data == null ? 0 : utf8.encode(data.toString()).length,
          body: _rawJson(data),
        ),
      ),
    );

    super.onError(err, handler);
  }

  String? _rawJson(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      return (data.isNotEmpty) ? json.encode(data) : null;
    } else if (data is List<dynamic>) {
      return (data.isNotEmpty) ? json.encode(data) : null;
    }
    if (data is String) {
      return data.isNotEmpty ? data : null;
    } else {
      return data.toString();
    }
  }
}
