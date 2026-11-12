/// Maps raw [DioException] and [Object] errors to domain-level network exceptions.
///
/// Converts HTTP errors, rate limits, network failures, and bot challenge
/// responses into typed [Exception] instances.
///
/// Usage:
/// Pass caught network errors through [mapDioError] before handling or exposing them.
library;

import 'package:dio/dio.dart';

import 'bot_challenge_exception.dart';
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
        if (isBotChallengeUri(response.realUri)) {
          return BotChallengeException(error.requestOptions.uri.toString());
        }
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
