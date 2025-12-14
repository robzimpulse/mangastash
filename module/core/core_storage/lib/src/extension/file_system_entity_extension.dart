import 'package:universal_io/universal_io.dart';

import 'int_extension.dart';

extension FileSystemEntityExtension on FileSystemEntity {
  String? get _lastPathComponent => path.split('/').lastOrNull;

  String? get filename => _lastPathComponent?.split('.').firstOrNull;

  String? get extension => _lastPathComponent?.split('.').lastOrNull;
}

extension FileStatExtension on FileStat {

  double get sizeInKb => size.inKb;

  double get sizeInMb => size.inMb;

  double get sizeInGb => size.inGb;

  String get formattedSize => size.formattedSize;
}