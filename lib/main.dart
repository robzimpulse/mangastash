import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:feature_home/feature_home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:service_locator/service_locator.dart';

import 'error_screen.dart';
import 'main_path.dart';
import 'main_route.dart';

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

  bool _isInitialized = false;

  @override
  void initState() {
    _initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return Provider<ServiceLocator>(
        create: (context) => _locator,
        child: StreamBuilder<ThemeData>(
          stream: _locator.get<ListenThemeUseCase>().themeDataStream,
          builder: (context, snapshot) {
            final theme = snapshot.data;
            if (theme != null) {
              return MaterialApp.router(
                title: 'Manga Stash',
                debugShowCheckedModeBanner: false,
                routerConfig: _route(locator: _locator),
                theme: theme,
                builder: (context, child) {
                  return ResponsiveBreakpoints.builder(
                    breakpoints: const [
                      Breakpoint(start: 0, end: 450, name: MOBILE),
                      Breakpoint(start: 451, end: 800, name: TABLET),
                      Breakpoint(start: 801, end: 1920, name: DESKTOP),
                      Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                    ],
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
            } else {
              return MaterialApp(
                title: 'Manga Stash',
                theme: ThemeData(primarySwatch: Colors.blue),
                debugShowCheckedModeBanner: false,
                home: const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
          },
        ),
      );
    } else {
      return MaterialApp(
        title: 'Manga Stash',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }

  void _initializeApp() async {
    final locator = await initiateAppLocator();
    setState(() {
      _isInitialized = true;
      _locator = locator;
    });
  }

  Future<ServiceLocator> initiateAppLocator() async {
    ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());
    final locator = ServiceLocator.asNewInstance();

    // TODO: register module registrar here
    await locator.registerRegistrar(CoreStorageRegistrar());
    await locator.registerRegistrar(CoreEnvironmentRegistrar());
    return locator;
  }

  GoRouter _route({
    required ServiceLocator locator,
    String initialRoute = MainPath.main
  }) {
    final routes = MainRouteBuilder();
    return GoRouter(
      initialLocation: initialRoute,
      errorBuilder: (context, state) => ErrorScreen(
        text: state.error.toString(),
      ),
      routes: [
        routes.root(locator: locator),
        ...routes.routes(locator: locator)
      ],
      observers: [

      ],
    );
  }
}
