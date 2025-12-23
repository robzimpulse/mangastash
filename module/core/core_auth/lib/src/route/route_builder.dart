import 'package:core_route/core_route.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';

import '../enum/auth_status.dart';
import '../screen/login_screen/login_screen.dart';
import '../screen/register_screen/register_screen.dart';
import '../use_case/get_auth_use_case.dart';
import 'route_path.dart';

class AuthRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    ValueGetter<List<NavigatorObserver>>? observers,
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
        redirect: (context, state) {
          final queryParams = state.uri.queryParameters;
          final destination = queryParams[AuthQueryParam.onFinishPath];
          final status = locator<GetAuthUseCase>().authState?.status;
          final isLoggedIn = status == AuthStatus.loggedIn;
          return isLoggedIn ? destination : null;
        },
        builder: (context, state) => LoginScreen.create(
          locator: locator,
          onFinishPath: state.uri.queryParameters[AuthQueryParam.onFinishPath],
          onTapRegister: () => context.push(AuthRoutePath.register),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AuthRoutePath.register,
        name: AuthRoutePath.register,
        builder: (context, state) => RegisterScreen.create(
          locator: locator,
        ),
      ),
    ];
  }
}
