/// Dio interceptor for MangaDex edge requests.
///
/// Strips User-Agent headers for MangaDex edge hosts (api.mangadex.org and
/// uploads.mangadex.org) so dart:io's default Dart User-Agent is used instead of
/// a browser-like User-Agent, preventing MangaDex's POWBlock bot challenge redirect.
/// Also rejects responses whose final URL is the POWBlock challenge page
/// (https://mangadex.org/edge/challenge) with a [DioException.badResponse].
///
/// Usage:
/// Add this interceptor to Dio's interceptors list before logging and retry interceptors:
/// `dio.interceptors.add(MangaDexEdgeInterceptor());`
library;

import 'package:dio/dio.dart';

import '../exception/bot_challenge_exception.dart';

/// Interceptor that strips User-Agent on MangaDex edge hosts and catches challenge redirects.
class MangaDexEdgeInterceptor extends Interceptor {
  /// The MangaDex edge hosts that challenge browser-like User-Agents.
  static const Set<String> hosts = {
    'api.mangadex.org',
    'uploads.mangadex.org',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (hosts.contains(options.uri.host)) {
      // `headers` is dio's case-insensitive map, so `remove` drops any
      // casing. Never use `removeWhere` here: on a LinkedHashMap with custom
      // equality it leaves a deleted slot that makes the next insert throw a
      // TypeError (`List<dynamic>` is not a subtype of `String` of 'key1').
      options.headers.remove('user-agent');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (isBotChallengeUri(response.realUri)) {
      handler.reject(
        DioException.badResponse(
          statusCode: response.statusCode ?? 200,
          requestOptions: response.requestOptions,
          response: response,
        ),
        true,
      );
      return;
    }
    handler.next(response);
  }
}
