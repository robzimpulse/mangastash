import 'package:core_route/core_route.dart';
import 'package:feature_collection/feature_collection.dart';
import 'package:feature_favourite/feature_favourite.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_setting/feature_setting.dart';
import 'package:service_locator/service_locator.dart';

import 'main_path.dart';
import 'main_screen.dart';

class MainRouteBuilder extends BaseRouteBuilder {
  @override
  List<RouteBase> routes({required ServiceLocator locator}) {
    return [
      GoRoute(
        path: MainPath.main,
        name: MainPath.main,
        redirect: (context, state) => HomeRoutePath.main,
      ),
    ];
  }

  @override
  RouteBase root({required ServiceLocator locator}) {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, shell) {
        return MainScreen(
          index: shell.currentIndex,
          child: shell,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [HomeRouteBuilder().root(locator: locator)],
        ),
        StatefulShellBranch(
          routes: [CollectionRouteBuilder().root(locator: locator)],
        ),
        StatefulShellBranch(
          routes: [FavouriteRouteBuilder().root(locator: locator)],
        ),
        StatefulShellBranch(
          routes: [SettingRouteBuilder().root(locator: locator)],
        ),
        StatefulShellBranch(
          routes: [ProfileRouteBuilder().root(locator: locator)],
        ),
      ],
    );
  }

}