import 'package:file/file.dart';

import '../database/adapter/filesystem/filesystem_adapter.dart'
    if (dart.library.js_interop) '../database/adapter/filesystem/filesystem_web.dart'
    if (dart.library.io) '../database/adapter/filesystem/filesystem_io.dart';
import '../database/database.dart';

extension FileDriftExtension on FileDrift {
  Future<File?> get file async {
    final path = relativePath;

    if (path == null) return null;

    return (await databaseDirectory()).childFile(path);
  }
}
