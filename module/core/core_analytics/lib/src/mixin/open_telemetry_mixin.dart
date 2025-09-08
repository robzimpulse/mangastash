import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutterrific_opentelemetry/flutterrific_opentelemetry.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../exporter/custom_oltp_http_metric_exporter.dart';

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

        /// docker run -p 4317:4317 -p 4318:4318 -p 3000:3000 --rm -ti grafana/otel-lgtm
        FlutterOTel.initialize(
          appName: info.appName,
          resourceAttributes: Attributes.of({
            'deployment.environment': 'debug',
            'service.namespace': 'flutter',
          }),
          metricExporter: CustomOtlpHttpMetricExporter(),
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
