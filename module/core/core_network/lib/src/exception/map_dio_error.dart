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
          );
        }
        if (status != null) {
          final snippet = response.data?.toString();
          return HttpStatusException(
            statusCode: status,
            cause: error,
            bodySnippet: snippet == null || snippet.isEmpty
                ? null
                : snippet.substring(0, snippet.length > 200 ? 200 : snippet.length),
          );
        }
      }
      return NetworkException(cause: error);
    }
    return error;
  }
  return Exception(error.toString());
}
