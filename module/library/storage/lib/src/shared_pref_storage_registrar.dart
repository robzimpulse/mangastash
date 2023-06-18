import 'package:service_locator/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_pref_storage.dart';

class SharedPreferencesStorageRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final local = await SharedPreferences.getInstance();
    locator.registerSingleton(SharedPreferencesStorage(local));
  }
}