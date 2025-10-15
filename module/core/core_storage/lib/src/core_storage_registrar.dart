import 'package:core_analytics/core_analytics.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:service_locator/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manager/storage_manager/storage_manager.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp();

    locator.registerFactory(() => const Executor());
    locator.registerLazySingleton(
      () => AppDatabase(executor: locator<Executor>().build()),
      dispose: (e) => e.close(),
    );
    locator.registerLazySingleton(() => DatabaseViewer());
    locator.registerFactory(() => MangaDao(locator()));
    locator.registerFactory(() => ChapterDao(locator()));
    locator.registerFactory(() => LibraryDao(locator()));
    locator.registerFactory(() => JobDao(locator()));
    locator.registerFactory(() => HistoryDao(locator()));
    locator.registerFactory(() => TagDao(locator()));

    locator.registerLazySingletonAsync(() => SharedPreferences.getInstance());
    locator.registerLazySingleton(
      () => StorageManager(dio: () => locator()),
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
    await locator.isReady<SharedPreferences>();
  }
}
