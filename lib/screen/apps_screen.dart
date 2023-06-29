import 'package:alice_lightweight/alice.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';
import 'package:ios_willpop_transition_theme/ios_willpop_transition_theme.dart';
import 'package:responsive_framework/breakpoint.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:service_locator/service_locator.dart';

import '../main_path.dart';
import '../main_route.dart';
import 'error_screen.dart';

class AppsScreen extends StatelessWidget {
  final ServiceLocator locator;

  final ListenThemeUseCase listenThemeUseCase;

  const AppsScreen({
    super.key,
    required this.locator,
    required this.listenThemeUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final route = _route(locator: locator);
    _setupAlice(locator: locator, route: route);
    return StreamBuilder<ThemeData>(
      stream: listenThemeUseCase.themeDataStream,
      builder: (context, snapshot) {
        final theme = snapshot.data?.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: IOSWillPopTransitionsBuilder(),
              TargetPlatform.android: IOSWillPopTransitionsBuilder(),
            },
          ),
        );
        return MaterialApp.router(
          title: 'Manga Stash',
          debugShowCheckedModeBanner: false,
          routerConfig: route,
          theme: theme ?? ThemeData.light(),
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
      },
    );
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
