import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:universal_io/io.dart';

import '../common/extension.dart';
import '../widget/item_column.dart';
import 'entry.dart';

class NetworkEntry extends Entry {
  final String? client;
  final bool? loading;
  final String? method;
  final Uri? uri;
  final HttpRequestModel? request;
  final HttpResponseModel? response;
  final HttpErrorModel? error;

  NetworkEntry({
    String? id,
    DateTime? timestamp,
    this.client,
    this.loading = true,
    this.method,
    this.uri,
    this.request,
    this.response,
    this.error,
  }) : super(id: id, timestamp: timestamp);

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
      method: method,
      uri: uri,
      request: request ?? this.request,
      response: response ?? this.response,
      error: error ?? this.error,
    );
  }

  @override
  Map<Tab, Widget> tabs(BuildContext context) {
    return {
      const Tab(
        text: 'Overview',
        icon: Icon(Icons.info, color: Colors.white),
      ): CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Method', value: method),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Url', value: uri.toString()),
                ),
                ItemColumn(name: 'Duration', value: duration.toString()),
              ],
            ),
          ),
        ],
      ),
      const Tab(
        text: 'Request',
        icon: Icon(Icons.arrow_upward, color: Colors.white),
      ): CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Timestamp',
                    value: request?.time.toIso8601String(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Headers',
                    value: request?.headers?.json,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Query',
                    value: request?.queryParameters.json,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Size (bytes)',
                    value: request?.size.toString(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Body', value: request?.body),
                ),
              ],
            ),
          ),
        ],
      ),
      const Tab(
        text: 'Response',
        icon: Icon(Icons.arrow_downward, color: Colors.white),
      ): CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Timestamp',
                    value: response?.time.toIso8601String(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Size (bytes)',
                    value: response?.size.toString(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Headers',
                    value: response?.headers?.json,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Body', value: response?.body),
                ),
              ],
            ),
          ),
        ],
      ),
      const Tab(
        text: 'Error',
        icon: Icon(Icons.warning, color: Colors.white),
      ): CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Error',
                    value: error?.error.toString(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Stack Trace',
                    value: error?.stackTrace.toString(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    };
  }

  @override
  Widget title(BuildContext context) {
    final theme = Theme.of(context);

    Color? color() {
      final status = response?.status;
      if (status == null) return null;
      if (status >= 200 && status < 300) {
        return Colors.green;
      } else if (status >= 300 && status < 400) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }

    Widget status0(BuildContext context) {
      if (loading == true) {
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(),
        );
      }

      final status = response?.status;
      if (status != null) {
        return Text(
          '$status',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(color: color()),
        );
      }

      return Text(
        'ERROR',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(color: Colors.red),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.public, size: 16, color: color()),
            const SizedBox(width: 8),
            status0(context),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${method ?? 'Undefined'} ${uri?.path}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${uri?.host}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ],
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
    Map<String, dynamic>? headers,
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
  final Map<String, dynamic>? headers;
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
    Map<String, dynamic>? headers,
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
