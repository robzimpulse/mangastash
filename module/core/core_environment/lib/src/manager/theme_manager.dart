import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/listen_theme_use_case.dart';
import '../use_case/update_theme_use_case.dart';

class ThemeManager implements UpdateThemeUseCase, ListenThemeUseCase {
  final Storage _storage;

  final _themeDataStream = BehaviorSubject<ThemeData>.seeded(ThemeData.light());

  static const _key = 'is_dark_mode';

  ThemeManager({
    required Storage storage,
  }) : _storage = storage {
    final value = storage.getBool(_key);
    if (value == null) return;
    updateTheme(theme: value ? ThemeData.dark() : ThemeData.light());
  }

  @override
  void updateTheme({required ThemeData theme}) {
    _storage.setBool(_key, theme.brightness == Brightness.dark);
    _themeDataStream.add(theme);
  }

  @override
  ValueStream<ThemeData> get themeDataStream => _themeDataStream.stream;
}
