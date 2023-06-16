import 'dart:developer';

import 'package:feature_home/feature_home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_home/ui_home.dart';

import 'path.dart';

void main() {
  // ServiceLocatorInitiator.setServiceLocatorFactory(() => GetItServiceLocator());
  // final locator = ServiceLocator.asNewInstance();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MangaStashApp());
}

class MangaStashApp extends StatefulWidget {
  const MangaStashApp({super.key});

  @override
  State<StatefulWidget> createState() => MangaStashAppState();
}

class MangaStashAppState extends State<MangaStashApp> {
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
          title: 'Stock Checker',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: ThemeData(primarySwatch: Colors.blue),
        ),
      );
    } else {
      return MaterialApp(
        title: 'Flutter Demo',
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
    log('initiateAppLocator', name: 'robzimpulse');
    return ServiceLocator.asNewInstance();
  }

  GoRouter initiateRouter({String initialRoute = MainPath.main}) {
    log('initiateRouter', name: 'robzimpulse');
    return GoRouter(
      initialLocation: initialRoute,
      errorBuilder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Error Not Found'),
        ),
      ),
      routes: [
        GoRoute(
          path: MainPath.main,
          name: MainPath.main,
          redirect: (context, state) => HomePath.main,
        ),
        ...HomeRouteBuilder().routes()
      ],
      observers: [

      ],
    );
  }
}



