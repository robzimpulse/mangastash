import 'package:core_analytics/core_analytics.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/global_options_manager.dart';
import 'manager/history_manager.dart';
import 'manager/job_manager.dart';
import 'manager/library_manager.dart';
import 'use_case/cancel_job_use_case.dart';
import 'use_case/chapter/get_all_chapter_use_case.dart';
import 'use_case/chapter/get_chapter_use_case.dart';
import 'use_case/chapter/get_neighbour_chapter_use_case.dart';
import 'use_case/chapter/listen_downloaded_chapter_use_case.dart';
import 'use_case/chapter/search_chapter_use_case.dart';
import 'use_case/chapter/update_chapter_use_case.dart';
import 'use_case/history/listen_read_history_use_case.dart';
import 'use_case/history/listen_unread_history_use_case.dart';
import 'use_case/library/add_to_library_use_case.dart';
import 'use_case/library/get_manga_from_library_use_case.dart';
import 'use_case/library/listen_manga_from_library_use_case.dart';
import 'use_case/library/remove_from_library_use_case.dart';
import 'use_case/manga/get_manga_from_url_use_case.dart';
import 'use_case/manga/get_manga_use_case.dart';
import 'use_case/manga/search_manga_use_case.dart';
import 'use_case/parameter/listen_search_parameter_use_case.dart';
import 'use_case/parameter/listen_setting_downloaded_only_use_case.dart';
import 'use_case/parameter/update_search_parameter_use_case.dart';
import 'use_case/parameter/update_setting_downloaded_only_use_case.dart';
import 'use_case/prefetch/listen_job_use_case.dart';
import 'use_case/prefetch/listen_prefetch_chapter_config.dart';
import 'use_case/prefetch/listen_prefetch_use_case.dart';
import 'use_case/prefetch/prefetch_chapter_use_case.dart';
import 'use_case/prefetch/prefetch_manga_use_case.dart';
import 'use_case/recrawl_use_case.dart';
import 'use_case/source/listen_sources_use_case.dart';
import 'use_case/source/update_sources_use_case.dart';
import 'use_case/tags/get_tags_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp();

    locator.registerLazySingletonAsync(
      () => GlobalOptionsManager.create(storage: locator()),
    );
    locator.alias<ListenSearchParameterUseCase, GlobalOptionsManager>();
    locator.alias<UpdateSearchParameterUseCase, GlobalOptionsManager>();
    locator.alias<ListenSourcesUseCase, GlobalOptionsManager>();
    locator.alias<UpdateSourcesUseCase, GlobalOptionsManager>();
    locator.alias<ListenPrefetchChapterConfig, GlobalOptionsManager>();
    locator.alias<ListenSettingDownloadedOnlyUseCase, GlobalOptionsManager>();
    locator.alias<UpdateSettingDownloadedOnlyUseCase, GlobalOptionsManager>();

    locator.registerLazySingleton(
      () => JobManager(
        log: locator(),
        jobDao: locator(),
        fileDao: locator(),
        getRootPathUseCase: locator(),
        manager: locator(),
        getChapterUseCase: () => locator(),
        getMangaUseCase: () => locator(),
        getAllChapterUseCase: () => locator(),
        listenSearchParameterUseCase: locator(),
      ),
      dispose: (e) => e.dispose(),
    );
    locator.alias<PrefetchMangaUseCase, JobManager>();
    locator.alias<PrefetchChapterUseCase, JobManager>();
    locator.alias<ListenPrefetchUseCase, JobManager>();
    locator.alias<ListenJobUseCase, JobManager>();
    locator.alias<CancelJobUseCase, JobManager>();

    locator.registerLazySingleton(() => HistoryManager(historyDao: locator()));
    locator.alias<ListenReadHistoryUseCase, HistoryManager>();
    locator.alias<ListenUnreadHistoryUseCase, HistoryManager>();

    // manga dex services
    locator.registerFactory(() => MangaService(locator()));
    locator.registerFactory(() => ChapterService(locator()));
    locator.registerFactory(() => AtHomeService(locator()));
    locator.registerFactory(() => AuthorService(locator()));
    locator.registerFactory(() => CoverArtService(locator()));

    // manga dex repositories
    locator.registerFactory(() => AtHomeRepository(service: locator()));
    locator.registerFactory(() => MangaRepository(service: locator()));
    locator.registerFactory(() {
      return ChapterRepository(
        mangaService: locator(),
        chapterService: locator(),
      );
    });
    locator.registerFactory(() => AuthorRepository(service: locator()));
    locator.registerFactory(() => CoverRepository(service: locator()));

    locator.registerFactory(
      () => SearchMangaUseCase(
        logBox: locator(),
        webview: locator(),
        mangaDao: locator(),
        mangaRepository: locator(),
        htmlCacheManager: locator(),
        searchMangaCacheManager: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchChapterUseCase(
        logBox: locator(),
        webview: locator(),
        mangaDao: locator(),
        chapterDao: locator(),
        chapterRepository: locator(),
        searchChapterCacheManager: locator(),
        converterCacheManager: locator(),
        htmlCacheManager: locator(),
      ),
    );
    locator.registerFactory(
      () => GetAllChapterUseCase(searchChapterUseCase: locator()),
    );
    locator.registerFactory(
      () => GetNeighbourChapterUseCase(chapterDao: locator()),
    );
    locator.registerFactory(
      () => GetMangaUseCase(
        logBox: locator(),
        webview: locator(),
        mangaDao: locator(),
        mangaService: locator(),
      ),
    );
    locator.registerFactory(
      () => GetMangaFromUrlUseCase(
        webview: locator(),
        mangaDao: locator(),
        logBox: locator(),
      ),
    );
    locator.registerFactory(
      () => GetChapterUseCase(
        logBox: locator(),
        webview: locator(),
        chapterDao: locator(),
        atHomeRepository: locator(),
        chapterRepository: locator(),
      ),
    );
    locator.registerFactory(() => AddToLibraryUseCase(libraryDao: locator()));
    locator.registerFactory(
      () => RemoveFromLibraryUseCase(libraryDao: locator()),
    );
    locator.registerFactory(
      () => UpdateChapterUseCase(chapterDao: locator(), logBox: locator()),
    );
    locator.registerFactory(
      () => GetTagsUseCase(
        webview: locator(),
        tagDao: locator(),
        logBox: locator(),
        mangaService: locator(),
      ),
    );
    locator.registerFactory(
      () => RecrawlUseCase(logBox: locator(), htmlCacheManager: locator()),
    );

    locator.registerFactory(
      () => ListenDownloadedChapterUseCase(chapterDao: locator()),
    );

    locator.registerLazySingleton(
      () => LibraryManager(libraryDao: locator()),
      dispose: (e) => e.dispose(),
    );
    locator.alias<GetMangaFromLibraryUseCase, LibraryManager>();
    locator.alias<ListenMangaFromLibraryUseCase, LibraryManager>();

    final end = DateTime.timestamp();

    locator<LogBox>().log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {
        'start': start.toIso8601String(),
        'finish': end.toIso8601String(),
        'duration': end.difference(start).toString(),
      },
    );
  }

  @override
  Future<void> allReady(ServiceLocator locator) async {
    await locator.isReady<GlobalOptionsManager>();
  }
}
