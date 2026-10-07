import 'dart:isolate';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'screen/apps_screen.dart';
import 'screen/error_screen.dart';
import 'screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Service locator/dependency injector code here
  ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());

  // Ignore bad certificate for development purpose,
  // - enable proxy for development
  // - enable https api call without certificate validation
  ignoreBadCertificate();

  final locator = ServiceLocator.asNewInstance();
  runApp(
    WrapperScreen(
      locatorBuilder: () {
        return Future(() async {
          await locator.reset();

          // TODO: register module registrar here
          await locator.registerRegistrar(CoreAnalyticsRegistrar());
          await locator.registerRegistrar(CoreStorageRegistrar());
          await locator.registerRegistrar(CoreNetworkRegistrar());
          await locator.registerRegistrar(CoreEnvironmentRegistrar());
          await locator.registerRegistrar(CoreRouteRegistrar());
          await locator.registerRegistrar(DomainMangaRegistrar());

          await locator.allReady();

          return locator;
        });
      },
      appScreenBuilder: (_, locator) {
        return AppsScreen(
          locator: locator,
          setupError: (logbox) {
            FlutterError.onError = (details) {
              logbox.log(
                details.exceptionAsString(),
                name: 'FlutterError',
                error: details.exception,
                stackTrace: details.stack,
              );
              locator.getOrNull<LogBoxBridge>()?.markFatal(
                details.exception,
                details.stack ?? StackTrace.empty,
              );
              locator.getOrNull<CrashReporter>()?.reportFatal(
                details.exception,
                details.stack ?? StackTrace.empty,
              );
            };

            PlatformDispatcher.instance.onError = (error, stack) {
              logbox.log(
                error.toString(),
                name: 'PlatformDispatcher',
                error: error,
                stackTrace: stack,
              );
              locator.getOrNull<LogBoxBridge>()?.markFatal(error, stack);
              locator.getOrNull<CrashReporter>()?.reportFatal(error, stack);
              return true;
            };

            if (!kIsWeb) {
              Isolate.current.addErrorListener(
                RawReceivePort((pair) {
                  if (pair is! List) return;
                  final Object? error = pair.firstOrNull.castOrNull();
                  final String? trace = pair.lastOrNull.castOrNull();
                  final StackTrace stack =
                      trace?.let((e) => StackTrace.fromString(e)) ??
                      StackTrace.empty;
                  final Object fatalError =
                      error ?? Exception('Unknown isolate error');

                  logbox.log(
                    error.toString(),
                    name: 'Isolate',
                    error: error,
                    stackTrace: stack,
                  );
                  locator.getOrNull<LogBoxBridge>()?.markFatal(
                    fatalError,
                    stack,
                  );
                  locator.getOrNull<CrashReporter>()?.reportFatal(
                    fatalError,
                    stack,
                  );
                }).sendPort,
              );
            }
          },
        );
      },
      splashScreenBuilder: (_) => const SplashScreen(),
      errorScreenBuilder: (_, error) => ErrorScreen(text: error.toString()),
    ),
  );
}
