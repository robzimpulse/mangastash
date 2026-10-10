// DomainMangaRegistrar: registers domain_manga's managers, MangaDex
// services/repositories and use cases into the ServiceLocator.
//
// Issue #115: SourceRegistry (the scripted sources, from bundled assets plus
// the user's `source_script_tables` rows) is an async lazy singleton built
// from SourceScriptDao (CoreStorageRegistrar) and RunSourceScriptUseCase
// (CoreNetworkRegistrar) — both registrars must run before this one. It is
// bound to the static `Sources` facade for widgets without locator access.
// GlobalOptionsManager awaits it; [allReady] awaits both.
//
// Usage: `await locator.registerRegistrar(DomainMangaRegistrar())` after the
// core registrars (see WrapperScreen in lib/main.dart), then
// `await locator.allReady()`.
import 'package:core_analytics/core_analytics.dart';
import 'package:flutter/services.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/global_options_manager.dart';
import 'manager/history_manager.dart';
import 'manager/job_manager.dart';
import 'manager/library_manager.dart';
import 'manager/source_registry.dart';
import 'sources/sources.dart';
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
import 'use_case/library/listen_manga_from_library_use_case.dart';
import 'use_case/library/remove_from_library_use_case.dart';
import 'use_case/manga/get_manga_from_url_use_case.dart';
import 'use_case/manga/get_manga_use_case.dart';
import 'use_case/manga/search_manga_use_case.dart';
import 'use_case/parameter/listen_search_parameter_use_case.dart';
import 'use_case/parameter/listen_setting_downloaded_only_use_case.dart';
import 'use_case/parameter/listen_setting_incognito_use_case.dart';
import 'use_case/parameter/update_search_parameter_use_case.dart';
import 'use_case/parameter/update_setting_downloaded_only_use_case.dart';
import 'use_case/parameter/update_setting_incognito_use_case.dart';
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
      () async {
        final registry = await SourceRegistry.create(
          dao: locator(),
          runner: locator(),
          loadAsset: rootBundle.loadString,
        );
        Sources.bind(registry);
        return registry;
      },
      dispose: (registry) async {
        Sources.unbind(registry);
        await registry.close();
      },
    );
    locator.registerLazySingletonAsync(
      () async => GlobalOptionsManager.create(
        storage: locator(),
        registry: await locator.getAsync<SourceRegistry>(),
      ),
      dispose: (e) => e.dispose(),
    );
    locator.alias<ListenSearchParameterUseCase, GlobalOptionsManager>();
    locator.alias<UpdateSearchParameterUseCase, GlobalOptionsManager>();
    locator.alias<ListenSourcesUseCase, GlobalOptionsManager>();
    locator.alias<UpdateSourcesUseCase, GlobalOptionsManager>();
    locator.alias<ListenPrefetchChapterConfig, GlobalOptionsManager>();
    locator.alias<ListenSettingDownloadedOnlyUseCase, GlobalOptionsManager>();
    locator.alias<UpdateSettingDownloadedOnlyUseCase, GlobalOptionsManager>();
    locator.alias<ListenSettingIncognitoUseCase, GlobalOptionsManager>();
    locator.alias<UpdateSettingIncognitoUseCase, GlobalOptionsManager>();

    locator.registerLazySingleton(
      () => JobManager(
        log: locator(),
        jobDao: locator(),
        manager: locator(),
        getChapterUseCase: () => locator(),
        getMangaUseCase: () => locator(),
        getAllChapterUseCase: () => locator(),
        listenSearchParameterUseCase: locator(),
        registry: locator(),
      ),
      dispose: (e) => e.dispose(),
    );
    locator.alias<PrefetchMangaUseCase, JobManager>();
    locator.alias<PrefetchChapterUseCase, JobManager>();
    locator.alias<ListenPrefetchUseCase, JobManager>();
    locator.alias<ListenJobUseCase, JobManager>();
    locator.alias<CancelJobUseCase, JobManager>();

    locator.registerLazySingleton(
      () => HistoryManager(
        historyDao: locator(),
        listenSourcesUseCase: locator(),
      ),
    );
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
        runner: locator(),
        registry: locator(),
        mangaDao: locator(),
        mangaRepository: locator(),
        searchMangaCacheManager: locator(),
        converterCacheManager: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchChapterUseCase(
        logBox: locator(),
        runner: locator(),
        registry: locator(),
        mangaDao: locator(),
        chapterDao: locator(),
        chapterRepository: locator(),
        searchChapterCacheManager: locator(),
        converterCacheManager: locator(),
      ),
    );
    locator.registerFactory(
      () => GetAllChapterUseCase(
        searchChapterUseCase: locator(),
        logBox: locator(),
      ),
    );
    locator.registerFactory(
      () => GetNeighbourChapterUseCase(chapterDao: locator()),
    );
    locator.registerFactory(
      () => GetMangaUseCase(
        logBox: locator(),
        runner: locator(),
        mangaDao: locator(),
        mangaService: locator(),
        converterCacheManager: locator(),
      ),
    );
    locator.registerFactory(
      () => GetMangaFromUrlUseCase(
        runner: locator(),
        mangaDao: locator(),
        logBox: locator(),
        converterCacheManager: locator(),
      ),
    );
    locator.registerFactory(
      () => GetChapterUseCase(
        logBox: locator(),
        runner: locator(),
        chapterDao: locator(),
        atHomeRepository: locator(),
        chapterRepository: locator(),
      ),
    );
    locator.registerFactory(
      () => AddToLibraryUseCase(
        libraryDao: locator(),
        listenSourcesUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => RemoveFromLibraryUseCase(
        libraryDao: locator(),
        listenSourcesUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => UpdateChapterUseCase(
        chapterDao: locator(),
        logBox: locator(),
        listenSettingIncognitoUseCase: locator(),
      ),
    );
    locator.registerFactory(
      () => GetTagsUseCase(
        tagDao: locator(),
        logBox: locator(),
        mangaService: locator(),
      ),
    );
    locator.registerFactory(
      () => RecrawlUseCase(logBox: locator(), runner: locator()),
    );

    locator.registerFactory(
      () => ListenDownloadedChapterUseCase(chapterDao: locator()),
    );

    locator.registerLazySingleton(
      () => LibraryManager(
        libraryDao: locator(),
        listenSourcesUseCase: locator(),
      ),
    );
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
    await locator.isReady<SourceRegistry>();
    await locator.isReady<GlobalOptionsManager>();
  }
}
