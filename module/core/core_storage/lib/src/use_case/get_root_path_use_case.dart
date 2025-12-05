import 'package:universal_io/io.dart';

abstract class GetRootPathUseCase {
  Directory? get rootPath;

  Directory? get androidRootPath;
}

extension RootForPickingFile on GetRootPathUseCase {
  Directory? get rootForPickFile => androidRootPath ?? rootPath;
}