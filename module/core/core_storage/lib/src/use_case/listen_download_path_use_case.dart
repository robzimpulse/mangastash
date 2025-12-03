import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

abstract class ListenDownloadPathUseCase {
  ValueStream<Directory?> get downloadPathStream;
}