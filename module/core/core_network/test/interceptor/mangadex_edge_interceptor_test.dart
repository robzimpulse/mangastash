/// Unit tests for [MangaDexEdgeInterceptor].
///
/// Verifies stripping User-Agent headers for MangaDex edge hosts (including custom casing),
/// preserving User-Agent for non-MangaDex hosts and chapter CDNs, and rejecting
/// responses redirected to the POWBlock bot challenge page.
///
/// Usage:
/// Run via `fvm flutter test test/interceptor/mangadex_edge_interceptor_test.dart`.
import 'dart:typed_data';

import 'package:core_network/src/interceptor/mangadex_edge_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter({this.redirects = const []});

  final List<RedirectRecord> redirects;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody(
      Stream.value(Uint8List.fromList([123, 125])),
      200,
      isRedirect: redirects.isNotEmpty,
      redirects: redirects,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late _CapturingAdapter adapter;

  setUp(() {
    dio = Dio(
      BaseOptions(
        headers: {'user-agent': 'Chrome/154.0.0.0'},
      ),
    );
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(MangaDexEdgeInterceptor());
  });

  bool hasUserAgent(Map<String, dynamic> headers) {
    return headers.keys.any((k) => k.toLowerCase() == 'user-agent');
  }

  test('strips UA for api.mangadex.org', () async {
    await dio.get<Object>('https://api.mangadex.org/ping');
    expect(hasUserAgent(adapter.lastOptions!.headers), isFalse);
  });

  test('strips UA for uploads.mangadex.org', () async {
    await dio.get<Object>('https://uploads.mangadex.org/covers/a.jpg');
    expect(hasUserAgent(adapter.lastOptions!.headers), isFalse);
  });

  test('strips caller-supplied User-Agent with other casing', () async {
    await dio.get<Object>(
      'https://api.mangadex.org/ping',
      options: Options(headers: {'User-Agent': 'CustomBrowser/1.0'}),
    );
    expect(hasUserAgent(adapter.lastOptions!.headers), isFalse);
  });

  test('headers stay writable after the UA is stripped', () async {
    // `removeWhere` on Dio's case-insensitive LinkedHashMap leaves a deleted
    // slot that makes the next insert throw a TypeError; a later interceptor
    // (or dio setting content-length for a body) must still be able to
    // write headers.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['user-agent'] = 'Later/1.0';
          options.headers['x-after-strip'] = '1';
          handler.next(options);
        },
      ),
    );

    await dio.get<Object>('https://api.mangadex.org/ping');

    expect(adapter.lastOptions!.headers['x-after-strip'], '1');
  });

  test('strips UA for mangadex.org and www.mangadex.org', () async {
    // The site and its favicon (the Manga Dex source icon) sit behind the
    // same challenge as the API.
    const urls = [
      'https://www.mangadex.org/favicon.ico',
      'https://mangadex.org/title/123',
    ];
    for (final url in urls) {
      await dio.get<Object>(url);
      expect(
        hasUserAgent(adapter.lastOptions!.headers),
        isFalse,
        reason: 'UA should be stripped for $url',
      );
    }
  });

  test('keeps UA for other hosts', () async {
    const hosts = [
      'https://cmdx.mangadex.network/data/1.jpg',
      'https://asurascans.com/manga',
      'https://notmangadex.org/a',
      'https://mangadex.org.example.com/a',
    ];
    for (final url in hosts) {
      await dio.get<Object>(url);
      expect(
        hasUserAgent(adapter.lastOptions!.headers),
        isTrue,
        reason: 'UA should be preserved for $url',
      );
      expect(
        adapter.lastOptions!.headers['user-agent'],
        equals('Chrome/154.0.0.0'),
      );
    }
  });

  test('rejects a response redirected to the challenge', () async {
    adapter = _CapturingAdapter(
      redirects: [
        RedirectRecord(
          302,
          'GET',
          Uri.parse('https://mangadex.org/edge/challenge?src=x'),
        ),
      ],
    );
    dio.httpClientAdapter = adapter;

    await expectLater(
      dio.get<Object>('https://uploads.mangadex.org/covers/a.jpg'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });

  test('passes normal responses', () async {
    final response = await dio.get<Object>('https://api.mangadex.org/ping');
    expect(response.statusCode, 200);
  });
}
