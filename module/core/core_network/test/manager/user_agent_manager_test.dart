import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/src/manager/user_agent_manager.dart';
import 'package:core_network/src/mixin/user_agent_mixin.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:universal_io/io.dart';

class FakeLogBox extends Mock implements LogBox {}

class FakeStorage extends Mock implements Storage {}

void main() {
  late FakeLogBox log;

  setUp(() {
    log = FakeLogBox();
    when(() => log.storage).thenReturn(FakeStorage());
  });

  test('current returns fallback static user agent before publish', () {
    final manager = UserAgentManager(log: log);

    expect(manager.current, UserAgentMixin.staticUserAgent);
  });

  test('attach without publish keeps fallback header on Dio', () {
    final manager = UserAgentManager(log: log);
    final dio = Dio();

    manager.attach(dio);

    expect(
      dio.options.headers[HttpHeaders.userAgentHeader],
      UserAgentMixin.staticUserAgent,
    );
  });

  test('publish updates current and re-stamps attached Dio header', () {
    final manager = UserAgentManager(log: log);
    final dio = Dio();
    manager.attach(dio);

    manager.publish('X/1');

    expect(manager.current, 'X/1');
    expect(dio.options.headers[HttpHeaders.userAgentHeader], 'X/1');
  });

  test('second publish is ignored (first wins)', () {
    final manager = UserAgentManager(log: log);

    manager.publish('X/1');
    manager.publish('Y/2');

    expect(manager.current, 'X/1');
  });

  test('empty and whitespace-only publish are ignored', () {
    final manager = UserAgentManager(log: log);

    manager.publish('');
    manager.publish('  ');

    expect(manager.current, UserAgentMixin.staticUserAgent);
  });
}
