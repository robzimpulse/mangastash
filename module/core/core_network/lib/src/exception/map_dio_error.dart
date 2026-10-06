import 'package:dio/dio.dart';

import 'http_status_exception.dart';
import 'network_exception.dart';
import 'rate_limit_exception.dart';

Exception mapDioError(Object error) {
  if (error is Exception) {
    if (error is DioException) {
      if (error.type == DioExceptionType.cancel) {
        return error;
      }
      final response = error.response;
      if (response != null) {
        final status = response.statusCode;
        if (status != null) {
          final raw = response.data?.toString();
          final bodySnippet = raw == null || raw.isEmpty
              ? null
              : raw.substring(0, raw.length > 200 ? 200 : raw.length);
          if (status == 429) {
            final retryHeader = response.headers.value('Retry-After');
            Duration? retryAfter;
            if (retryHeader != null) {
              final seconds = int.tryParse(retryHeader.trim());
              if (seconds != null && seconds > 0) {
                retryAfter = Duration(seconds: seconds);
              }
            }
            return RateLimitException(
              cause: error,
              retryAfter: retryAfter,
              bodySnippet: bodySnippet,
            );
          }
          return HttpStatusException(
            statusCode: status,
            cause: error,
            bodySnippet: bodySnippet,
          );
        }
      }
      return NetworkException(cause: error);
    }
    return error;
  }
  return Exception(error.toString());
}
