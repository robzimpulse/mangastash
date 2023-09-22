import 'package:core_storage/core_storage.dart';

class MockStorage implements Storage {

  final Map<String, Object> _data = {};

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  bool containsKey(String key) {
    return _data.containsKey(key);
  }

  @override
  Object? get(String key) {
    return _data[key];
  }

  @override
  bool? getBool(String key) {
    return _data[key] as bool?;
  }

  @override
  double? getDouble(String key) {
    return _data[key] as double?;
  }

  @override
  int? getInt(String key) {
    return _data[key] as int?;
  }

  @override
  Set<String> getKeys() {
    return _data.keys.toSet();
  }

  @override
  String? getString(String key) {
    return _data[key] as String?;
  }

  @override
  List<String>? getStringList(String key) {
    return _data[key] as List<String>?;
  }

  @override
  Future<void> reload() async {
    return;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

}