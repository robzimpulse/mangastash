import 'package:flutter/material.dart';
import 'package:rxdart/streams.dart';

abstract class ListenThemeUseCase {
  ValueStream<ThemeData> get themeDataStream;
}
