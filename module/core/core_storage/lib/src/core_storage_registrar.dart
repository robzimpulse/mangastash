import 'package:log_box/log_box.dart' hide Storage;
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:service_locator/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manager/storage_manager/storage_manager.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'start': DateTime.timestamp().toIso8601String()},
    );

    locator.registerSingleton(AppDatabase(), dispose: (e) => e.close());
    locator.registerSingleton(DatabaseViewer());
    locator.registerFactory(() => MangaDao(locator()));
    locator.registerFactory(() => ChapterDao(locator()));
    locator.registerFactory(() => LibraryDao(locator()));
    locator.registerFactory(() => JobDao(locator()));
    locator.registerFactory(() => HistoryDao(locator()));
    locator.registerFactory(() => TagDao(locator()));

    locator.registerSingleton(await SharedPreferences.getInstance());
    locator.registerSingleton(
      StorageManager(dio: locator(), logbox: log),
      dispose: (e) => e.dispose(),
    );

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}
