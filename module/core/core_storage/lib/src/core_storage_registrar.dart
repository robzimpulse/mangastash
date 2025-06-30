import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/custom_cache_manager/custom_cache_manager.dart';
import 'storage/shared_preferences_storage.dart';
import 'storage/storage.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();
    final MeasureProcessUseCase measurement = locator();

    await measurement.execute(() async {
      locator.registerSingleton(
        AppDatabase(),
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

      // TODO: @robzimpulse - broken on web
      // locator.registerSingleton(await PathManager.create(storage: locator()));
      // locator.alias<GetRootPathUseCase, PathManager>();
      // locator.alias<ListenDownloadPathUseCase, PathManager>();
      // locator.alias<SetDownloadPathUseCase, PathManager>();
      // locator.alias<ListenBackupPathUseCase, PathManager>();
      // locator.alias<SetBackupPathUseCase, PathManager>();

      locator.registerSingleton(
        CustomCacheManager(dio: () => locator(), dao: () => locator()),
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
