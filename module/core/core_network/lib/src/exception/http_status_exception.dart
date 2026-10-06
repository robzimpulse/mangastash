import 'package:dio/dio.dart';

class HttpStatusException implements Exception {
  final int statusCode;
  final DioException cause;
  final String? bodySnippet;

  HttpStatusException({
    required this.statusCode,
    required this.cause,
    this.bodySnippet,
  });

  @override
  String toString() {
    final snippet = bodySnippet == null ? '' : ' body: $bodySnippet';
    return '$runtimeType : $statusCode$snippet';
  }
}
