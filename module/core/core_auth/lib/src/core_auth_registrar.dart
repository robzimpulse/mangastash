import 'package:log_box/log_box.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/auth_manager.dart';
import 'use_case/get_auth_use_case.dart';
import 'use_case/listen_auth_use_case.dart';
import 'use_case/login_anonymously_use_case.dart';
import 'use_case/login_use_case.dart';
import 'use_case/logout_use_case.dart';
import 'use_case/register_use_case.dart';

class CoreAuthRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();

    log.log(
      'Register ${runtimeType.toString()}',
      name: 'Services',
      id: runtimeType.toString(),
      extra: {'start': DateTime.timestamp().toIso8601String()},
    );

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

    log.log(
      'Register ${runtimeType.toString()}',
      name: 'Services',
      id: runtimeType.toString(),
      extra: {'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}
