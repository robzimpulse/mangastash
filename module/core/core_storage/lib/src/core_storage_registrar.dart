import 'package:log_box/log_box.dart' hide Storage;
import 'package:service_locator/service_locator.dart';

import '../core_storage.dart';
import 'storage/shared_preferences_storage.dart';

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
      CustomCacheManager(dio: () => locator()),
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
