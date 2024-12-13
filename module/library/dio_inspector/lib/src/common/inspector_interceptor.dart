import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../model/form_data_field_model.dart';
import '../model/form_data_file_model.dart';
import '../model/http_activity_model.dart';
import '../model/http_error_model.dart';
import '../model/http_request_model.dart';
import '../model/http_response_model.dart';
import 'extensions.dart';
import 'http_activity_storage.dart';

class InspectorInterceptor extends InterceptorsWrapper {
  final bool kIsDebug;
  final HttpActivityStorage storage;
  NavigatorObserver? navigatorKey;

  InspectorInterceptor({
    required this.kIsDebug,
    required this.storage,
    this.navigatorKey,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kIsDebug) {
      handler.next(options);
      return;
    }

    final mergedQueryParameters = <String, dynamic>{};

    for (final entry in options.queryParameters.entries) {
      if (mergedQueryParameters.containsKey(entry.key)) {
        mergedQueryParameters[entry.key] = [
          mergedQueryParameters[entry],
          entry.value,
        ].expand((e) => e is List ? e : [e]).toList();
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

    storage.addActivity(
      activity: HttpActivityModel.create(
        id: options.hashCode,
        method: options.method,
        endpoint: options.uri.path.isEmpty ? '/' : options.uri.path,
        server: options.uri.host,
        client: 'Dio',
        uri: options.uri.toString(),
        secure: options.uri.scheme == 'https',
        request: HttpRequestModel.create(
          queryParameters: mergedQueryParameters,
          headers: options.headers.encodeRawJson,
          contentType: options.contentType.toString(),
          size: data == null ? 0 : utf8.encode(data.toString()).length,
          body: fieldsJson.isNotEmpty
              ? jsonEncode(fieldsJson)
              : data is FormData
                  ? data.encodeRawJson
                  : null,
          formDataFiles: files.isEmpty ? null : files,
          formDataFields: fields.isEmpty ? null : fields,
        ),
      ),
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!kIsDebug) {
      handler.next(response);
      return;
    }

    final data = response.data;
    storage.addResponse(
      id: response.requestOptions.hashCode,
      response: HttpResponseModel.create(
        status: response.statusCode,
        headers: response.headers.map,
        body: data.encodeRawJson,
        size: data == null ? 0 : utf8.encode(response.data.toString()).length,
      ),
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kIsDebug) {
      handler.next(err);
      return;
    }

    final response = err.response;
    final data = response?.data;

    storage.addError(
      id: err.requestOptions.hashCode,
      error: HttpErrorModel(
        error: err.toString(),
        stackTrace: err.stackTrace,
      ),
    );

    storage.addResponse(
      id: err.requestOptions.hashCode,
      response: HttpResponseModel.create(
        status: response == null ? -1 : response.statusCode,
        headers: err.response?.headers.map,
        size: data == null ? 0 : utf8.encode(data.toString()).length,
        body: data.encodeRawJson,
      ),
    );

    handler.next(err);
  }
}
