import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/listen_theme_use_case.dart';
import '../use_case/update_theme_use_case.dart';

class ThemeManager implements UpdateThemeUseCase, ListenThemeUseCase {
  final SharedPreferencesAsync _storage;

  final BehaviorSubject<ThemeData> _themeDataStream;

  static const _key = 'is_dark_mode';

  ThemeManager._({
    required SharedPreferencesAsync storage,
    required ThemeData initialThemeData,
  }) : _storage = storage,
       _themeDataStream = BehaviorSubject.seeded(initialThemeData);

  static Future<ThemeManager> create({
    required SharedPreferencesAsync storage,
  }) async {
    final value = await storage.getBool(_key);
    return ThemeManager._(
      storage: storage,
      initialThemeData: value == true ? ThemeData.dark() : ThemeData.light(),
    );
  }

  @override
  Future<void> updateTheme({required ThemeData theme}) async {
    await _storage.setBool(_key, theme.brightness == Brightness.dark);
    _themeDataStream.add(theme);
  }

  @override
  ValueStream<ThemeData> get themeDataStream => _themeDataStream.stream;
}
