import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangastash/main.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:service_locator/service_locator.dart';

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
      MangaStashApp(locator: locator, overrideDependencies: onSetupTestScreen),
    );

    await $.pumpAndTrySettle();

    await onRunTest.call(locator, $);

    debugDefaultTargetPlatformOverride = null;
  });
}
