import 'package:core_analytics/core_analytics.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:service_locator/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manager/path_manager/path_manager.dart';
import 'manager/storage_manager/file_service/custom_file_service.dart';
import 'manager/storage_manager/images_cache_manager.dart';
import 'manager/storage_manager/storage_manager.dart';
import 'use_case/file_picker_use_case.dart';
import 'use_case/file_saver_use_case.dart';
import 'use_case/get_backup_path_use_case.dart';
import 'use_case/get_download_path_use_case.dart';
import 'use_case/get_root_path_use_case.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp();

    locator.registerFactory(() => Executor(interceptor: locator()));
    locator.registerLazySingleton(
      () => AppDatabase(executor: locator()),
      dispose: (e) => e.close(),
    );
    locator.registerLazySingleton(() => DatabaseViewer());
    locator.registerFactory(() => FileDao(locator()));
    locator.registerFactory(() => MangaDao(locator()));
    locator.registerFactory(() => ChapterDao(locator()));
    locator.registerFactory(() => LibraryDao(locator()));
    locator.registerFactory(() => JobDao(locator()));
    locator.registerFactory(() => HistoryDao(locator()));
    locator.registerFactory(() => TagDao(locator()));
    locator.registerFactory(() => DiagnosticDao(locator()));

    locator.registerLazySingleton(() => SharedPreferencesAsync());
    locator.registerLazySingletonAsync(() => PathManager.create());
    locator.alias<GetRootPathUseCase, PathManager>();
    locator.alias<GetBackupPathUseCase, PathManager>();
    locator.alias<GetDownloadPathUseCase, PathManager>();

    locator.registerFactory(
      () => FilePickerUseCase(getRootPathUseCase: locator()),
    );
    locator.registerFactory(
      () => FileSaverUseCase(getRootPathUseCase: locator()),
    );
    locator.registerFactory(
      () => CustomFileService(
        dio: () => locator(),
        headlessWebviewUseCase: () => locator(),
      ),
    );
    locator.registerLazySingleton(
      () => ImagesCacheManager(
        fileService: locator(),
        fileDao: locator(),
        logBox: locator(),
      ),
      dispose: (e) => e.dispose(),
    );
    locator.registerLazySingleton(
      () => ConverterCacheManager(fileService: locator()),
      dispose: (e) => e.dispose(),
    );
    locator.registerLazySingleton(
      () => HtmlCacheManager(fileService: locator()),
      dispose: (e) => e.dispose(),
    );
    locator.registerLazySingleton(
      () => SearchChapterCacheManager(fileService: locator()),
      dispose: (e) => e.dispose(),
    );
    locator.registerLazySingleton(
      () => SearchMangaCacheManager(fileService: locator()),
      dispose: (e) => e.dispose(),
    );

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
    await locator.isReady<PathManager>();
  }
}
