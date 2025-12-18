import 'package:file/file.dart';

extension FileSystemEntityExtension on FileSystemEntity {
  String? get _lastPathComponent => path.split('/').lastOrNull;

  String? get name {
    return (_lastPathComponent?.split('.')?..removeLast())?.join('.');
  }

  String? get ext => _lastPathComponent?.split('.').lastOrNull;

  String? get filename => [name, ext].nonNulls.join('.');
}

extension FileStatExtension on FileStat {
  double get sizeInKb => size.inKb;
  double get sizeInMb => size.inMb;
  double get sizeInGb => size.inGb;
  String get formattedSize => size.formattedSize;
}

extension DirectorySize on Directory {
  Future<int> get size async {
    var total = 0;

    for (final child in await list().toList()) {
      if (child is File) {
        total += await child.stat().then((value) => value.size);
      }

      if (child is Directory) {
        total += await child.size;
      }
    }

    return total;
  }
}

extension IntExtension on int {
  double get inKb => this / (1024);

  double get inMb => inKb / (1024);

  double get inGb => inMb / (1024);

  String get formattedSize {
    if (this < 1000) return '$this b';
    if (inKb < 1000) return '$inKb Kb';
    if (inMb < 1000) return '$inMb Mb';
    return '$inGb Gb';
  }
}
