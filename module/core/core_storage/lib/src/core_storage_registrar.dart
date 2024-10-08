import 'dart:developer';

import 'package:service_locator/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'in_memory_storage.dart';
import 'shared_preferences_storage.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString());
    final local = await SharedPreferences.getInstance();
    locator.registerSingleton(SharedPreferencesStorage(local));
    locator.registerSingleton(InMemoryStorage({}));
    log('finish register', name: runtimeType.toString());
  }
}
