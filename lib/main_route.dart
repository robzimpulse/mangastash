import 'package:core_route/core_route.dart';
import 'package:feature_collection/feature_collection.dart';
import 'package:feature_favourite/feature_favourite.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_setting/feature_setting.dart';

import 'main_path.dart';
import 'main_screen.dart';

class MainRouteBuilder extends BaseRouteBuilder {
  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: MainPath.main,
        name: MainPath.main,
        redirect: (context, state) => HomeRoutePath.main,
      ),
    ];
  }

  @override
  RouteBase root() {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, shell) {
        return MainScreen(
          index: shell.currentIndex,
          child: shell,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [HomeRouteBuilder().root()],
        ),
        StatefulShellBranch(
          routes: [CollectionRouteBuilder().root()],
        ),
        StatefulShellBranch(
          routes: [FavouriteRouteBuilder().root()],
        ),
        StatefulShellBranch(
          routes: [SettingRouteBuilder().root()],
        ),
        StatefulShellBranch(
          routes: [ProfileRouteBuilder().root()],
        ),
      ],
    );
  }

}