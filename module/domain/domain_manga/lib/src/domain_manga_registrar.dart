import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/tags_manager.dart';
import 'use_case/get_all_chapter_use_case.dart';
import 'use_case/get_author_use_case.dart';
import 'use_case/get_chapter_image_use_case.dart';
import 'use_case/get_chapter_use_case.dart';
import 'use_case/get_cover_art_use_case.dart';
import 'use_case/get_manga_use_case.dart';
import 'use_case/list_tag_use_case.dart';
import 'use_case/listen_list_tag_use_case.dart';
import 'use_case/search_chapter_use_case.dart';
import 'use_case/search_manga_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    // manga dex services
    locator.registerFactory(() => MangaService(locator()));
    locator.registerFactory(() => ChapterService(locator()));
    locator.registerFactory(() => AtHomeService(locator()));
    locator.registerFactory(() => AuthorService(locator()));
    locator.registerFactory(() => CoverArtService(locator()));

    // manga dex repositories
    locator.registerFactory(() => AtHomeRepository(service: locator()));
    locator.registerFactory(() => MangaRepository(service: locator()));
    locator.registerFactory(() => ChapterRepository(service: locator()));
    locator.registerFactory(() => AuthorRepository(service: locator()));
    locator.registerFactory(() => CoverRepository(service: locator()));

    locator.registerFactory(() => GetAuthorUseCase(repository: locator()));
    locator.registerFactory(() => GetChapterUseCase(repository: locator()));
    locator.registerFactory(() => GetCoverArtUseCase(repository: locator()));
    locator.registerFactory(() => GetMangaUseCase(repository: locator()));
    locator.registerFactory(() => ListTagUseCase(repository: locator()));
    locator.registerFactory(() => SearchChapterUseCase(repository: locator()));

    locator.registerFactory(
      () => GetChapterImageUseCase(
        repository: locator(),
      ),
    );

    locator.registerFactory(
      () => SearchMangaUseCase(
        mangaRepository: locator(),
        authorRepository: locator(),
        coverRepository: locator(),
      ),
    );

    locator.registerFactory(
      () => GetAllChapterUseCase(
        chapterRepository: locator(),
      ),
    );

    locator.registerLazySingleton(() => TagsManager(listTagUseCase: locator()));
    locator.alias<ListenListTagUseCase, TagsManager>();
  }
}
