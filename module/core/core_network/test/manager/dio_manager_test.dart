/// Unit tests for [DioManager].
///
/// Verifies HTTP client creation, timeouts, retry policies, UserAgentManager
/// attachment, MangaDex edge User-Agent stripping, and bot challenge handling.
///
/// Usage:
/// Run via `fvm flutter test test/manager/dio_manager_test.dart`.
import 'dart:typed_data';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/src/exception/bot_challenge_exception.dart';
import 'package:core_network/src/exception/map_dio_error.dart';
import 'package:core_network/src/manager/dio_manager.dart';
import 'package:core_network/src/manager/user_agent_manager.dart';
import 'package:core_network/src/mixin/user_agent_mixin.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:universal_io/io.dart';

class FakeLogBox extends Mock implements LogBox {}

class FakeStorage extends Mock implements Storage {}

/// Serves the queued status codes in order (the last one repeats) and counts
/// how many HTTP requests actually hit the adapter.
class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.statuses, {this.redirects = const []});

  final List<int> statuses;
  final List<RedirectRecord> redirects;
  int calls = 0;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    final status = statuses[calls.clamp(0, statuses.length - 1)];
    calls++;
    return ResponseBody(
      Stream.value(Uint8List.fromList([123, 125])),
      status,
      isRedirect: redirects.isNotEmpty,
      redirects: redirects,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeLogBox log;

  setUp(() {
    log = FakeLogBox();
    when(() => log.storage).thenReturn(FakeStorage());
  });

  test('sets connect/receive timeouts on the shared instance', () {
    final dio = DioManager.create(log: log);

    expect(dio.options.connectTimeout, isNotNull);
    expect(dio.options.receiveTimeout, isNotNull);
  });

  test('timeouts match the documented defaults (connect 15s, receive 30s)', () {
    final dio = DioManager.create(log: log);

    expect(dio.options.connectTimeout, const Duration(seconds: 15));
    expect(dio.options.receiveTimeout, const Duration(seconds: 30));
  });

  test('does not set sendTimeout (no request sends a body)', () {
    final dio = DioManager.create(log: log);

    expect(dio.options.sendTimeout, isNull);
  });

  test('HTTP 400 is not retried (deterministic client error)', () async {
    final dio = DioManager.create(
      log: log,
      retryDelays: const [Duration(milliseconds: 1)],
    );
    final adapter = _CountingAdapter([400]);
    dio.httpClientAdapter = adapter;

    await expectLater(
      dio.get<Object>('https://example.com/a'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.calls, 1);
  });

  test('HTTP 429 is retried and can succeed', () async {
    final dio = DioManager.create(
      log: log,
      retryDelays: const [Duration(milliseconds: 1)],
    );
    final adapter = _CountingAdapter([429, 200]);
    dio.httpClientAdapter = adapter;

    final response = await dio.get<Object>('https://example.com/a');

    expect(response.statusCode, 200);
    expect(adapter.calls, 2);
  });

  test('uses user agent manager current header when provided', () {
    final manager = UserAgentManager(log: log);

    final dio = DioManager.create(log: log, userAgentManager: manager);

    expect(
      dio.options.headers[HttpHeaders.userAgentHeader],
      manager.current,
    );
  });

  test('keeps Dio header live after manager publish', () {
    final manager = UserAgentManager(log: log);
    final dio = DioManager.create(log: log, userAgentManager: manager);

    manager.publish('X/1');

    expect(dio.options.headers[HttpHeaders.userAgentHeader], 'X/1');
  });

  test('defaults to Chrome/154 user agent without manager', () {
    final dio = DioManager.create(log: log);

    expect(
      dio.options.headers[HttpHeaders.userAgentHeader],
      contains('Chrome/154.0.0.0'),
    );
    expect(
      dio.options.headers[HttpHeaders.userAgentHeader],
      UserAgentMixin.staticUserAgent,
    );
  });

  test('MangaDex request carries no UA after publish', () async {
    final manager = UserAgentManager(log: log);
    final dio = DioManager.create(log: log, userAgentManager: manager);
    final adapter = _CountingAdapter([200]);
    dio.httpClientAdapter = adapter;

    manager.publish('WebView/1');

    await dio.get<Object>('https://api.mangadex.org/ping');
    final mangadexHeaders = adapter.lastOptions?.headers ?? {};
    expect(
      mangadexHeaders.keys.any((k) => k.toLowerCase() == 'user-agent'),
      isFalse,
    );

    await dio.get<Object>('https://example.com/a');
    final otherHeaders = adapter.lastOptions?.headers ?? {};
    expect(
      otherHeaders[HttpHeaders.userAgentHeader],
      'WebView/1',
    );
  });

  test('challenge response is not retried', () async {
    final dio = DioManager.create(
      log: log,
      retryDelays: const [Duration(milliseconds: 1)],
    );
    final adapter = _CountingAdapter(
      [200],
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
      dio.get<Object>('https://api.mangadex.org/ping'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 1);
  });

  test('challenge maps to BotChallengeException', () async {
    final dio = DioManager.create(log: log);
    final adapter = _CountingAdapter(
      [200],
      redirects: [
        RedirectRecord(
          302,
          'GET',
          Uri.parse('https://mangadex.org/edge/challenge?src=x'),
        ),
      ],
    );
    dio.httpClientAdapter = adapter;

    DioException? caught;
    try {
      await dio.get<Object>('https://api.mangadex.org/ping');
    } on DioException catch (e) {
      caught = e;
    }
    expect(caught, isNotNull);
    final mapped = mapDioError(caught!);
    expect(mapped, isA<BotChallengeException>());
  });
}
