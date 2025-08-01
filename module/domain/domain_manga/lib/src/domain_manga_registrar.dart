import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/global_options_manager.dart';
import 'manager/headless_webview_manager.dart';
import 'manager/history_manager.dart';
import 'manager/job_manager.dart';
import 'manager/library_manager.dart';
import 'use_case/chapter/get_all_chapter_use_case.dart';
import 'use_case/chapter/get_chapter_use_case.dart';
import 'use_case/chapter/search_chapter_use_case.dart';
import 'use_case/history/listen_read_history_use_case.dart';
import 'use_case/history/listen_unread_history_use_case.dart';
import 'use_case/history/update_chapter_last_read_at_use_case.dart';
import 'use_case/library/add_to_library_use_case.dart';
import 'use_case/library/get_manga_from_library_use_case.dart';
import 'use_case/library/listen_manga_from_library_use_case.dart';
import 'use_case/library/remove_from_library_use_case.dart';
import 'use_case/manga/get_manga_from_url_use_case.dart';
import 'use_case/manga/get_manga_use_case.dart';
import 'use_case/manga/search_manga_use_case.dart';
import 'use_case/parameter/listen_search_parameter_use_case.dart';
import 'use_case/parameter/update_search_parameter_use_case.dart';
import 'use_case/prefetch/listen_prefetch_use_case.dart';
import 'use_case/prefetch/prefetch_chapter_use_case.dart';
import 'use_case/prefetch/prefetch_manga_use_case.dart';
import 'use_case/source/listen_sources_use_case.dart';
import 'use_case/source/update_sources_use_case.dart';
import 'use_case/tags/get_tags_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'start': DateTime.timestamp().toIso8601String()},
    );

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
        listenSearchParameterUseCase: locator(),
      ),
      dispose: (e) => e.dispose(),
    );
    locator.alias<PrefetchMangaUseCase, JobManager>();
    locator.alias<PrefetchChapterUseCase, JobManager>();
    locator.alias<ListenPrefetchUseCase, JobManager>();

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
      () =>
          ChapterRepository(mangaService: locator(), chapterService: locator()),
    );
    locator.registerFactory(() => AuthorRepository(service: locator()));
    locator.registerFactory(() => CoverRepository(service: locator()));

    locator.registerFactory(
      () => SearchMangaUseCase(
        logBox: locator(),
        webview: locator(),
        mangaDao: locator(),
        mangaRepository: locator(),
      ),
    );
    locator.registerFactory(
      () => SearchChapterUseCase(
        logBox: locator(),
        webview: locator(),
        mangaDao: locator(),
        chapterDao: locator(),
        chapterRepository: locator(),
      ),
    );
    locator.registerFactory(
      () => GetAllChapterUseCase(searchChapterUseCase: locator()),
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
      () => UpdateChapterLastReadAtUseCase(
        chapterDao: locator(),
        logBox: locator(),
      ),
    );
    locator.registerFactory(
      () => GetTagsUseCase(
        webview: locator(),
        tagDao: locator(),
        logBox: locator(),
        mangaService: locator(),
      ),
    );

    locator.registerSingleton(LibraryManager(libraryDao: locator()));
    locator.alias<GetMangaFromLibraryUseCase, LibraryManager>();
    locator.alias<ListenMangaFromLibraryUseCase, LibraryManager>();

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}
