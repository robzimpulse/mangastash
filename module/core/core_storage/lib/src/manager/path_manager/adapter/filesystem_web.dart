import 'package:file/file.dart';
import 'package:file/memory.dart';

Future<Directory> rootDirectory() {
  return MemoryFileSystem().systemTempDirectory.createTemp('local');
}