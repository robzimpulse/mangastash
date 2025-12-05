import 'package:flutter_test/flutter_test.dart';

import '../extension/patrol_tester_extension.dart';

void main() {
  group('test screen size', () {
    // TODO: @robzimpulse - fix this test caused by filesystem
    testScreen(
      'open apps with screen size 400 x 800',
      width: 400,
      height: 800,
      onRunTest: (locator, $) async {
        expect($(#left_navigation_rail), findsNothing);
        expect($(#bottom_navigation_bar), findsOneWidget);
      },
    );

    testScreen(
      'open apps with screen size 600 x 800',
      width: 600,
      height: 800,
      onRunTest: (locator, $) async {
        expect($(#left_navigation_rail), findsOneWidget);
        expect($(#bottom_navigation_bar), findsNothing);
      },
    );

    testScreen(
      'open apps with screen size 800 x 800',
      width: 800,
      height: 800,
      onRunTest: (locator, $) async {
        expect($(#left_navigation_rail), findsOneWidget);
        expect($(#bottom_navigation_bar), findsNothing);
      },
    );

    testScreen(
      'open apps with screen size 1200 x 800',
      width: 1200,
      height: 800,
      onRunTest: (locator, $) async {
        expect($(#left_navigation_rail), findsOneWidget);
        expect($(#bottom_navigation_bar), findsNothing);
      },
    );
  });
}
