import 'dart:async';
import 'package:flutter/widgets.dart' as widget;
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

  static void runApp(widget.Widget app) async {
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

        widget.runApp(app);
      },
      (error, stacktrace) {
        FlutterOTel.reportError('Zone Error', error, stacktrace);
      },
    );
  }

  static widget.NavigatorObserver get observer {
    return OTelNavigatorObserver();
  }
}
