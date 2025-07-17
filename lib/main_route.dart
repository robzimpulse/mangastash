import 'package:core_route/core_route.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:feature_common/feature_common.dart';
import 'package:feature_history/feature_history.dart';
import 'package:feature_library/feature_library.dart';
import 'package:feature_more/feature_more.dart';
import 'package:feature_updates/feature_updates.dart';
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
          text: state.extra as String? ?? '',
        ),
      ),
      ...CommonRouteBuilder().routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
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
    ];
  }

  @override
  RouteBase root({
    required ServiceLocator locator,
    List<NavigatorObserver> observers = const [],
  }) {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainScreen(
        index: shell.currentIndex,
        onTapMenu: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        onTapClosedApps: () => context.pushNamed<bool>(
          CommonRoutePath.confirmation,
          queryParameters: {
            CommonRoutePath.confirmationTitle: 'Exit',
            CommonRoutePath.confirmationContent: 'Are you sure want to quit?',
            CommonRoutePath.confirmationNegativeButtonText: 'No',
            CommonRoutePath.confirmationPositiveButtonText: 'Yes',
          },
        ),
        child: shell,
      ),
      branches: [
        StatefulShellBranch(
          observers: observers,
          routes: [
            LibraryRouteBuilder().root(locator: locator),
          ],
        ),
        StatefulShellBranch(
          observers: observers,
          routes: [
            UpdatesRouteBuilder().root(locator: locator),
          ],
        ),
        StatefulShellBranch(
          observers: observers,
          routes: [
            HistoryRouteBuilder().root(locator: locator),
          ],
        ),
        StatefulShellBranch(
          observers: observers,
          routes: [
            BrowseRouteBuilder().root(locator: locator),
          ],
        ),
        StatefulShellBranch(
          observers: observers,
          routes: [
            MoreRouteBuilder().root(locator: locator),
          ],
        ),
      ],
    );
  }
}
