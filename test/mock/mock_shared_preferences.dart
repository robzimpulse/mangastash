import 'package:core_storage/core_storage.dart';

class MockSharedPreferences implements SharedPreferences {

  final Map<String, Object> _storage = {};

  @override
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }

  @override
  Future<bool> commit() async {
    return true;
  }

  @override
  bool containsKey(String key) => _storage.containsKey(key);

  @override
  Object? get(String key) => _storage[key];

  T? _get<T>(String key) {
    final value = get(key);
    if (value is T) return value;
    return null;
  }

  @override
  bool? getBool(String key) => _get(key);

  @override
  double? getDouble(String key) => _get(key);

  @override
  int? getInt(String key) => _get(key);

  @override
  Set<String> getKeys() => _storage.keys.toSet();

  @override
  String? getString(String key) => _get(key);

  @override
  List<String>? getStringList(String key) => _get(key);

  @override
  Future<void> reload() async {}

  @override
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = value;
    return true;
  }
}