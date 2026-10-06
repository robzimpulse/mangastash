import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final DioException cause;

  NetworkException({required this.cause});

  @override
  String toString() => '$runtimeType : ${cause.message}';
}
