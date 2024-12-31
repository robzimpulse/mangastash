import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/active_download_manager.dart';
import 'manager/file_download_manager.dart';
import 'manager/library_manager.dart';
import 'manager/manga_source_manager.dart';
import 'use_case/chapter/download_chapter_use_case.dart';
import 'use_case/chapter/get_active_download_use_case.dart';
import 'use_case/chapter/get_chapter_on_manga_dex_use_case.dart';
import 'use_case/chapter/get_chapter_use_case.dart';
import 'use_case/chapter/get_download_progress_use_case.dart';
import 'use_case/chapter/listen_download_progress_use_case.dart';
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
    final LogBox log = locator();
    log.log(
      'start register',
      name: runtimeType.toString(),
      time: DateTime.now(),
    );

    locator.registerSingleton(await FileDownloadManager.create(log: log));
    locator.registerSingleton(
      await ActiveDownloadManager.create(fileDownloader: locator(), log: log),
    );
    locator.alias<ListenDownloadProgressUseCase, ActiveDownloadManager>();


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
        log: locator(),
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
    locator.registerFactory(
      () => DownloadChapterUseCase(
        fileDownloader: locator(),
        getChapterUseCase: locator(),
        log: log,
      ),
    );
    locator.registerFactory(
      () => GetActiveDownloadUseCase(fileDownloader: locator()),
    );
    locator.registerFactory(
      () => GetDownloadProgressUseCase(fileDownloader: locator()),
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

    // locator.registerSingleton(
    //   await DownloadChapterManager.create(
    //     log: locator(),
    //     cacheManager: locator(),
    //     getChapterUseCase: () => locator(),
    //   ),
    //   dispose: (instance) => instance.dispose(),
    // );
    // locator.alias<DownloadChapterUseCase, DownloadChapterManager>();
    // locator.alias<ListenActiveDownloadUseCase, DownloadChapterManager>();
    // locator.alias<DownloadChapterProgressUseCase, DownloadChapterManager>();

    log.log(
      'finish register',
      name: runtimeType.toString(),
      time: DateTime.now(),
    );
  }
}
