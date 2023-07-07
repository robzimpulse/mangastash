import 'package:core_route/core_route.dart';
import 'package:feature_library/feature_library.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';

import 'main_path.dart';
import 'screen/main_screen.dart';

class MainRouteBuilder extends BaseRouteBuilder {

  final String _defaultLocation = LibraryRoutePath.library;

  final Map<int, String> _indexToLocation = {
    0: LibraryRoutePath.library,
    1: LibraryRoutePath.library,
    2: LibraryRoutePath.library,
    3: LibraryRoutePath.library,
  };

  @override
  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MainPath.main,
        name: MainPath.main,
        redirect: (context, state) => LibraryRoutePath.library,
      ),
      // ...SearchRouteBuilder().allRoutes(
      //   locator: locator,
      //   rootNavigatorKey: rootNavigatorKey,
      //   shellNavigatorKey: shellNavigatorKey,
      // ),
    ];
  }

  @override
  RouteBase root({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, widget) {
        final index = _indexToLocation.map(
          (key, value) => MapEntry(value, key),
        );
        return MainScreen(
          index: index[state.location] ?? 0,
          onTapMenu: (index) {
            final location = _indexToLocation[index] ?? _defaultLocation;
            context.go(location);
          },
          child: widget,
        );
      },
      routes: [
        LibraryRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
        // CollectionRouteBuilder().root(
        //   locator: locator,
        //   rootNavigatorKey: rootNavigatorKey,
        //   shellNavigatorKey: shellNavigatorKey,
        // ),
        // SettingRouteBuilder().root(
        //   locator: locator,
        //   rootNavigatorKey: rootNavigatorKey,
        //   shellNavigatorKey: shellNavigatorKey,
        // ),
        // ProfileRouteBuilder().root(
        //   locator: locator,
        //   rootNavigatorKey: rootNavigatorKey,
        //   shellNavigatorKey: shellNavigatorKey,
        // ),
      ],
    );
  }
}
