import 'dart:developer';

import 'package:service_locator/service_locator.dart';

import 'manager/auth_manager.dart';
import 'service/auth_service.dart';
import 'use_case/get_auth_use_case.dart';
import 'use_case/listen_auth_use_case.dart';
import 'use_case/login_anonymously_use_case.dart';
import 'use_case/login_use_case.dart';
import 'use_case/logout_use_case.dart';
import 'use_case/register_use_case.dart';

class CoreAuthRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString(), time: DateTime.now());

    locator.registerFactory(() => AuthService(app: locator()));
    locator.registerFactory(
      () => LoginAnonymouslyUseCase(authService: locator()),
    );
    locator.registerFactory(() => LogoutUseCase(authService: locator()));
    locator.registerFactory(() => LoginUseCase(authService: locator()));
    locator.registerFactory(() => RegisterUseCase(authService: locator()));

    locator.registerSingleton(AuthManager(service: locator()));
    locator.alias<ListenAuthUseCase, AuthManager>();
    locator.alias<GetAuthUseCase, AuthManager>();
    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }
}
