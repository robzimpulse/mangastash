import 'dart:developer';

import 'package:service_locator/service_locator.dart';

import 'manager/auth_manager.dart';
import 'service/auth_service.dart';
import 'use_case/get_auth.dart';
import 'use_case/listen_auth.dart';
import 'use_case/login_anonymously.dart';

class CoreAuthRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString());

    locator.registerFactory(() => AuthService(app: locator()));
    locator.registerFactory(() => LoginAnonymously(authService: locator()));

    locator.registerSingleton(AuthManager(service: locator()));
    locator.alias<ListenAuth, AuthManager>();
    locator.alias<GetAuth, AuthManager>();
    log('finish register', name: runtimeType.toString());
  }
}
