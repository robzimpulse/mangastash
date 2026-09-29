import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/src/manager/dio_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeLogBox extends Mock implements LogBox {}

class FakeStorage extends Mock implements Storage {}

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
}
