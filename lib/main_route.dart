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
  List<GoRoute> routes() {
    return [
      GoRoute(
        path: MainPath.mainScreen,
        name: MainPath.mainScreen,
        builder: (context, state) {
          final screen = state.pathParameters['screen'];

          switch (screen) {
            case HomeRoutePath.home: {
              return const MainScreen(
                index: 0,
                child: HomeScreen(),
              );
            }
            case CollectionRoutePath.home: {
              return const MainScreen(
                index: 1,
                child: CollectionScreen(),
              );
            }
            case FavouriteRoutePath.home: {
              return const MainScreen(
                index: 2,
                child: FavouriteScreen(),
              );
            }
            case SettingRoutePath.home: {
              return const MainScreen(
                index: 3,
                child: SettingScreen(),
              );
            }
            case ProfileRoutePath.home: {
              return const MainScreen(
                index: 4,
                child: ProfileScreen(),
              );
            }
            default: {
              return ErrorScreen(
                text: 'Error Screen: $screen',
              );
            }
          }
        },
      ),
    ];
  }

}