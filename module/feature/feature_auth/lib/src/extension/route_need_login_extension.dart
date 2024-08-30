import 'package:core_auth/core_auth.dart';
import 'package:go_router/go_router.dart';

import '../../feature_auth.dart';

extension RouteNeedLoginExtension on GoRouterState {
  String? needLogin(GetAuth auth) {
    final status = auth.authState?.status;
    if (status == AuthStatus.loggedIn) return null;
    return [
      AuthRoutePath.login,
      {
        AuthRoutePath.onFinishPath: path,
      }.entries.map((e) => '${e.key}=${e.value}').join('&'),
    ].join('?');
  }
}
