import 'dart:developer';

import 'package:service_locator/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_storage.dart';
import 'storage.dart';

class CoreStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: 'core_storage');
    final local = await SharedPreferences.getInstance();
    locator.registerSingleton(SharedPreferencesStorage(local));
    locator.alias<Storage, SharedPreferencesStorage>();
    log('finish register', name: 'core_storage');
  }
}
