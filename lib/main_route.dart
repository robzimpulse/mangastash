import 'package:core_route/core_route.dart';
import 'package:feature_collection/feature_collection.dart';
import 'package:feature_favourite/feature_favourite.dart';
import 'package:feature_home/feature_home.dart';
import 'package:feature_profile/feature_profile.dart';
import 'package:feature_setting/feature_setting.dart';
import 'package:ui_collection/ui_collection.dart';
import 'package:ui_favourite/ui_favourite.dart';
import 'package:ui_home/ui_home.dart';
import 'package:ui_profile/ui_profile.dart';
import 'package:ui_setting/ui_setting.dart';

import 'error_screen.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) {
          return MainScreen(
            index: shell.currentIndex,
            child: shell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: HomeRouteBuilder().routes(),
          ),
          StatefulShellBranch(
            routes: CollectionRouteBuilder().routes(),
          ),
          StatefulShellBranch(
            routes: FavouriteRouteBuilder().routes(),
          ),
          StatefulShellBranch(
            routes: SettingRouteBuilder().routes(),
          ),
          StatefulShellBranch(
            routes: ProfileRouteBuilder().routes(),
          ),
        ],
      ),
    ];
  }

}