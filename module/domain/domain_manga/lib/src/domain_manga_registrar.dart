import 'dart:developer';

import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/download_chapter_manager_v2.dart';
import 'manager/library_manager.dart';
import 'manager/manga_source_manager.dart';
import 'use_case/chapter/download_chapter_progress_use_case.dart';
import 'use_case/chapter/download_chapter_use_case.dart';
import 'use_case/chapter/get_chapter_on_manga_dex_use_case.dart';
import 'use_case/chapter/get_chapter_use_case.dart';
import 'use_case/chapter/listen_active_download_use_case.dart';
import 'use_case/chapter/search_chapter_on_manga_dex_use_case.dart';
import 'use_case/chapter/search_chapter_use_case.dart';
import 'use_case/library/add_to_library_use_case.dart';
import 'use_case/library/get_manga_from_library_use_case.dart';
import 'use_case/library/listen_manga_from_library_use_case.dart';
import 'use_case/library/remove_from_library_use_case.dart';
import 'use_case/manga/get_manga_on_mangadex_use_case.dart';
import 'use_case/manga/get_manga_use_case.dart';
import 'use_case/manga/search_manga_on_mangadex_use_case.dart';
import 'use_case/manga/search_manga_use_case.dart';
import 'use_case/manga_source/get_manga_source_use_case.dart';
import 'use_case/manga_source/get_manga_sources_use_case.dart';
import 'use_case/manga_source/listen_manga_source_use_case.dart';
import 'use_case/manga_tags/get_list_tags_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString(), time: DateTime.now());

    // manga dex services
    locator.registerFactory(() => MangaService(locator()));
    locator.registerFactory(() => ChapterService(locator()));
    locator.registerFactory(() => AtHomeService(locator()));
    locator.registerFactory(() => AuthorService(locator()));
    locator.registerFactory(() => CoverArtService(locator()));

    // manga dex repositories
    locator.registerFactory(() => AtHomeRepository(service: locator()));
    locator.registerFactory(() => MangaRepository(service: locator()));
    locator.registerFactory(
      () => ChapterRepository(
        mangaService: locator(),
        chapterService: locator(),
      ),
    );
    locator.registerFactory(() => AuthorRepository(service: locator()));
    locator.registerFactory(() => CoverRepository(service: locator()));

    locator.registerFactory(
      () => GetListTagsUseCase(service: locator()),
    );
    locator.registerFactory(
      () => SearchMangaOnMangaDexUseCase(
        mangaService: locator(),
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
        getMangaFromLibraryUseCase: locator(),
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
    locator.registerFactory(
      () => RemoveFromLibraryUseCase(
        mangaLibraryServiceFirebase: locator(),
      ),
    );

    locator.registerSingleton(
      LibraryManager(
        mangaLibraryServiceFirebase: locator(),
        listenAuthUseCase: locator(),
      ),
    );
    locator.alias<GetMangaFromLibraryUseCase, LibraryManager>();
    locator.alias<ListenMangaFromLibraryUseCase, LibraryManager>();

    locator.registerSingleton(
      MangaSourceManager(
        mangaSourceServiceFirebase: locator(),
      ),
    );
    locator.alias<GetMangaSourcesUseCase, MangaSourceManager>();
    locator.alias<ListenMangaSourceUseCase, MangaSourceManager>();
    locator.alias<GetMangaSourceUseCase, MangaSourceManager>();

    locator.registerSingleton(
      await DownloadChapterManagerV2.create(
        cacheManager: locator(),
        getChapterUseCase: () => locator(),
      ),
      dispose: (instance) => instance.dispose(),
    );
    locator.alias<DownloadChapterUseCase, DownloadChapterManagerV2>();
    locator.alias<ListenActiveDownloadUseCase, DownloadChapterManagerV2>();
    locator.alias<DownloadChapterProgressUseCase, DownloadChapterManagerV2>();

    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }
}
