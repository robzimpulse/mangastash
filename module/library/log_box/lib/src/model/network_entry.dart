import 'package:equatable/equatable.dart';
import 'package:universal_io/io.dart';

import 'entry.dart';

class NetworkEntry extends Entry {
  final String? client;
  final bool? loading;
  final bool? secure;
  final String? method;
  final String? endpoint;
  final String? server;
  final String? uri;
  final HttpRequestModel? request;
  final HttpResponseModel? response;
  final HttpErrorModel? error;

  NetworkEntry({
    String? id,
    DateTime? timestamp,
    this.client,
    this.loading = true,
    this.secure,
    this.method,
    this.endpoint,
    this.server,
    this.uri,
    this.request,
    this.response,
    this.error,
  }) : super(id: id, timestamp: timestamp);

  Duration get duration {
    final request = this.request;
    final response = this.response;
    if (request != null && response != null) {
      return response.time.difference(request.time);
    }
    return Duration.zero;
  }

  NetworkEntry copyWith({
    bool? loading,
    HttpRequestModel? request,
    HttpResponseModel? response,
    HttpErrorModel? error,
  }) {
    return NetworkEntry(
      id: id,
      timestamp: timestamp,
      client: client,
      loading: loading ?? this.loading,
      secure: secure,
      method: method,
      endpoint: endpoint,
      server: server,
      uri: uri,
      request: request ?? this.request,
      response: response ?? this.response,
      error: error ?? this.error,
    );
  }
}

class HttpErrorModel extends Equatable {
  final dynamic error;
  final StackTrace? stackTrace;

  const HttpErrorModel({this.error, this.stackTrace});

  @override
  List<Object?> get props => [error, stackTrace];
}

class HttpResponseModel extends Equatable {
  factory HttpResponseModel.create({
    int? status,
    int size = 0,
    String? body,
    Map<String, List<String>>? headers,
  }) {
    return HttpResponseModel._(
      status: status,
      size: size,
      time: DateTime.timestamp(),
      body: body,
      headers: headers,
    );
  }

  const HttpResponseModel._({
    this.status,
    required this.size,
    required this.time,
    this.body,
    this.headers,
  });

  final int? status;
  final int size;
  final DateTime time;
  final String? body;
  final Map<String, List<String>>? headers;

  @override
  List<Object?> get props => [status, size, time, body, headers];
}

class HttpRequestModel extends Equatable {
  factory HttpRequestModel.create({
    int size = 0,
    String? headers,
    String? body,
    String? contentType,
    List<Cookie> cookies = const <Cookie>[],
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    List<FormDataFileModel>? formDataFiles,
    List<FormDataFieldModel>? formDataFields,
  }) {
    return HttpRequestModel._(
      size: size,
      time: DateTime.timestamp(),
      headers: headers,
      body: body,
      contentType: contentType,
      cookies: cookies,
      queryParameters: queryParameters,
      formDataFiles: formDataFiles,
      formDataFields: formDataFields,
    );
  }

  const HttpRequestModel._({
    required this.size,
    required this.time,
    this.headers,
    this.body,
    this.contentType,
    required this.cookies,
    required this.queryParameters,
    this.formDataFiles,
    this.formDataFields,
  });

  final int size;
  final DateTime time;
  final String? headers;
  final String? body;
  final String? contentType;
  final List<Cookie> cookies;
  final Map<String, dynamic> queryParameters;
  final List<FormDataFileModel>? formDataFiles;
  final List<FormDataFieldModel>? formDataFields;

  @override
  List<Object?> get props => [
    size,
    time,
    headers,
    body,
    contentType,
    cookies,
    queryParameters,
    formDataFiles,
    formDataFields,
  ];

  HttpRequestModel copyWith({
    int? size,
    String? headers,
    String? body,
    String? contentType,
    List<Cookie>? cookies,
    Map<String, dynamic>? queryParameters,
    List<FormDataFileModel>? formDataFiles,
    List<FormDataFieldModel>? formDataFields,
  }) {
    return HttpRequestModel._(
      size: size ?? this.size,
      time: time,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      contentType: contentType ?? this.contentType,
      cookies: cookies ?? this.cookies,
      queryParameters: queryParameters ?? this.queryParameters,
      formDataFiles: formDataFiles ?? this.formDataFiles,
      formDataFields: formDataFields ?? this.formDataFields,
    );
  }
}

class FormDataFieldModel extends Equatable {
  const FormDataFieldModel({required this.name, required this.value});

  final String name;
  final String value;

  @override
  List<Object?> get props => [name, value];
}

class FormDataFileModel extends Equatable {
  const FormDataFileModel({
    this.fileName,
    required this.contentType,
    required this.length,
  });

  final String? fileName;
  final String contentType;
  final int length;

  @override
  List<Object?> get props => [fileName, contentType, length];
}
