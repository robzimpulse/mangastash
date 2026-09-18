import 'package:file/file.dart';

import 'package:persistent_file_system/persistent_file_system.dart';

Future<Directory> rootDirectory() async =>
    persistentFileSystem.directory('/local');
