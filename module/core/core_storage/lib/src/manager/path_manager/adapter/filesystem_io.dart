import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';

FileSystem filesystem() => LocalFileSystem();

Future<Directory> rootDirectory() async {
  return filesystem().directory(
    (await getApplicationDocumentsDirectory()).path,
  );
}
