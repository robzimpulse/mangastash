import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';

FileSystem fileSystem() => LocalFileSystem();

Future<Directory> rootDirectory({required FileSystem system}) async {
  return system.directory(await getApplicationDocumentsDirectory());
}