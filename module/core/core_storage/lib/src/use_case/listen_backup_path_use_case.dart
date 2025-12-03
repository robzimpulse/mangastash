import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

abstract class ListenBackupPathUseCase {
  ValueStream<Directory?> get backupPathStream;
}