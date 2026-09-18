import 'package:file/file.dart';

import 'package:persistent_file_system/persistent_file_system.dart';

Future<Directory> databaseDirectory() async =>
    persistentFileSystem.directory('/database');
