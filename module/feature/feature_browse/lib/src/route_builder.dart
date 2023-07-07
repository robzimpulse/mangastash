import 'package:core_route/core_route.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_browse/ui_browse.dart';

import 'route_path.dart';

class BrowseRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return GoRoute(
      path: BrowseRoutePath.browse,
      name: BrowseRoutePath.browse,
      builder: (context, state) => BrowseScreen.create(
        locator: locator,
        // TODO: implement redirect to search source screen
        onTapSearchSource: (context) {},
      ),
      pageBuilder: (context, state) => NoTransitionPage(
        child: BrowseScreen.create(
          locator: locator,
          // TODO: implement redirect to search source screen
          onTapSearchSource: (context) {},
        ),
      ),
    );
  }

  @override
  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return [];
  }
}