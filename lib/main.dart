import 'package:alice_lightweight/alice.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart';

import 'main_path.dart';
import 'main_route.dart';
import 'screen/apps_screen.dart';
import 'screen/error_screen.dart';
import 'screen/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MangaStashApp());
}

class MangaStashApp extends StatefulWidget {
  const MangaStashApp({super.key});

  @override
  State<StatefulWidget> createState() => _MangaStashAppState();
}

class _MangaStashAppState extends State<MangaStashApp> {
  late final ServiceLocator _locator;
  late final GoRouter _router;
  bool _isInitialized = false;

  @override
  void initState() {
    _initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? AppsScreen(locator: _locator, listenThemeUseCase: _locator.get(), routerConfig: _router,)
        : const SplashScreen();
  }

  void _initializeApp() async {
    final locator = await initiateAppLocator();
    final route = _route(locator: locator);
    _setupAlice(locator: locator, route: route);
    setState(() {
      _isInitialized = true;
      _locator = locator;
      _router = route;
    });
  }

  Future<ServiceLocator> initiateAppLocator() async {
    ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());
    final locator = ServiceLocator.asNewInstance();

    // TODO: register module registrar here
    await locator.registerRegistrar(CoreNetworkRegistrar());
    await locator.registerRegistrar(CoreStorageRegistrar());
    await locator.registerRegistrar(CoreEnvironmentRegistrar());
    await locator.registerRegistrar(DomainMangaRegistrar());
    return locator;
  }

  GoRouter _route({
    required ServiceLocator locator,
    String initialRoute = MainPath.main,
  }) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialRoute,
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

  void _setupAlice({
    required ServiceLocator locator,
    required GoRouter route,
  }) {
    final Alice alice = locator();
    final navigatorKey = route.routerDelegate.navigatorKey;
    alice.setNavigatorKey(navigatorKey);
  }
}
