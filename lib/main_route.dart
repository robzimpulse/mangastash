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
  final String _defaultLocation = LibraryRoutePath.library;

  final Map<int, String> _indexToLocation = {
    0: LibraryRoutePath.library,
    1: UpdatesRoutePath.updates,
    2: HistoryRoutePath.history,
    3: BrowseRoutePath.browse,
    4: MoreRoutePath.more,
  };

  Map<String, int> get _locationToIndex {
    return _indexToLocation.map(
      (key, value) => MapEntry(value, key),
    );
  }

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
        shellNavigatorKey: shellNavigatorKey,
      ),
      ...UpdatesRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
        shellNavigatorKey: shellNavigatorKey,
      ),
      ...HistoryRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
        shellNavigatorKey: shellNavigatorKey,
      ),
      ...BrowseRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
        shellNavigatorKey: shellNavigatorKey,
      ),
      ...MoreRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
        shellNavigatorKey: shellNavigatorKey,
      ),
      ...AuthRouteBuilder().routes(
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
      builder: (context, state, widget) => MainScreen(
        index: _locationToIndex[state.location] ?? 0,
        onTapMenu: (index) => context.go(
          _indexToLocation[index] ?? _defaultLocation,
        ),
        child: widget,
      ),
      routes: [
        LibraryRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
        UpdatesRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
        HistoryRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
        BrowseRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
        MoreRouteBuilder().root(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          shellNavigatorKey: shellNavigatorKey,
        ),
      ],
    );
  }
}
