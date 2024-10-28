import 'package:shared_preferences/shared_preferences.dart';

import 'storage.dart';

class SharedPreferencesStorage extends Storage {
  final SharedPreferences _impl;

  SharedPreferencesStorage._({required SharedPreferences impl}) : _impl = impl;

  static Future<SharedPreferencesStorage> create() async {
    final local = await SharedPreferences.getInstance();
    return SharedPreferencesStorage._(impl: local);
  }

  @override
  Set<String> getKeys() => _impl.getKeys();

  @override
  bool containsKey(String key) => _impl.containsKey(key);

  @override
  Object? get(String key) => _impl.get(key);

  @override
  bool? getBool(String key) => _impl.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) => _impl.setBool(key, value);

  @override
  int? getInt(String key) => _impl.getInt(key);

  @override
  Future<bool> setInt(String key, int value) => _impl.setInt(key, value);

  @override
  double? getDouble(String key) => _impl.getDouble(key);

  @override
  Future<bool> setDouble(String key, double value) {
    return _impl.setDouble(key, value);
  }

  @override
  String? getString(String key) => _impl.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    return _impl.setString(key, value);
  }

  @override
  List<String>? getStringList(String key) => _impl.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) {
    return _impl.setStringList(key, value);
  }

  @override
  Future<bool> remove(String key) => _impl.remove(key);

  @override
  Future<bool> clear() => _impl.clear();

  @override
  Future<void> reload() => _impl.reload();
}
