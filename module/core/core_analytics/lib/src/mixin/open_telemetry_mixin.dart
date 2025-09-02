import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';

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
    required VoidCallback runApp,
    bool enableDebugLog = false,
  }) async {
    runZonedGuarded(
      () {
        FlutterOTel.initialize(
          serviceName: 'mangastash-app',
          serviceVersion: '0.1.7',
          tracerName: 'main',
          resourceAttributes: Attributes.of({
            'deployment.environment': 'debug',
            'service.namespace': 'mobile-apps',
          }),
        );

        if (enableDebugLog) {
          OTelLog.logFunction = print;
          OTelLog.spanLogFunction = print;
          OTelLog.exportLogFunction = print;
          OTelLog.metricLogFunction = print;
        }

        runApp();
      },
      (error, stacktrace) {
        FlutterOTel.reportError('Zone Error', error, stacktrace);
      },
    );
  }

  static NavigatorObserver get observer {
    return OTelNavigatorObserver();
  }
}
