import 'package:core_route/core_route.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:feature_history/feature_history.dart';
import 'package:feature_library/feature_library.dart';
import 'package:feature_more/feature_more.dart';
import 'package:feature_updates/feature_updates.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';

import 'main_path.dart';
import 'screen/error_screen.dart';
import 'screen/main_screen.dart';

class MainRouteBuilder extends BaseRouteBuilder {

  @override
  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) {
    return [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MainPath.main,
        name: MainPath.main,
        redirect: (context, state) => LibraryRoutePath.library,
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MainPath.notFound,
        name: MainPath.notFound,
        builder: (context, state) => ErrorScreen(
          text: state.error.toString(),
        ),
      ),
      ...LibraryRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
      ),
      ...UpdatesRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
      ),
      ...HistoryRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
      ),
      ...BrowseRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
      ),
      ...MoreRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
      ),
      ...AuthRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
      ),
    ];
  }

  @override
  RouteBase root({
    required ServiceLocator locator,
  }) {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainScreen(
        index: shell.currentIndex,
        onTapMenu: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        child: shell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            LibraryRouteBuilder().root(locator: locator),
          ],
        ),
        StatefulShellBranch(
          routes: [
            UpdatesRouteBuilder().root(locator: locator),
          ],
        ),
        StatefulShellBranch(
          routes: [
            HistoryRouteBuilder().root(locator: locator),
          ],
        ),
        StatefulShellBranch(
          routes: [
            BrowseRouteBuilder().root(locator: locator),
          ],
        ),
        StatefulShellBranch(
          routes: [
            MoreRouteBuilder().root(locator: locator),
          ],
        ),
      ],
    );
  }
}
