import 'package:file/file.dart';

extension FileSystemEntityExtension on FileSystemEntity {
  String? get _lastPathComponent => path.split('/').lastOrNull;

  String? get filename => _lastPathComponent?.split('.').firstOrNull;

  String? get extension => _lastPathComponent?.split('.').lastOrNull;
}