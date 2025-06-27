import 'package:equatable/equatable.dart';
import 'package:universal_io/io.dart';

import 'form_data_field_model.dart';
import 'form_data_file_model.dart';

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
      time: DateTime.now(),
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
