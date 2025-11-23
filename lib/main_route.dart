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
        builder:
            (context, state) => ErrorScreen(text: state.extra as String? ?? ''),
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
    ValueGetter<List<NavigatorObserver>>? observers,
  }) {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, shell) {
        return MainScreen(
          headlessWebviewUseCase: locator(),
          index: shell.currentIndex,
          onTapMenu: (index) {
            shell.goBranch(index, initialLocation: index == shell.currentIndex);
          },
          onTapClosedApps: () {
            return context.pushNamed<bool>(
              CommonRoutePath.confirmation,
              queryParameters: {
                CommonRoutePath.confirmationTitle: 'Exit',
                CommonRoutePath.confirmationContent:
                    'Are you sure want to quit?',
                CommonRoutePath.confirmationNegativeButtonText: 'No',
                CommonRoutePath.confirmationPositiveButtonText: 'Yes',
              },
            );
          },
          child: shell,
        );
      },
      branches: [
        StatefulShellBranch(
          observers: observers?.call(),
          routes: [
            LibraryRouteBuilder().root(locator: locator, observers: observers),
          ],
        ),
        StatefulShellBranch(
          observers: observers?.call(),
          routes: [
            UpdatesRouteBuilder().root(locator: locator, observers: observers),
          ],
        ),
        StatefulShellBranch(
          observers: observers?.call(),
          routes: [
            HistoryRouteBuilder().root(locator: locator, observers: observers),
          ],
        ),
        StatefulShellBranch(
          observers: observers?.call(),
          routes: [
            BrowseRouteBuilder().root(locator: locator, observers: observers),
          ],
        ),
        StatefulShellBranch(
          observers: observers?.call(),
          routes: [
            MoreRouteBuilder().root(locator: locator, observers: observers),
          ],
        ),
      ],
    );
  }
}
