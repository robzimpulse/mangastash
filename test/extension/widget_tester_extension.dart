import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangastash/main.dart';
import 'package:service_locator/service_locator.dart';

extension WidgetTesterExtension on WidgetTester {
  Future<void> launch({
    AsyncValueSetter<ServiceLocator>? setup,
    double width = 400,
    double height = 800,
    double dpi = 2.625,
    double textScaleFactor = 1.1,
  }) async {
    ServiceLocatorInitiator.setServiceLocatorFactory(
      () => GetItServiceLocator()..setAllowReassignment(true),
    );
    final locator = ServiceLocator.asNewInstance();

    view.devicePixelRatio = dpi;
    view.physicalSize = Size(width * dpi, height * dpi);
    binding.setSurfaceSize(Size(width * dpi, height * dpi));
    platformDispatcher.textScaleFactorTestValue = textScaleFactor;

    await pumpWidget(
      MangaStashApp(
        locator: locator,
        overrideDependencies: setup,
      ),
    );

    await locator.reset();
  }
}
