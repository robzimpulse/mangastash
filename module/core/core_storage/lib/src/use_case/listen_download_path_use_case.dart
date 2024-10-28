import 'dart:io';

import 'package:rxdart/rxdart.dart';

abstract class ListenDownloadPathUseCase {
  ValueStream<Directory> get downloadPathStream;
}