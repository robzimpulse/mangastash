import 'package:file/file.dart';
import 'package:file/memory.dart';

Future<Directory> databaseDirectory() {
  return MemoryFileSystem().systemTempDirectory.createTemp('database');
}
