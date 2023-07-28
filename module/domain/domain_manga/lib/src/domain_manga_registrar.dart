import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/tags_manager.dart';
import 'use_case/get_cover_art_use_case.dart';
import 'use_case/get_manga_use_case.dart';
import 'use_case/list_tag_use_case.dart';
import 'use_case/listen_list_tag_use_case.dart';
import 'use_case/search_manga_use_case.dart';


class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    await locator.registerRegistrar(MangaDexApiRegistrar());

    locator.registerFactory(() => SearchMangaUseCase(repository: locator()));
    locator.registerFactory(() => ListTagUseCase(repository: locator()));
    locator.registerFactory(() => GetCoverArtUseCase(repository: locator()));
    locator.registerFactory(() => GetMangaUseCase(repository: locator()));

    locator.registerSingleton(TagsManager(listTagUseCase: locator()));
    locator.alias<ListenListTagUseCase, TagsManager>();
  }
}
