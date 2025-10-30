import 'package:core_storage/core_storage.dart';

class MockSharedPreferencesAsync implements SharedPreferencesAsync {

  final Map<String, Object> _storage = {};

  Future<T?> _get<T>(String key) async {
    final value = _storage[key];
    return (value is T) ? value : null;
  }

  @override
  Future<void> clear({Set<String>? allowList}) async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) async {
    return _storage;
  }

  @override
  Future<bool?> getBool(String key) => _get(key);

  @override
  Future<double?> getDouble(String key) => _get(key);

  @override
  Future<int?> getInt(String key) => _get(key);

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) async {
    return _storage.keys.toSet();
  }

  @override
  Future<String?> getString(String key) => _get(key);

  @override
  Future<List<String>?> getStringList(String key) => _get(key);

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _storage[key] = value;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _storage[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _storage[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _storage[key] = value;
  }

}