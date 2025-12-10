import 'package:universal_io/io.dart';

abstract class GetRootPathUseCase {
  Directory? get rootPath;

  Directory get defaultRootDirectory;
}

extension DefaultRootPath on GetRootPathUseCase {
  bool get isDefault => rootPath == defaultRootDirectory;
}
