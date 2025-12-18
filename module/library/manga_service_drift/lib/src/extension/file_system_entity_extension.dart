import 'package:file/file.dart';

extension FileSystemEntityExtension on FileSystemEntity {
  String? get _lastPathComponent => path.split('/').lastOrNull;

  String? get filename {
    return (_lastPathComponent?.split('.')?..removeLast())?.join('.');
  }

  String? get extension => _lastPathComponent?.split('.').lastOrNull;
}
