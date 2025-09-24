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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Service locator/dependency injector code here
  ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());
  FaroMixin.runner(MangaStashApp(locator: ServiceLocator.asNewInstance()));
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

    // TODO: register module registrar here
    await widget.locator.registerRegistrar(CoreAnalyticsRegistrar());
    await widget.locator.registerRegistrar(CoreStorageRegistrar());
    await widget.locator.registerRegistrar(CoreNetworkRegistrar());
    await widget.locator.registerRegistrar(CoreEnvironmentRegistrar());
    await widget.locator.registerRegistrar(CoreRouteRegistrar());
    await widget.locator.registerRegistrar(DomainMangaRegistrar());

    /// for tracking flutter error
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final LogBox log = widget.locator();
      log.log(
        details.exceptionAsString(),
        name: 'FlutterError',
        error: details.exception,
        stackTrace: details.stack,
      );
      originalOnError?.call(details);
    };

    /// for tracking platform error
    final platformOriginalOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (e, st) {
      final LogBox log = widget.locator();
      log.log(
        e.toString(),
        name: 'PlatformDispatcher',
        error: e,
        stackTrace: st,
      );
      return platformOriginalOnError?.call(e, st) ?? false;
    };

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
        observers: () => [logBox.observer, FaroShellRouteNavigationObserver()],
      ),
      observers: [
        logBox.observer,
        viewer.navigatorObserver,
        FaroShellRouteNavigationObserver(),
      ],
    );
  }
}
