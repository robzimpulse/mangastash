import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/custom_cache_manager/custom_cache_manager.dart';
import 'manager/path_manager.dart';
import 'storage/shared_preferences_storage.dart';
import 'storage/storage.dart';
import 'use_case/get_root_path_use_case.dart';
import 'use_case/listen_backup_path_use_case.dart';
import 'use_case/listen_download_path_use_case.dart';
import 'use_case/set_backup_path_use_case.dart';
import 'use_case/set_download_path_use_case.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();
    final MeasureProcessUseCase measurement = locator();

    void logger(
      message, {
      error,
      extra,
      level,
      name,
      sequenceNumber,
      stackTrace,
      time,
      zone,
    }) {
      return log.log(
        message,
        name: name ?? runtimeType.toString(),
        sequenceNumber: sequenceNumber,
        level: level ?? 0,
        zone: zone,
        error: error,
        stackTrace: stackTrace,
        time: time,
        extra: extra,
      );
    }

    await measurement.execute(() async {
      locator.registerSingleton(
        AppDatabase(logger: logger),
        dispose: (e) => e.close(),
      );
      locator.registerSingleton(DatabaseViewer());
      locator.registerFactory(() => MangaDao(locator()));
      locator.registerFactory(() => ChapterDao(locator()));
      locator.registerFactory(() => LibraryDao(locator()));
      locator.registerFactory(() => JobDao(locator()));
      locator.registerFactory(() => CacheDao(locator()));
      locator.registerFactory(() => HistoryDao(locator()));
      locator.registerFactory(() => TagDao(locator()));

      locator.registerSingleton(await SharedPreferencesStorage.create());
      locator.alias<Storage, SharedPreferencesStorage>();

      locator.registerSingleton(await PathManager.create(storage: locator()));
      locator.alias<GetRootPathUseCase, PathManager>();
      locator.alias<ListenDownloadPathUseCase, PathManager>();
      locator.alias<SetDownloadPathUseCase, PathManager>();
      locator.alias<ListenBackupPathUseCase, PathManager>();
      locator.alias<SetBackupPathUseCase, PathManager>();

      locator.registerSingleton(
        CustomCacheManager(dio: locator(), dao: () => locator()),
        dispose: (e) => e.dispose(),
      );
      locator.alias<BaseCacheManager, CustomCacheManager>();
    });

    log.log(
      'Finish Register ${runtimeType.toString()}',
      name: 'Services',
      extra: {'duration': measurement.elapsed},
    );
  }
}
