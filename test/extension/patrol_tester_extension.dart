import 'dart:ui';

import 'package:core_storage/core_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:mangastash/main.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:service_locator/service_locator.dart';

import '../mock/mock_shared_preferences.dart';

typedef OnRunTestScreen =
    Future<void> Function(ServiceLocator locator, PatrolTester $);

typedef OnSetupTestScreen = Future<void> Function(ServiceLocator locator);

void testScreen(
  String description, {
  OnSetupTestScreen? onSetupTestScreen,
  required OnRunTestScreen onRunTest,
  double width = 400,
  double height = 800,
  double dpi = 2.625,
  double textScaleFactor = 1.1,
}) {
  ServiceLocatorInitiator.setServiceLocatorFactory(
    () => GetItServiceLocator()..setAllowReassignment(true),
  );

  patrolWidgetTest(description, ($) async {
    $.tester.view.physicalSize = Size(width * dpi, height * dpi);
    await $.tester.binding.setSurfaceSize(Size(width * dpi, height * dpi));
    $.tester.view.devicePixelRatio = dpi;
    $.tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;

    TestWidgetsFlutterBinding.ensureInitialized();

    final locator = ServiceLocator.asNewInstance();

    await $.pumpWidget(
      MangaStashApp(
        locator: locator,
        overrideDependencies: (locator) async {
          locator.registerSingleton<SharedPreferences>(MockSharedPreferences());
          locator.registerSingleton<Executor>(MemoryExecutor());
          await onSetupTestScreen?.call(locator);
        },
      ),
    );

    await $.pumpAndTrySettle();

    await onRunTest.call(locator, $);

    await $.tester.runAsync(() => locator.reset());

    debugDefaultTargetPlatformOverride = null;
  });
}
