import 'dart:developer';

import 'package:core_network/core_network.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'use_case/chapter/get_chapter_on_manga_dex_use_case.dart';
import 'use_case/chapter/get_chapter_use_case.dart';
import 'use_case/chapter/search_chapter_on_manga_dex_use_case.dart';
import 'use_case/chapter/search_chapter_use_case.dart';
import 'use_case/library/add_to_library_use_case.dart';
import 'use_case/manga/get_manga_on_mangadex_use_case.dart';
import 'use_case/manga/get_manga_use_case.dart';
import 'use_case/manga/search_manga_on_mangadex_use_case.dart';
import 'use_case/manga/search_manga_use_case.dart';
import 'use_case/manga_source/add_manga_source_use_case.dart';
import 'use_case/manga_source/get_list_manga_sources_use_case.dart';
import 'use_case/manga_source/get_manga_source_use_case.dart';
import 'use_case/manga_source/search_manga_source_use_case.dart';
import 'use_case/manga_source/update_manga_source_use_case.dart';
import 'use_case/manga_tags/get_list_tags_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString(), time: DateTime.now());

    // manga dex dio client
    locator.registerFactory(
      () => MangaDexDio(interceptors: [locator<Alice>().getDioInterceptor()]),
    );

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

    locator.registerFactory(
      () => AddMangaSourcesUseCase(service: locator()),
    );
    locator.registerFactory(
      () => UpdateMangaSourcesUseCase(service: locator()),
    );
    locator.registerFactory(
      () => GetListMangaSourcesUseCase(service: locator()),
    );
    locator.registerFactory(
      () => GetMangaSourceUseCase(service: locator()),
    );
    locator.registerFactory(
      () => SearchMangaSourcesUseCase(service: locator()),
    );
    locator.registerFactory(
      () => GetListTagsUseCase(service: locator()),
    );
    locator.registerFactory(
      () => SearchMangaOnMangaDexUseCase(
        mangaService: locator(),
        authorService: locator(),
        coverArtService: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchChapterOnMangaDexUseCase(
        chapterRepository: locator(),
      ),
    );
    locator.registerFactory(
      () => GetChapterOnMangaDexUseCase(
        chapterRepository: locator(),
        atHomeRepository: locator(),
      ),
    );
    locator.registerFactory(
      () => GetMangaOnMangaDexUseCase(
        mangaService: locator(),
        authorService: locator(),
        coverArtService: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchMangaUseCase(
        searchMangaOnMangaDexUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchChapterUseCase(
        searchChapterOnMangaDexUseCase: locator(),
        listenLocaleUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => GetMangaUseCase(
        getMangaOnMangaDexUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => GetChapterUseCase(
        getChapterOnMangaDexUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => AddToLibraryUseCase(
        mangaLibraryServiceFirebase: locator(),
      ),
    );

    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }
}
