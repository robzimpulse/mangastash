import 'package:alice_lightweight/alice.dart';
import 'package:service_locator/service_locator.dart';

import 'client/manga_dex_dio.dart';
import 'interceptor/header_interceptor.dart';
import 'repository/at_home_repository.dart';
import 'repository/chapter_repository.dart';
import 'repository/search_repository.dart';
import 'service/at_home_service.dart';
import 'service/chapter_service.dart';
import 'service/search_service.dart';

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
    locator.registerFactory(() => ChapterService(locator()));
    locator.registerFactory(() => AtHomeService(locator()));

    locator.registerFactory(() => AtHomeRepository(service: locator()));
    locator.registerFactory(() => SearchRepository(service: locator()));
    locator.registerFactory(() => ChapterRepository(service: locator()));
  }
}
