/// Dio interceptor for MangaDex edge requests.
///
/// Strips User-Agent headers for MangaDex edge hosts (`mangadex.org` and every
/// `*.mangadex.org` subdomain: api, uploads, www) so dart:io's default Dart
/// User-Agent is used instead of a browser-like User-Agent, preventing
/// MangaDex's POWBlock bot challenge redirect. `*.mangadex.network` (MD@Home
/// chapter pages) is not challenged and keeps the published UA.
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
  /// Whether [host] sits behind MangaDex's edge challenge: `mangadex.org`
  /// itself or any `*.mangadex.org` subdomain (api, uploads, www — the latter
  /// serves the Manga Dex source icon).
  static bool isEdgeHost(String host) {
    return host == 'mangadex.org' || host.endsWith('.mangadex.org');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isEdgeHost(options.uri.host)) {
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
