// Tests for RecrawlUseCase: the visible webview session is tracked by the
// shared VisibleWebviewGuard (so the headless runner never terminates the
// shared Android renderer under it, issue #115), the guard is lowered even
// when the session throws, and the cached script results of the URL are
// evicted only after the session closed.
//
// Run with: fvm flutter test test/use_case/recrawl/recrawl_use_case_test.dart
import 'dart:async';

import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:domain_manga/src/use_case/recrawl_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLogBox extends Mock implements analytics.LogBox {}

class MockRunner extends Mock implements RunSourceScriptUseCase {}

void main() {
  late MockRunner runner;
  late VisibleWebviewGuard guard;

  setUp(() {
    runner = MockRunner();
    guard = VisibleWebviewGuard();
    when(() => runner.evict(url: any(named: 'url'))).thenAnswer((_) async {});
  });

  Future<BuildContext> pumpContext(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    return tester.element(find.byType(SizedBox));
  }

  testWidgets('keeps the guard open for the whole visible session, '
      'then evicts the url', (tester) async {
    final context = await pumpContext(tester);
    final session = Completer<void>();
    final opened = <Uri>[];
    final useCase = RecrawlUseCase(
      logBox: MockLogBox(),
      runner: runner,
      guard: guard,
      openWebview: (_, uri) {
        opened.add(uri);
        return session.future;
      },
    );

    final done = useCase.execute(context: context, url: 'https://x/p');
    await tester.pump();

    expect(opened, [Uri.parse('https://x/p')]);
    expect(guard.isOpen, isTrue);
    verifyNever(() => runner.evict(url: any(named: 'url')));

    session.complete();
    await done;

    expect(guard.isOpen, isFalse);
    verify(() => runner.evict(url: 'https://x/p')).called(1);
  });

  testWidgets('a session that throws still lowers the guard', (tester) async {
    final context = await pumpContext(tester);
    final useCase = RecrawlUseCase(
      logBox: MockLogBox(),
      runner: runner,
      guard: guard,
      openWebview: (_, _) async => throw StateError('closed badly'),
    );

    await expectLater(
      useCase.execute(context: context, url: 'https://x/p'),
      throwsStateError,
    );

    expect(guard.isOpen, isFalse);
  });
}
