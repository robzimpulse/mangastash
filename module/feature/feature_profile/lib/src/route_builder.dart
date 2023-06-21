import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_profile/ui_profile.dart';

import 'route_path.dart';

class ProfileRouteBuilder extends BaseRouteBuilder {

  @override
  GoRoute root({required ServiceLocator locator}) {
    return GoRoute(
      path: ProfileRoutePath.main,
      name: ProfileRoutePath.main,
      builder: (context, state) => const ProfileScreen(),
    );
  }

  @override
  List<RouteBase> routes({required ServiceLocator locator}) {
    return [];
  }
}
