import 'package:core_route/core_route.dart';
import 'package:ui_profile/ui_profile.dart';

import 'route_path.dart';

class ProfileRouteBuilder extends BaseRouteBuilder {
  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: ProfileRoutePath.main,
        name: ProfileRoutePath.main,
        builder: (context, state) => const ProfileScreen(),
      ),
    ];
  }
}
