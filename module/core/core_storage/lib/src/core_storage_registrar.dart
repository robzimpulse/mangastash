import 'dart:developer';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/custom_cache_manager.dart';
import 'manager/path_manager.dart';
import 'storage/in_memory_storage.dart';
import 'storage/shared_preferences_storage.dart';
import 'use_case/get_root_path_use_case.dart';
import 'use_case/listen_backup_path_use_case.dart';
import 'use_case/listen_download_path_use_case.dart';
import 'use_case/set_backup_path_use_case.dart';
import 'use_case/set_download_path_use_case.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString(), time: DateTime.now());

    locator.registerSingleton(await SharedPreferencesStorage.create());

    locator.registerSingleton(InMemoryStorage());

    locator.registerSingleton(CustomCacheManager.create());
    locator.alias<BaseCacheManager, CustomCacheManager>();

    locator.registerSingleton(await PathManager.create(storage: locator()));
    locator.alias<GetRootPathUseCase, PathManager>();
    locator.alias<ListenDownloadPathUseCase, PathManager>();
    locator.alias<SetDownloadPathUseCase, PathManager>();
    locator.alias<ListenBackupPathUseCase, PathManager>();
    locator.alias<SetBackupPathUseCase, PathManager>();

    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }
}
