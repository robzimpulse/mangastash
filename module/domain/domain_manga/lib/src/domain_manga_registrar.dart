import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/download_progress_manager.dart';
import 'manager/file_download_manager.dart';
import 'manager/global_options_manager.dart';
import 'manager/headless_webview_manager.dart';
import 'manager/history_manager.dart';
import 'manager/job_manager.dart';
import 'manager/library_manager.dart';
import 'use_case/chapter/get_all_chapter_use_case.dart';
import 'use_case/chapter/get_chapter_use_case.dart';
import 'use_case/chapter/search_chapter_use_case.dart';
import 'use_case/crawl_url_use_case.dart';
import 'use_case/download/download_chapter_use_case.dart';
import 'use_case/download/download_manga_use_case.dart';
import 'use_case/download/listen_download_progress_use_case.dart';
import 'use_case/history/listen_read_history_use_case.dart';
import 'use_case/history/listen_unread_history_use_case.dart';
import 'use_case/history/update_chapter_last_read_at_use_case.dart';
import 'use_case/library/add_to_library_use_case.dart';
import 'use_case/library/get_manga_from_library_use_case.dart';
import 'use_case/library/listen_manga_from_library_use_case.dart';
import 'use_case/library/remove_from_library_use_case.dart';
import 'use_case/manga/get_manga_on_mangadex_use_case.dart';
import 'use_case/manga/get_manga_use_case.dart';
import 'use_case/manga/search_manga_on_mangadex_use_case.dart';
import 'use_case/manga/search_manga_use_case.dart';
import 'use_case/parameter/listen_search_parameter_use_case.dart';
import 'use_case/parameter/update_search_parameter_use_case.dart';
import 'use_case/prefetch/listen_prefetch_use_case.dart';
import 'use_case/prefetch/prefetch_chapter_use_case.dart';
import 'use_case/prefetch/prefetch_manga_use_case.dart';
import 'use_case/source/listen_sources_use_case.dart';
import 'use_case/source/update_sources_use_case.dart';
import 'use_case/tags/get_tags_on_mangadex_use_case.dart';
import 'use_case/tags/get_tags_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();
    final MeasureProcessUseCase measurement = locator();

    await measurement.execute(() async {
      if (!kIsWeb) {
        locator.registerSingleton(await FileDownloadManager.create(log: log));
      }

      locator.registerSingleton(
        await DownloadProgressManager.create(
          fileDownloader: locator.getOrNull(),
          cacheManager: locator(),
          log: log,
        ),
      );
      locator.alias<ListenDownloadProgressUseCase, DownloadProgressManager>();

      locator.registerSingleton(
        GlobalOptionsManager(storage: locator()),
        dispose: (e) => e.dispose(),
      );
      locator.alias<ListenSearchParameterUseCase, GlobalOptionsManager>();
      locator.alias<UpdateSearchParameterUseCase, GlobalOptionsManager>();
      locator.alias<ListenSourcesUseCase, GlobalOptionsManager>();
      locator.alias<UpdateSourcesUseCase, GlobalOptionsManager>();

      locator.registerSingleton(
        JobManager(
          log: log,
          jobDao: locator(),
          cacheManager: locator(),
          getChapterUseCase: () => locator(),
          getMangaUseCase: () => locator(),
          getAllChapterUseCase: () => locator(),
          fileDownloader: locator.getOrNull(),
          listenSearchParameterUseCase: locator(),
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
      locator.alias<ListenUnreadHistoryUseCase, HistoryManager>();

      locator.registerSingleton(
        HeadlessWebviewManager(log: log, cacheManager: locator()),
        dispose: (e) => e.dispose(),
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
          chapterRepository: locator(),
          logBox: locator(),
          webview: locator(),
          mangaDao: locator(),
          chapterDao: locator(),
        ),
      );
      locator.registerFactory(
        () => GetAllChapterUseCase(
          searchChapterUseCase: () => locator(),
          logBox: locator(),
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
          logBox: locator(),
          webview: locator(),
          chapterDao: locator(),
          chapterRepository: locator(),
          atHomeRepository: locator(),
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

      locator.registerSingleton(LibraryManager(libraryDao: locator()));
      locator.alias<GetMangaFromLibraryUseCase, LibraryManager>();
      locator.alias<ListenMangaFromLibraryUseCase, LibraryManager>();

      locator.registerFactory(
        () => GetTagsOnMangaDexUseCase(
          mangaService: locator(),
          tagDao: locator(),
          logBox: locator(),
        ),
      );

      locator.registerFactory(
        () => GetTagsUseCase(
          getTagsOnMangaDexUseCase: locator(),
          webview: locator(),
          tagDao: locator(),
          logBox: locator(),
        ),
      );
    });

    log.log(
      'Finish Register ${runtimeType.toString()}',
      name: 'Services',
      extra: {'duration': measurement.elapsed},
    );
  }
}
