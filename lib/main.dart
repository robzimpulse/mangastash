import 'dart:isolate';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:log_box_navigation_logger/log_box_navigation_logger.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';
import 'package:universal_io/io.dart';

import 'main_path.dart';
import 'main_route.dart';
import 'screen/apps_screen.dart';
import 'screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Service locator/dependency injector code here
  ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());

  const faroApiKey = String.fromEnvironment('FARO_API_KEY');
  const faroCollectorUrl = String.fromEnvironment('FARO_COLLECTOR_URL');

  if (faroApiKey.isNotEmpty && faroCollectorUrl.isNotEmpty) {
    HttpOverrides.global = FaroHttpOverrides(HttpOverrides.current);
    final info = await PackageInfo.fromPlatform();
    Faro().runApp(
      optionsConfiguration: FaroConfig(
        appName: info.appName,
        appVersion: info.version,
        appEnv: kDebugMode ? 'debug' : 'release',
        apiKey: faroApiKey,
        collectorUrl: faroCollectorUrl,
        enableCrashReporting: true,
        anrTracking: true,
        refreshRateVitals: true,
        namespace: 'flutter',
      ),
      appRunner: () {
        return runApp(
          DefaultAssetBundle(
            bundle: FaroAssetBundle(),
            child: FaroUserInteractionWidget(
              child: MangaStashApp(locator: ServiceLocator.asNewInstance()),
            ),
          ),
        );
      },
    );
  } else {
    runApp(MangaStashApp(locator: ServiceLocator.asNewInstance()));
  }
}

class MangaStashApp extends StatefulWidget {
  const MangaStashApp({super.key, required this.locator, this.testing = false});

  final bool testing;

  final ServiceLocator locator;

  @override
  State<StatefulWidget> createState() => _MangaStashAppState();
}

class _MangaStashAppState extends State<MangaStashApp> {
  late final Future<GoRouter> _router = _initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GoRouter>(
      future: _router,
      builder: (context, snapshot) {
        final router = snapshot.data;
        if (router == null) return const SplashScreen();
        return AppsScreen(
          listenThemeUseCase: widget.locator(),
          routerConfig: router,
        );
      },
    );
  }

  Future<GoRouter> _initializeApp() async {
    await initiateAppLocator();
    return _route(locator: widget.locator);
  }

  Future<void> initiateAppLocator() async {
    if (widget.testing) return;

    widget.locator.registerSingleton(LogBox(capacity: 1000));

    // TODO: register module registrar here
    await widget.locator.registerRegistrar(CoreStorageRegistrar());
    await widget.locator.registerRegistrar(CoreNetworkRegistrar());
    await widget.locator.registerRegistrar(CoreEnvironmentRegistrar());
    await widget.locator.registerRegistrar(CoreRouteRegistrar());
    await widget.locator.registerRegistrar(DomainMangaRegistrar());

    // TODO: commented for a while to test analytics
    // FlutterError.onError = (details) {
    //   final LogBox log = widget.locator();
    //   log.log(
    //     details.exceptionAsString(),
    //     name: 'FlutterError',
    //     error: details.exception,
    //     stackTrace: details.stack,
    //   );
    // };
    //
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   final LogBox log = widget.locator();
    //   log.log(
    //     error.toString(),
    //     name: 'PlatformDispatcher',
    //     error: error,
    //     stackTrace: stack,
    //   );
    //   return true;
    // };
    //
    // Isolate.current.addErrorListener(
    //   RawReceivePort((pair) {
    //     if (pair is! List) return;
    //     final LogBox log = widget.locator();
    //     final Object? error = pair.firstOrNull.castOrNull();
    //     final String? trace = pair.lastOrNull.castOrNull();
    //
    //     log.log(
    //       error.toString(),
    //       name: 'Isolate',
    //       error: error,
    //       stackTrace: trace?.let((e) => StackTrace.fromString(e)),
    //     );
    //   }).sendPort,
    // );
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
        observers: () => [logBox.observer, FaroNavigationObserver()],
      ),
      observers: [
        logBox.observer,
        viewer.navigatorObserver,
        FaroNavigationObserver(),
      ],
    );
  }
}
