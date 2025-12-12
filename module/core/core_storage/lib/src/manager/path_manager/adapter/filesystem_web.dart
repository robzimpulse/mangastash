import 'package:file/file.dart';
import 'package:file/memory.dart';

FileSystem filesystem() => MemoryFileSystem();

Future<Directory> rootDirectory() async {
  return filesystem().systemTempDirectory.createTemp('mangastash');
}
