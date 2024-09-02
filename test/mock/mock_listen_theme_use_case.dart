import 'package:core_environment/core_environment.dart';
import 'package:flutter/src/material/theme_data.dart';
import 'package:rxdart/rxdart.dart';

class MockListenThemeUseCase implements ListenThemeUseCase {

  final data = BehaviorSubject<ThemeData>.seeded(ThemeData.light());

  @override
  ValueStream<ThemeData> get themeDataStream => data.stream;

}