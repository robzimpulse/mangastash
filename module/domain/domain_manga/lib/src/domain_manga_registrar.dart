import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/download_progress_manager.dart';
import 'manager/file_download_manager.dart';
import 'manager/headless_webview_manager.dart';
import 'manager/library_manager.dart';
import 'manager/manga_source_manager.dart';
import 'use_case/chapter/download_chapter_use_case.dart';
import 'use_case/chapter/get_chapter_on_manga_clash_use_case.dart';
import 'use_case/chapter/get_chapter_on_manga_dex_use_case.dart';
import 'use_case/chapter/get_chapter_use_case.dart';
import 'use_case/chapter/listen_download_progress_use_case.dart';
import 'use_case/chapter/search_chapter_on_manga_clash_use_case.dart';
import 'use_case/chapter/search_chapter_on_manga_dex_use_case.dart';
import 'use_case/chapter/search_chapter_use_case.dart';
import 'use_case/library/add_to_library_use_case.dart';
import 'use_case/library/get_manga_from_library_use_case.dart';
import 'use_case/library/listen_manga_from_library_use_case.dart';
import 'use_case/library/remove_from_library_use_case.dart';
import 'use_case/manga/get_manga_on_asura_scan_use_case.dart';
import 'use_case/manga/get_manga_on_manga_clash_use_case.dart';
import 'use_case/manga/get_manga_on_mangadex_use_case.dart';
import 'use_case/manga/get_manga_use_case.dart';
import 'use_case/manga/search_manga_on_asura_scan_use_case.dart';
import 'use_case/manga/search_manga_on_manga_clash_use_case.dart';
import 'use_case/manga/search_manga_on_mangadex_use_case.dart';
import 'use_case/manga/search_manga_use_case.dart';
import 'use_case/manga_source/get_manga_source_use_case.dart';
import 'use_case/manga_source/get_manga_sources_use_case.dart';
import 'use_case/manga_source/listen_manga_source_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();
    log.log('start register', name: runtimeType.toString());

    locator.registerSingleton(
      await HeadlessWebviewManager.create(log: log, cacheManager: locator()),
      dispose: (e) => e.dispose(),
    );

    locator.registerSingleton(await FileDownloadManager.create(log: log));
    locator.registerSingleton(
      await DownloadProgressManager.create(
        fileDownloader: locator(),
        log: log,
        cacheManager: locator(),
      ),
    );
    locator.alias<ListenDownloadProgressUseCase, DownloadProgressManager>();

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
      () => SearchMangaOnMangaDexUseCase(
        mangaService: locator(),
        log: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchChapterOnMangaDexUseCase(
        chapterRepository: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchMangaOnMangaClashUseCaseUseCase(
        log: log,
        webview: locator(),
        mangaServiceFirebase: locator(),
        mangaTagServiceFirebase: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchChapterOnMangaClashUseCase(
        mangaServiceFirebase: locator(),
        webview: locator(),
        mangaChapterServiceFirebase: locator(),
      ),
    );
    locator.registerFactory(
      () => GetChapterOnMangaDexUseCase(
        chapterRepository: locator(),
        atHomeRepository: locator(),
      ),
    );
    locator.registerFactory(
      () => GetChapterOnMangaClashUseCase(
        mangaChapterServiceFirebase: locator(),
        webview: locator(),
      ),
    );
    locator.registerFactory(
      () => GetMangaOnMangaDexUseCase(
        mangaService: locator(),
      ),
    );
    locator.registerFactory(
      () => GetMangaOnMangaClashUseCase(
        mangaServiceFirebase: locator(),
        webview: locator(),
      ),
    );
    locator.registerFactory(
      () => GetMangaOnAsuraScanUseCase(
        mangaServiceFirebase: locator(),
        webview: locator(),
        mangaTagServiceFirebase: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchMangaOnAsuraScanUseCase(
        webview: locator(),
        mangaServiceFirebase: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchMangaUseCase(
        searchMangaOnMangaDexUseCase: locator(),
        searchMangaOnMangaClashUseCaseUseCase: locator(),
        searchMangaOnAsuraScanUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchChapterUseCase(
        searchChapterOnMangaDexUseCase: locator(),
        listenLocaleUseCase: locator(),
        searchChapterOnMangaClashUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => GetMangaUseCase(
        getMangaOnAsuraScanUseCase: locator(),
        getMangaOnMangaDexUseCase: locator(),
        getMangaOnMangaClashUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => GetChapterUseCase(
        getChapterOnMangaDexUseCase: locator(),
        getChapterOnMangaClashUseCase: locator(),
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
    locator.registerFactory(
      () => DownloadChapterUseCase(
        fileDownloader: locator(),
        getChapterUseCase: locator(),
        log: log,
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

    log.log('finish register', name: runtimeType.toString());
  }
}
