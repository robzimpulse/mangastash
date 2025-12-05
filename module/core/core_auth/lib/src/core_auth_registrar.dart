import 'package:core_analytics/core_analytics.dart';
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
    final start = DateTime.timestamp().toIso8601String();

    final LogBox log = locator();

    locator.registerLazySingletonAsync(
      () => Firebase.initializeApp(options: locator.getOrNull()),
    );
    locator.registerFactory(() => AuthService(app: locator()));
    locator.registerFactory(
      () => LoginAnonymouslyUseCase(authService: locator()),
    );
    locator.registerFactory(() => LogoutUseCase(authService: locator()));
    locator.registerFactory(() => LoginUseCase(authService: locator()));
    locator.registerFactory(() => RegisterUseCase(authService: locator()));

    locator.registerLazySingleton(
      () => AuthManager(service: locator()),
      dispose: (e) => e.dispose(),
    );
    locator.alias<ListenAuthUseCase, AuthManager>();
    locator.alias<GetAuthUseCase, AuthManager>();

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'start': start, 'finish': DateTime.timestamp().toIso8601String()},
    );
  }

  @override
  Future<void> allReady(ServiceLocator locator) async {
    await locator.isReady<FirebaseApp>();
  }
}
