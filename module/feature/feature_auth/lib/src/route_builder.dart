import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_auth/ui_auth.dart';
import 'package:ui_common/ui_common.dart';

import '../feature_auth.dart';

class AuthRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
  }) {
    return GoRoute(
      path: AuthRoutePath.auth,
      name: AuthRoutePath.auth,
      redirect: (context, state) => AuthRoutePath.login,
    );
  }

  @override
  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) {
    return [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AuthRoutePath.login,
        name: AuthRoutePath.login,
        builder: (context, state) => LoginScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AuthRoutePath.register,
        name: AuthRoutePath.register,
        builder: (context, state) => RegisterScreen.create(locator: locator),
      ),
    ];
  }
}
