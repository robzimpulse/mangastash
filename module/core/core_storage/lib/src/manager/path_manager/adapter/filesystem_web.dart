import 'package:file/file.dart';
import 'package:file/memory.dart';

FileSystem fileSystem() => MemoryFileSystem();

Future<Directory> rootDirectory({required FileSystem system}) {
  return system.systemTempDirectory.createTemp('local');
}