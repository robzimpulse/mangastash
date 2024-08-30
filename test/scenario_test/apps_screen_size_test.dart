import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mangastash/main.dart';
import 'package:service_locator/service_locator.dart';

import '../mock/mock_listen_theme_use_case.dart';
import '../mock/mock_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  ServiceLocatorInitiator.setServiceLocatorFactory(
    () => GetItServiceLocator()..setAllowReassignment(true),
  );
  final locator = ServiceLocator.asNewInstance();

  setUp(() {
    locator.registerSingleton<Storage>(MockStorage());
    locator.registerSingleton<Alice>(Alice());
    locator.registerSingleton<ListenThemeUseCase>(
      MockListenThemeUseCase(),
    );
  });

  void setScreenSize(WidgetTester tester, int width, int height) {
    const dpi = 2.625;
    tester.view.devicePixelRatio = dpi;
    tester.view.physicalSize = Size(width * dpi, height * dpi);
    tester.platformDispatcher.textScaleFactorTestValue = 1.1;
  }

  group('test screen size', () {
    testWidgets(
      'open apps with screen size 400 x 800',
      (tester) async {
        setScreenSize(tester, 400, 800);

        await tester.runAsync(
          () async => await tester.pumpWidget(
            MangaStashApp(
              locator: locator,
              testing: true,
            ),
          ),
        );

        await tester.pump();

        expect(
          find.byKey(const Key('left-navigation-rail')),
          findsOneWidget,
        );

        expect(
          find.byKey(const Key('bottom-navigation-bar')),
          findsNothing,
        );

        await tester.pump();

        expect(
          find.byKey(const Key('left-navigation-rail')),
          findsNothing,
        );

        expect(
          find.byKey(const Key('bottom-navigation-bar')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'open apps with screen size 600 x 800',
      (tester) async {
        setScreenSize(tester, 600, 800);

        await tester.runAsync(
          () async => await tester.pumpWidget(
            MangaStashApp(
              locator: locator,
              testing: true,
            ),
          ),
        );

        await tester.pump();

        expect(
          find.byKey(const Key('left-navigation-rail')),
          findsOneWidget,
        );

        expect(
          find.byKey(const Key('bottom-navigation-bar')),
          findsNothing,
        );

        await tester.pump();

        expect(
          find.byKey(const Key('left-navigation-rail')),
          findsOneWidget,
        );

        expect(
          find.byKey(const Key('bottom-navigation-bar')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'open apps with screen size 800 x 800',
      (tester) async {
        setScreenSize(tester, 800, 800);

        await tester.runAsync(
          () async => await tester.pumpWidget(
            MangaStashApp(
              locator: locator,
              testing: true,
            ),
          ),
        );

        await tester.pump();

        expect(
          find.byKey(const Key('left-navigation-rail')),
          findsOneWidget,
        );

        expect(
          find.byKey(const Key('bottom-navigation-bar')),
          findsNothing,
        );

        await tester.pump();

        expect(
          find.byKey(const Key('left-navigation-rail')),
          findsOneWidget,
        );

        expect(
          find.byKey(const Key('bottom-navigation-bar')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'open apps with screen size 1200 x 800',
      (tester) async {
        setScreenSize(tester, 1200, 800);

        await tester.runAsync(
          () async => await tester.pumpWidget(
            MangaStashApp(
              locator: locator,
              testing: true,
            ),
          ),
        );

        await tester.pump();

        expect(
          find.byKey(const Key('left-navigation-rail')),
          findsOneWidget,
        );

        expect(
          find.byKey(const Key('bottom-navigation-bar')),
          findsNothing,
        );

        await tester.pump();

        expect(
          find.byKey(const Key('left-navigation-rail')),
          findsOneWidget,
        );

        expect(
          find.byKey(const Key('bottom-navigation-bar')),
          findsNothing,
        );
      },
    );
  });
}
