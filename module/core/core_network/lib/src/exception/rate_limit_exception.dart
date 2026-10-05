import 'package:dio/dio.dart';

import 'http_status_exception.dart';

class RateLimitException extends HttpStatusException {
  final Duration? retryAfter;

  RateLimitException({
    required DioException cause,
    this.retryAfter,
  }) : super(statusCode: 429, cause: cause);

  @override
  String toString() {
    final retry = retryAfter == null ? '' : ' retryAfter: ${retryAfter!.inSeconds}s';
    return '$runtimeType : 429${retry}';
  }
}
