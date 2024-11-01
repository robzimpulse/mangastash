import 'dart:io';

import 'package:rxdart/rxdart.dart';

abstract class ListenBackupPathUseCase {
  ValueStream<Directory> get backupPathStream;
}