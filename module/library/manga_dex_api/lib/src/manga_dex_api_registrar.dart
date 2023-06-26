import 'package:alice_lightweight/alice.dart';
import 'package:service_locator/service_locator.dart';

import '../manga_dex_api.dart';
import 'interceptor/header_interceptor.dart';

class MangaDexApiRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerLazySingleton(() => Alice());
    locator.registerLazySingleton(() => HeaderInterceptor());
    locator.registerFactory(
      () => MangaDexDio(
        aliceDioInterceptor: locator<Alice>().getDioInterceptor(),
        headerInterceptor: locator(),
      ),
    );
    locator.registerFactory(() => SearchService(locator()));
  }
}
