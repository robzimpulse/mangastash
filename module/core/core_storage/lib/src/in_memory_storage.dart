import 'storage.dart';

class InMemoryStorage extends Storage {

  final Map<String, Object> _impl;

  InMemoryStorage(this._impl);

  @override
  Future<bool> clear() async {
    _impl.clear();
    return _impl.isEmpty;
  }

  @override
  bool containsKey(String key) => _impl.containsKey(key);

  @override
  Object? get(String key) => _impl[key];

  @override
  bool? getBool(String key) {
    final object = get(key);
    return (object is bool) ? object : null;
  }

  @override
  double? getDouble(String key) {
    final object = get(key);
    return (object is double) ? object : null;
  }

  @override
  int? getInt(String key) {
    final object = get(key);
    return (object is int) ? object : null;
  }

  @override
  Set<String> getKeys() => _impl.keys.toSet();

  @override
  String? getString(String key) {
    final object = get(key);
    return (object is String) ? object : null;
  }

  @override
  List<String>? getStringList(String key) {
    final object = get(key);
    return (object is List<String>) ? object : null;
  }

  @override
  Future<void> reload() async {  }

  @override
  Future<bool> remove(String key) async {
    _impl.remove(key);
    return containsKey(key);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _impl[key] = value;
    return _impl[key] == value;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _impl[key] = value;
    return _impl[key] == value;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _impl[key] = value;
    return _impl[key] == value;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _impl[key] = value;
    return _impl[key] == value;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _impl[key] = value;
    return _impl[key] == value;
  }

}