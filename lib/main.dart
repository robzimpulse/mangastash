import 'package:feature_home/feature_home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:service_locator/service_locator.dart';

import 'error_screen.dart';
import 'main_path.dart';
import 'main_route.dart';

void main() {
  // ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());
  // final locator = ServiceLocator.asNewInstance();
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
    if (_isInitialized) {
      return Provider<ServiceLocator>(
        create: (context) => _locator,
        child: MaterialApp.router(
          title: 'Manga Stash',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: ThemeData(primarySwatch: Colors.blue),
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
    final router = initiateRouter();
    setState(() {
      _isInitialized = true;
      _locator = locator;
      _router = router;
    });
  }

  Future<ServiceLocator> initiateAppLocator() async {
    ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());
    await Future.delayed(const Duration(seconds: 3));
    // TODO: register module registrar here
    return ServiceLocator.asNewInstance();
  }

  GoRouter initiateRouter({String initialRoute = MainPath.main}) {
    return GoRouter(
      initialLocation: initialRoute,
      errorBuilder: (context, state) => ErrorScreen(
        text: state.error.toString(),
      ),
      routes: [
        GoRoute(
          path: MainPath.main,
          name: MainPath.main,
          redirect: (context, state) => HomeRoutePath.main,
        ),
        ...MainRouteBuilder().routes(),
      ],
      observers: [

      ],
    );
  }
}
