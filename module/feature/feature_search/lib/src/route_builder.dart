import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_search/ui_search.dart';

import 'route_path.dart';

class SearchRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: SearchRoutePath.main,
      name: SearchRoutePath.main,
      builder: (context, state) => SearchScreen.create(locator: locator),
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
        path: SearchRoutePath.setting,
        name: SearchRoutePath.setting,
        builder: (context, state) {
          return SearchParameterEditorScreen.create(
            locator: locator,
            parameter: const SearchMangaParameter(),
            callback: state.getArgs<SearchMangaParameter>()?.callback,
          );
        },
      ),
    ];
  }
}
