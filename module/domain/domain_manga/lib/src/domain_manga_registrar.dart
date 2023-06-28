import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'use_case/search_manga_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerRegistrar(MangaDexApiRegistrar());

    locator.registerFactory(
      () => SearchMangaUseCase(searchRepository: locator()),
    );
  }
}