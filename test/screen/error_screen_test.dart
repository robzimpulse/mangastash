// Widget tests for ErrorScreen's back button (issue #130): the error page
// can end up as the only page on the navigator stack (e.g. after a restored
// deep link to an unknown path), where a blind context.pop() throws
// "there is nothing to pop". The back button must fall back to the home
// location (MainPath.main) when it cannot pop.
//
// Run with: fvm flutter test test/screen/error_screen_test.dart
import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangastash/main_path.dart';
import 'package:mangastash/screen/error_screen.dart';

/// Pumps [frames] of 200ms each. ScaffoldScreen contains an always-animating
/// shimmer, so pumpAndSettle never settles (see CLAUDE.md known blockers).
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

GoRouter _router({required String initialLocation, Widget? home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: MainPath.main,
        builder: (_, _) =>
            home ?? const Scaffold(body: Center(child: Text('HOME'))),
      ),
      GoRoute(
        path: MainPath.notFound,
        builder: (_, _) => const ErrorScreen(text: 'boom'),
      ),
    ],
  );
}

void main() {
  testWidgets('back on the only page returns home instead of throwing (#130)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _router(initialLocation: MainPath.notFound)),
    );
    await pumpFrames(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await pumpFrames(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('back pops normally when a page is underneath (#130)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: _router(
          initialLocation: MainPath.main,
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => context.push(MainPath.notFound),
                  child: const Text('go-error'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await pumpFrames(tester);

    await tester.tap(find.text('go-error'));
    await pumpFrames(tester);
    expect(find.text('Error Screen'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await pumpFrames(tester);

    expect(tester.takeException(), isNull);
    // Back returns to the page underneath (the custom home with the
    // 'go-error' button), not to some fallback location.
    expect(find.text('go-error'), findsOneWidget);
  });
}
