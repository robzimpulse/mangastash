/// Tests for [VisibleWebviewGuard], the counter of open visible webview
/// sessions that keeps the headless runner from terminating the shared
/// Android renderer under them (issue #115).
///
/// Purpose: pins the raise/lower semantics: the count is up while the session
/// runs, nested sessions add up, and it always comes back down (a throwing
/// session included) so the guard can never get stuck open.
/// Usage: `fvm flutter test test/manager/visible_webview_guard_test.dart`
/// from module/core/core_network.
library;

import 'dart:async';

import 'package:core_network/src/manager/visible_webview_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('is closed until a session starts', () {
    final guard = VisibleWebviewGuard();

    expect(guard.isOpen, isFalse);
    expect(guard.openCount, 0);
  });

  test('is open while the session runs and closed after it', () async {
    final guard = VisibleWebviewGuard();
    final session = Completer<String>();

    final result = guard.track(() => session.future);

    expect(guard.isOpen, isTrue);
    session.complete('done');
    expect(await result, 'done');
    expect(guard.isOpen, isFalse);
  });

  test('nested sessions add up', () async {
    final guard = VisibleWebviewGuard();
    final first = Completer<void>();
    final second = Completer<void>();

    final a = guard.track(() => first.future);
    final b = guard.track(() => second.future);
    expect(guard.openCount, 2);

    first.complete();
    await a;
    expect(guard.openCount, 1);
    expect(guard.isOpen, isTrue);

    second.complete();
    await b;
    expect(guard.isOpen, isFalse);
  });

  test('a throwing session still lowers the guard', () async {
    final guard = VisibleWebviewGuard();

    await expectLater(
      guard.track<void>(() async => throw StateError('closed badly')),
      throwsStateError,
    );

    expect(guard.isOpen, isFalse);
  });
}
