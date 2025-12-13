import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> rootDirectory() async {
  return LocalFileSystem().directory(await getApplicationDocumentsDirectory());
}