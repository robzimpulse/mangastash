import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/download_progress_manager.dart';
import 'manager/file_download_manager.dart';
import 'manager/global_options_manager.dart';
import 'manager/headless_webview_manager.dart';
import 'manager/history_manager.dart';
import 'manager/job_manager.dart';
import 'manager/library_manager.dart';
import 'manager/manga_source_manager.dart';
import 'use_case/chapter/crawl_url_use_case.dart';
import 'use_case/chapter/download_chapter_use_case.dart';
import 'use_case/chapter/get_chapter_on_manga_dex_use_case.dart';
import 'use_case/chapter/get_chapter_use_case.dart';
import 'use_case/chapter/listen_download_progress_use_case.dart';
import 'use_case/chapter/prefetch_chapter_use_case.dart';
import 'use_case/chapter/search_chapter_on_manga_dex_use_case.dart';
import 'use_case/chapter/search_chapter_use_case.dart';
import 'use_case/chapter/update_chapter_last_read_at_use_case.dart';
import 'use_case/library/add_to_library_use_case.dart';
import 'use_case/library/get_manga_from_library_use_case.dart';
import 'use_case/library/listen_manga_from_library_use_case.dart';
import 'use_case/library/listen_prefetch_use_case.dart';
import 'use_case/library/listen_read_history_use_case.dart';
import 'use_case/library/remove_from_library_use_case.dart';
import 'use_case/manga/download_manga_use_case.dart';
import 'use_case/manga/get_manga_on_mangadex_use_case.dart';
import 'use_case/manga/get_manga_use_case.dart';
import 'use_case/manga/listen_search_parameter_use_case.dart';
import 'use_case/manga/prefetch_manga_use_case.dart';
import 'use_case/manga/search_manga_on_mangadex_use_case.dart';
import 'use_case/manga/search_manga_use_case.dart';
import 'use_case/manga/update_search_parameter_use_case.dart';
import 'use_case/manga_source/get_manga_source_use_case.dart';
import 'use_case/manga_source/get_manga_sources_use_case.dart';
import 'use_case/manga_source/listen_manga_source_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();
    final MeasureProcessUseCase measurement = locator();

    await measurement.execute(() async {
      locator.registerFactory(() => MangaSourceServiceFirebase(app: locator()));

      locator.registerSingleton(await FileDownloadManager.create(log: log));

      locator.registerSingleton(
        GlobalOptionsManager(listenLocaleUseCase: locator()),
        dispose: (e) => e.dispose(),
      );
      locator.alias<ListenSearchParameterUseCase, GlobalOptionsManager>();
      locator.alias<UpdateSearchParameterUseCase, GlobalOptionsManager>();

      locator.registerSingleton(
        JobManager(
          log: log,
          jobDao: locator(),
          cacheManager: locator(),
          getChapterUseCase: () => locator(),
          getMangaUseCase: () => locator(),
          searchChapterUseCase: () => locator(),
          fileDownloader: locator(),
        ),
        dispose: (e) => e.dispose(),
      );
      locator.alias<PrefetchMangaUseCase, JobManager>();
      locator.alias<PrefetchChapterUseCase, JobManager>();
      locator.alias<ListenPrefetchUseCase, JobManager>();
      locator.alias<DownloadChapterUseCase, JobManager>();
      locator.alias<DownloadMangaUseCase, JobManager>();

      locator.registerSingleton(HistoryManager(historyDao: locator()));
      locator.alias<ListenReadHistoryUseCase, HistoryManager>();

      locator.registerSingleton(
        HeadlessWebviewManager(log: log, cacheManager: locator()),
        dispose: (e) => e.dispose(),
      );

      locator.registerSingleton(
        await DownloadProgressManager.create(
          fileDownloader: locator(),
          cacheManager: locator(),
          log: log,
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
        () => CrawlUrlUseCase(
          logBox: locator(),
          cacheManager: locator(),
        ),
      );
      locator.registerFactory(
        () => SearchMangaOnMangaDexUseCase(
          logBox: locator(),
          mangaRepository: locator(),
          mangaDao: locator(),
        ),
      );
      locator.registerFactory(
        () => SearchChapterOnMangaDexUseCase(
          chapterRepository: locator(),
          chapterDao: locator(),
          logBox: locator(),
        ),
      );
      locator.registerFactory(
        () => GetChapterOnMangaDexUseCase(
          chapterRepository: locator(),
          atHomeRepository: locator(),
          chapterDao: locator(),
          logBox: locator(),
        ),
      );
      locator.registerFactory(
        () => GetMangaOnMangaDexUseCase(
          logBox: locator(),
          mangaService: locator(),
          mangaDao: locator(),
        ),
      );
      locator.registerFactory(
        () => SearchMangaUseCase(
          searchMangaOnMangaDexUseCase: locator(),
          logBox: locator(),
          webview: locator(),
          mangaDao: locator(),
        ),
      );
      locator.registerFactory(
        () => SearchChapterUseCase(
          searchChapterOnMangaDexUseCase: locator(),
          logBox: locator(),
          webview: locator(),
          mangaDao: locator(),
          chapterDao: locator(),
        ),
      );
      locator.registerFactory(
        () => GetMangaUseCase(
          getMangaOnMangaDexUseCase: locator(),
          logBox: locator(),
          webview: locator(),
          mangaDao: locator(),
        ),
      );
      locator.registerFactory(
        () => GetChapterUseCase(
          getChapterOnMangaDexUseCase: locator(),
          logBox: locator(),
          webview: locator(),
          chapterDao: locator(),
        ),
      );
      locator.registerFactory(
        () => AddToLibraryUseCase(
          libraryDao: locator(),
        ),
      );
      locator.registerFactory(
        () => RemoveFromLibraryUseCase(
          libraryDao: locator(),
        ),
      );
      locator.registerFactory(
        () => UpdateChapterLastReadAtUseCase(
          chapterDao: locator(),
          logBox: locator(),
        ),
      );

      locator.registerSingleton(
        LibraryManager(
          libraryDao: locator(),
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
    });

    log.log(
      'Finish Register ${runtimeType.toString()}',
      name: 'Services',
      extra: {'duration': measurement.elapsed},
    );
  }
}
