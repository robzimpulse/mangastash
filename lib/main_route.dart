import 'dart:async';

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
  final _rootBuilder = [
    LibraryRouteBuilder(),
    UpdatesRouteBuilder(),
    HistoryRouteBuilder(),
    BrowseRouteBuilder(),
    MoreRouteBuilder(),
  ];

  late final _builders = [CommonRouteBuilder(), ..._rootBuilder];

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
        builder: (context, state) {
          return ErrorScreen(text: state.extra as String? ?? '');
        },
      ),
      ..._builders.aggregatedRoutes(
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
          index: shell.currentIndex,
          onTapMenu: (index) {
            shell.goBranch(index, initialLocation: index == shell.currentIndex);
          },
          onTapClosedApps: () {
            return context.pushNamed<bool>(
              CommonRoutePath.confirmation,
              queryParameters: {
                CommonQueryParam.title: 'Exit',
                CommonQueryParam.content: 'Are you sure want to quit?',
                CommonQueryParam.negativeButtonText: 'No',
                CommonQueryParam.positiveButtonText: 'Yes',
              },
            );
          },
          child: shell,
        );
      },
      branches: [
        ..._rootBuilder.map(
          (e) => StatefulShellBranch(
            observers: observers?.call(),
            routes: [e.root(locator: locator, observers: observers)],
          ),
        ),
      ],
    );
  }

  @override
  FutureOr<OnEnterResult?> onEnter({
    required BuildContext context,
    required GoRouterState current,
    required GoRouterState next,
    required GoRouter router,
  }) async {
    return _builders.aggregatedOnEnter(
      context: context,
      current: current,
      next: next,
      router: router,
    );
  }
}
