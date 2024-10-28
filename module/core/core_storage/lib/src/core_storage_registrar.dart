import 'dart:developer';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/custom_cache_manager.dart';
import 'manager/root_path_manager.dart';
import 'storage/in_memory_storage.dart';
import 'storage/shared_preferences_storage.dart';
import 'use_case/get_root_path_use_case.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString());

    locator.registerSingleton(await RootPathManager.create());
    locator.alias<GetRootPathUseCase, RootPathManager>();

    locator.registerSingleton(await SharedPreferencesStorage.create());

    locator.registerSingleton(InMemoryStorage());

    locator.registerSingleton(CustomCacheManager.create());
    locator.alias<BaseCacheManager, CustomCacheManager>();

    log('finish register', name: runtimeType.toString());
  }
}
