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
import 'screen/wrapper_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Service locator/dependency injector code here
  ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());

  runApp(
    WrapperScreen(
      locatorBuilder: () {
        return Future(() async {
          final locator = ServiceLocator.asNewInstance();

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
            };

            PlatformDispatcher.instance.onError = (error, stack) {
              logbox.log(
                error.toString(),
                name: 'PlatformDispatcher',
                error: error,
                stackTrace: stack,
              );
              return true;
            };

            if (!kIsWeb) {
              Isolate.current.addErrorListener(
                RawReceivePort((pair) {
                  if (pair is! List) return;
                  final Object? error = pair.firstOrNull.castOrNull();
                  final String? trace = pair.lastOrNull.castOrNull();

                  logbox.log(
                    error.toString(),
                    name: 'Isolate',
                    error: error,
                    stackTrace: trace?.let((e) => StackTrace.fromString(e)),
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
