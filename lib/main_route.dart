import 'package:core_route/core_route.dart';
import 'package:feature_collection/feature_collection.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_search/feature_search.dart';
import 'package:feature_setting/feature_setting.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:collection/collection.dart';

import 'main_path.dart';
import 'screen/main_screen.dart';

class MainRouteBuilder extends BaseRouteBuilder {
  final Map<int, String> _indexToLocation = {
    0: HomeRoutePath.main,
    1: CollectionRoutePath.main,
    2: SettingRoutePath.main,
    3: ProfileRoutePath.main,
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
        redirect: (context, state) => HomeRoutePath.main,
      ),
      ...SearchRouteBuilder().allRoutes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
        shellNavigatorKey: shellNavigatorKey,
      ),
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
            final location = _indexToLocation[index] ?? HomeRoutePath.main;
            context.go(location);
          },
          child: widget,
        );
      },
      routes: [
        HomeRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
        CollectionRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
        SettingRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
        ProfileRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
      ],
    );
  }
}
