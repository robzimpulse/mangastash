import 'dart:developer';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'firebase_options.dart';
import 'main_path.dart';
import 'main_route.dart';
import 'screen/apps_screen.dart';
import 'screen/error_screen.dart';
import 'screen/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Service locator/dependency injector code here
  ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());
  final locator = ServiceLocator.asNewInstance();
  runApp(MangaStashApp(locator: locator));
}

class MangaStashApp extends StatefulWidget {
  const MangaStashApp({super.key, required this.locator, this.testing = false});

  final bool testing;

  final ServiceLocator locator;

  @override
  State<StatefulWidget> createState() => _MangaStashAppState();
}

class _MangaStashAppState extends State<MangaStashApp> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GoRouter>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        final router = snapshot.data;
        if (router == null) return const SplashScreen();
        return AppsScreen(
          listenThemeUseCase: widget.locator.get(),
          routerConfig: router,
        );
      },
    );
  }

  Future<GoRouter> _initializeApp() async {
    await initiateAppLocator();
    final route = _route(locator: widget.locator);
    widget.locator<Alice>().setNavigatorKey(route.routerDelegate.navigatorKey);
    return route;
  }

  Future<void> initiateAppLocator() async {
    if (widget.testing) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // TODO: register module registrar here
    await widget.locator.registerRegistrar(CoreNetworkRegistrar());
    await widget.locator.registerRegistrar(CoreStorageRegistrar());
    await widget.locator.registerRegistrar(CoreEnvironmentRegistrar());
    await widget.locator.registerRegistrar(DomainMangaRegistrar());
  }

  GoRouter _route({
    required ServiceLocator locator,
    String initialRoute = MainPath.main,
  }) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialRoute,
      // TODO: replace [errorBuilder] with [onError] based on https://github.com/flutter/flutter/issues/108144
      errorBuilder: (context, state) => ErrorScreen(
        text: state.error.toString(),
      ),
      routes: MainRouteBuilder().allRoutes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
        shellNavigatorKey: GlobalKey<NavigatorState>(),
      ),
      observers: [BaseRouteObserver()],
    );
  }
}
