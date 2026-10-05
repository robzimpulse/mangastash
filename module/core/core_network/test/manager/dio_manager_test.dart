import 'dart:typed_data';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/src/manager/dio_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeLogBox extends Mock implements LogBox {}

class FakeStorage extends Mock implements Storage {}

/// Serves the queued status codes in order (the last one repeats) and counts
/// how many HTTP requests actually hit the adapter.
class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.statuses);

  final List<int> statuses;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final status = statuses[calls.clamp(0, statuses.length - 1)];
    calls++;
    return ResponseBody(
      Stream.value(Uint8List.fromList([123, 125])),
      status,
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
}
