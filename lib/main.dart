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
import 'screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Service locator/dependency injector code here
  ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());
  final locator = ServiceLocator.asNewInstance();

  // TODO: register module registrar here
  await locator.registerRegistrar(CoreAnalyticsRegistrar());
  await locator.registerRegistrar(CoreStorageRegistrar());
  await locator.registerRegistrar(CoreNetworkRegistrar());
  await locator.registerRegistrar(CoreEnvironmentRegistrar());
  await locator.registerRegistrar(CoreRouteRegistrar());
  await locator.registerRegistrar(DomainMangaRegistrar());

  final existingFlutterError = FlutterError.onError;
  FlutterError.onError = (details) {
    final LogBox log = locator();
    log.log(
      details.exceptionAsString(),
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
    existingFlutterError?.call(details);
  };

  final existingPlatformDispatcher = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    final LogBox log = locator();
    log.log(
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
        final LogBox log = locator();
        final Object? error = pair.firstOrNull.castOrNull();
        final String? trace = pair.lastOrNull.castOrNull();

        log.log(
          error.toString(),
          name: 'Isolate',
          error: error,
          stackTrace: trace?.let((e) => StackTrace.fromString(e)),
        );
      }).sendPort,
    );
  }

  runApp(MangaStashApp(locator: locator));
}

class MangaStashApp extends StatefulWidget {
  const MangaStashApp({super.key, required this.locator});

  final ServiceLocator locator;

  @override
  State<StatefulWidget> createState() => _MangaStashAppState();
}

class _MangaStashAppState extends State<MangaStashApp> {
  // late final Future<GoRouter> _router = _initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.locator.allReady(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        return AppsScreen(
          listenThemeUseCase: widget.locator(),
          routerConfig: _route(locator: widget.locator),
        );
      },
    );
  }

  GoRouter _route({
    required ServiceLocator locator,
    String initialRoute = MainPath.main,
  }) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final LogBox logBox = locator();
    final DatabaseViewer viewer = locator();
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialRoute,
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
}
