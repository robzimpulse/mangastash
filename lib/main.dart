import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart';

import 'apps_screen.dart';
import 'splash_screen.dart';

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
    return _isInitialized
        ? AppsScreen(locator: _locator, listenThemeUseCase: _locator.get())
        : const SplashScreen();
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


}
