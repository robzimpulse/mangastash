import 'dart:developer';

import 'package:service_locator/service_locator.dart';

import 'manager/auth_manager.dart';
import 'use_case/get_auth.dart';
import 'use_case/listen_auth.dart';
import 'use_case/login_anonymously.dart';
import 'use_case/update_auth.dart';

class CoreAuthRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString());
    locator.registerSingleton(AuthManager(app: locator()));
    locator.alias<UpdateAuth, AuthManager>();
    locator.alias<ListenAuth, AuthManager>();
    locator.alias<LoginAnonymously, AuthManager>();
    locator.alias<GetAuth, AuthManager>();
    log('finish register', name: runtimeType.toString());
  }
}
