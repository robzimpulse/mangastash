import 'package:file/file.dart';

import 'package:persistent_file_system/src/persistent_web_file_system.dart';

Future<Directory> databaseDirectory() async =>
    persistentFileSystem.directory('/database');
