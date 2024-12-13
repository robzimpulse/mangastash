import 'package:equatable/equatable.dart';

import 'http_error_model.dart';
import 'http_request_model.dart';
import 'http_response_model.dart';

class HttpActivityModel extends Equatable {
  const HttpActivityModel._({
    required this.id,
    required this.createdTime,
    required this.client,
    required this.loading,
    required this.secure,
    required this.method,
    required this.endpoint,
    required this.server,
    required this.uri,
    this.request,
    this.response,
    this.error,
  });

  final int id;
  final DateTime createdTime;
  final String client;
  final bool loading;
  final bool secure;
  final String method;
  final String endpoint;
  final String server;
  final String uri;

  final HttpRequestModel? request;
  final HttpResponseModel? response;
  final HttpErrorModel? error;

  int get duration {
    var duration = Duration.zero;
    final request = this.request;
    final response = this.response;
    if (request != null && response != null) {
      duration = response.time.difference(request.time);
    }
    return duration.inMilliseconds;
  }

  factory HttpActivityModel.empty() {
    return HttpActivityModel._(
      id: 0,
      createdTime: DateTime.now(),
      client: '',
      loading: true,
      secure: false,
      method: '',
      endpoint: '',
      server: '',
      uri: '',
    );
  }

  factory HttpActivityModel.create({
    required int id,
    String client = '',
    bool loading = true,
    bool secure = false,
    String method = '',
    String endpoint = '',
    String server = '',
    String uri = '',
    HttpRequestModel? request,
    HttpResponseModel? response,
    HttpErrorModel? error,
  }) {
    return HttpActivityModel._(
      id: id,
      createdTime: DateTime.now(),
      client: client,
      loading: loading,
      secure: secure,
      method: method,
      endpoint: endpoint,
      server: server,
      uri: uri,
      request: request,
      response: response,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdTime,
        client,
        loading,
        secure,
        method,
        endpoint,
        server,
        uri,
        duration,
        request,
        response,
        error,
      ];

  HttpActivityModel copyWith({
    String? client,
    bool? loading,
    bool? secure,
    String? method,
    String? endpoint,
    String? server,
    String? uri,
    HttpRequestModel? request,
    HttpResponseModel? response,
    HttpErrorModel? error,
  }) {
    return HttpActivityModel._(
      id: id,
      createdTime: createdTime,
      client: client ?? this.client,
      loading: loading ?? this.loading,
      secure: secure ?? this.secure,
      method: method ?? this.method,
      endpoint: endpoint ?? this.endpoint,
      server: server ?? this.server,
      uri: uri ?? this.uri,
      request: request ?? this.request,
      response: response ?? this.response,
      error: error ?? this.error,
    );
  }
}
