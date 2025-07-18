import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'route_path.dart';

class CommonRouteBuilder extends BaseRouteBuilder {
  @override
  RouteBase root({
    required ServiceLocator locator,
    ValueGetter<List<NavigatorObserver>>? observers,
  }) {
    // intended empty since this routes should not be used
    throw UnimplementedError();
  }

  @override
  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) {
    return [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: CommonRoutePath.confirmation,
        name: CommonRoutePath.confirmation,
        pageBuilder:
            (context, state) => ConfirmationRouteBottomSheet(
              locator: locator,
              title:
                  state.uri.queryParameters[CommonRoutePath.confirmationTitle],
              content:
                  state.uri.queryParameters[CommonRoutePath
                      .confirmationContent] ??
                  '',
              positiveButtonText:
                  state.uri.queryParameters[CommonRoutePath
                      .confirmationPositiveButtonText],
              negativeButtonText:
                  state.uri.queryParameters[CommonRoutePath
                      .confirmationNegativeButtonText],
            ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: CommonRoutePath.menu,
        name: CommonRoutePath.menu,
        pageBuilder:
            (context, state) => MenuRouteBottomSheet(
              locator: locator,
              isOnLibrary:
                  state.uri.queryParameters[CommonRoutePath.menuIsOnLibrary] ==
                  'true',
            ),
      ),
    ];
  }
}
