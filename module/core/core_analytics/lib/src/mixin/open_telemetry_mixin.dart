import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';
import 'package:package_info_plus/package_info_plus.dart';

mixin OTelMixin {
  static void reportError(
    String message,
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? attributes,
  }) {
    FlutterOTel.reportError(message, error, stackTrace, attributes: attributes);
  }

  static void runner({
    required VoidCallback ensureInitialized,
    required VoidCallback run,
    bool enableDebugLog = false,
  }) async {
    runZonedGuarded(
      () async {
        ensureInitialized();

        final info = await PackageInfo.fromPlatform();

        FlutterOTel.initialize(
          appName: info.appName,
          resourceAttributes: Attributes.of({
            'deployment.environment': 'debug',
            'service.namespace': 'flutter',
          }),
          secure: false,
        );

        if (enableDebugLog) {
          OTelLog.logFunction = print;
          OTelLog.spanLogFunction = print;
          OTelLog.exportLogFunction = print;
          OTelLog.metricLogFunction = print;
        }

        run();
      },
      (error, stacktrace) {
        reportError('Zone Error', error, stacktrace);
      },
    );
  }

  static NavigatorObserver get observer {
    return OTelNavigatorObserver();
  }
}
