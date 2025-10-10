import 'package:core_analytics/core_analytics.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:service_locator/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manager/storage_manager/storage_manager.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp().toIso8601String();

    final LogBox log = locator();

    locator.registerFactory(() => const Executor().build());
    locator.registerLazySingleton(
      () => AppDatabase(executor: locator()),
      dispose: (e) => e.close(),
    );
    locator.registerLazySingleton(() => DatabaseViewer());
    locator.registerFactory(() => MangaDao(locator()));
    locator.registerFactory(() => ChapterDao(locator()));
    locator.registerFactory(() => LibraryDao(locator()));
    locator.registerFactory(() => JobDao(locator()));
    locator.registerFactory(() => HistoryDao(locator()));
    locator.registerFactory(() => TagDao(locator()));

    locator.registerSingleton(await SharedPreferences.getInstance());
    locator.registerLazySingleton(
      () => StorageManager(dio: () => locator(), logBox: log),
      dispose: (e) => e.dispose(),
    );

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'start': start, 'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}
