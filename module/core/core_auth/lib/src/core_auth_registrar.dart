import 'package:service_locator/service_locator.dart';

import 'manager/auth_manager.dart';
import 'use_case/listen_auth.dart';
import 'use_case/update_auth.dart';

class CoreAuthRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerSingleton(AuthManager());
    locator.alias<UpdateAuth, AuthManager>();
    locator.alias<ListenAuth, AuthManager>();
  }
}
