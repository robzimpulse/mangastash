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
        pageBuilder: (context, state) {
          final queries = state.uri.queryParameters;
          return ConfirmationRouteBottomSheet(
            locator: locator,
            title: queries[CommonQueryParam.title],
            content: queries[CommonQueryParam.content] ?? '',
            positiveButtonText: queries[CommonQueryParam.positiveButtonText],
            negativeButtonText: queries[CommonQueryParam.negativeButtonText],
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: CommonRoutePath.mangaMenu,
        name: CommonRoutePath.mangaMenu,
        pageBuilder: (context, state) {
          final queries = state.uri.queryParameters;
          return MangaMenuRouteBottomSheet(
            locator: locator,
            isOnLibrary: queries[CommonQueryParam.isOnLibrary] == 'true',
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: CommonRoutePath.imageMenu,
        name: CommonRoutePath.imageMenu,
        pageBuilder: (context, state) {
          return ImageMenuRouteBottomSheet(locator: locator);
        },
      ),
    ];
  }
}
