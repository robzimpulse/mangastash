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

import 'main_path.dart';
import 'main_route.dart';
import 'screen/apps_screen.dart';
import 'screen/error_screen.dart';
import 'screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Service locator/dependency injector code here
  ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());
  runApp(MangaStashApp(locator: ServiceLocator.asNewInstance()));
}

class MangaStashApp extends StatelessWidget {
  const MangaStashApp({
    super.key,
    required this.locator,
    this.overrideDependencies,
  });

  final AsyncValueSetter<ServiceLocator>? overrideDependencies;
  final ServiceLocator locator;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _setupLocator(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        if (snapshot.hasError) {
          return ErrorScreen(text: snapshot.error.toString());
        }

        return AppsScreen(
          listenThemeUseCase: locator(),
          routerConfig: _route(locator: locator),
        );
      },
    );
  }

  GoRouter _route({required ServiceLocator locator}) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final LogBox logBox = locator();
    final DatabaseViewer viewer = locator();
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: _initialRoute(locator: locator),
      onException: (context, state, router) {
        router.push(
          MainPath.notFound,
          extra: 'Path Not Found (${state.uri.toString()})',
        );
      },
      routes: MainRouteBuilder().allRoutes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
        // TODO: add observer here
        observers: () => [logBox.observer],
      ),
      observers: [logBox.observer, viewer.navigatorObserver],
    );
  }

  String _initialRoute({required ServiceLocator locator}) {
    return MainPath.main;
  }

  Future<void> _setupLocator() async {
    await locator.reset();

    // TODO: register module registrar here
    await locator.registerRegistrar(CoreAnalyticsRegistrar());
    await locator.registerRegistrar(CoreStorageRegistrar());
    await locator.registerRegistrar(CoreNetworkRegistrar());
    await locator.registerRegistrar(CoreEnvironmentRegistrar());
    await locator.registerRegistrar(CoreRouteRegistrar());
    await locator.registerRegistrar(DomainMangaRegistrar());

    await overrideDependencies?.call(locator);

    await locator.allReady();

    final existingFlutterError = FlutterError.onError;
    FlutterError.onError = (details) {
      locator<LogBox>().log(
        details.exceptionAsString(),
        name: 'FlutterError',
        error: details.exception,
        stackTrace: details.stack,
      );
      existingFlutterError?.call(details);
    };

    final existingPlatformDispatcher = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      locator<LogBox>().log(
        error.toString(),
        name: 'PlatformDispatcher',
        error: error,
        stackTrace: stack,
      );
      return existingPlatformDispatcher?.call(error, stack) ?? true;
    };

    if (!kIsWeb) {
      Isolate.current.addErrorListener(
        RawReceivePort((pair) {
          if (pair is! List) return;
          final Object? error = pair.firstOrNull.castOrNull();
          final String? trace = pair.lastOrNull.castOrNull();

          locator<LogBox>().log(
            error.toString(),
            name: 'Isolate',
            error: error,
            stackTrace: trace?.let((e) => StackTrace.fromString(e)),
          );
        }).sendPort,
      );
    }
  }
}
