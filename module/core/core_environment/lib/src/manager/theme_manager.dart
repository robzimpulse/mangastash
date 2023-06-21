import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/listen_theme_use_case.dart';
import '../use_case/update_theme_use_case.dart';

class ThemeManager implements UpdateThemeUseCase, ListenThemeUseCase {

  final _themeDataStream = BehaviorSubject<ThemeData>.seeded(ThemeData.light());

  @override
  void updateTheme({required ThemeData theme}) {
    _themeDataStream.add(theme);
  }

  @override
  ValueStream<ThemeData> get themeDataStream => _themeDataStream.stream;

}