import 'package:core_storage/core_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../extension/patrol_tester_extension.dart';
import '../mock/mock_shared_preferences.dart';

void main() {
  group('test screen size', () {
    // testScreen(
    //   'open apps with screen size 400 x 800',
    //   width: 400,
    //   height: 800,
    //   onSetupTestScreen: (locator) async {
    //     locator.registerSingleton<SharedPreferences>(MockSharedPreferences());
    //     locator.registerSingleton<Executor>(MemoryExecutor());
    //   },
    //   onRunTest: (locator, $) async {
    //     expect($(#left_navigation_rail), findsNothing);
    //     expect($(#bottom_navigation_bar), findsOneWidget);
    //   },
    // );

    //   testWidgets('open apps with screen size 400 x 800', (tester) async {
    //     await tester.launch(
    //       width: 400,
    //       height: 800,
    //       setup: (locator) async {
    //         locator.registerSingleton<SharedPreferences>(MockSharedPreferences());
    //         locator.registerSingleton<Executor>(MemoryExecutor());
    //       },
    //     );
    //
    //     await tester.pump();
    //
    //     expect(find.byKey(const Key('left-navigation-rail')), findsOneWidget);
    //
    //     expect(find.byKey(const Key('bottom-navigation-bar')), findsNothing);
    //
    //     await tester.pump();
    //
    //     expect(find.byKey(const Key('left-navigation-rail')), findsNothing);
    //
    //     expect(find.byKey(const Key('bottom-navigation-bar')), findsOneWidget);
    //   });
    //
    //   testWidgets('open apps with screen size 600 x 800', (tester) async {
    //     await tester.launch(
    //       width: 600,
    //       height: 800,
    //       setup: (locator) async {
    //         locator.registerSingleton<SharedPreferences>(MockSharedPreferences());
    //         locator.registerSingleton<Executor>(MemoryExecutor());
    //       },
    //     );
    //
    //     await tester.pump();
    //
    //     expect(find.byKey(const Key('left-navigation-rail')), findsOneWidget);
    //
    //     expect(find.byKey(const Key('bottom-navigation-bar')), findsNothing);
    //
    //     await tester.pump();
    //
    //     expect(find.byKey(const Key('left-navigation-rail')), findsOneWidget);
    //
    //     expect(find.byKey(const Key('bottom-navigation-bar')), findsNothing);
    //   });
    //
    //   testWidgets('open apps with screen size 800 x 800', (tester) async {
    //     await tester.launch(
    //       width: 800,
    //       height: 800,
    //       setup: (locator) async {
    //         locator.registerSingleton<SharedPreferences>(MockSharedPreferences());
    //         locator.registerSingleton<Executor>(MemoryExecutor());
    //       },
    //     );
    //
    //     await tester.pump();
    //
    //     expect(find.byKey(const Key('left-navigation-rail')), findsOneWidget);
    //
    //     expect(find.byKey(const Key('bottom-navigation-bar')), findsNothing);
    //
    //     await tester.pump();
    //
    //     expect(find.byKey(const Key('left-navigation-rail')), findsOneWidget);
    //
    //     expect(find.byKey(const Key('bottom-navigation-bar')), findsNothing);
    //   });
    //
    //   testWidgets('open apps with screen size 1200 x 800', (tester) async {
    //     await tester.launch(
    //       width: 1200,
    //       height: 800,
    //       setup: (locator) async {
    //         locator.registerSingleton<SharedPreferences>(MockSharedPreferences());
    //         locator.registerSingleton<Executor>(MemoryExecutor());
    //       },
    //     );
    //
    //     await tester.pump();
    //
    //     expect(find.byKey(const Key('left-navigation-rail')), findsOneWidget);
    //
    //     expect(find.byKey(const Key('bottom-navigation-bar')), findsNothing);
    //
    //     await tester.pump();
    //
    //     expect(find.byKey(const Key('left-navigation-rail')), findsOneWidget);
    //
    //     expect(find.byKey(const Key('bottom-navigation-bar')), findsNothing);
    //   });
  });
}
