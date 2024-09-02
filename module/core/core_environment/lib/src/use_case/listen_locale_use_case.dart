import 'dart:ui';

import 'package:rxdart/rxdart.dart';

abstract class ListenLocaleUseCase {
  ValueStream<Locale?> get localeDataStream;
}
