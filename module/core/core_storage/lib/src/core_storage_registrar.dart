import 'dart:developer';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:service_locator/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_cache_manager.dart';
import 'in_memory_storage.dart';
import 'shared_preferences_storage.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString());
    final local = await SharedPreferences.getInstance();
    locator.registerSingleton(SharedPreferencesStorage(local));
    locator.registerSingleton(InMemoryStorage({}));
    locator.registerSingleton(CustomCacheManager.create());
    locator.alias<BaseCacheManager, CustomCacheManager>();
    log('finish register', name: runtimeType.toString());
  }
}
