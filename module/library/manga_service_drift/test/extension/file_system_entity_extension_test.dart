import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/extension/file_system_entity_extension.dart';

void main() {
  late FileSystem fs;

  setUp(() {
    fs = MemoryFileSystem();
  });

  group('FileSystemEntityExtension', () {
    test('name, ext, filename', () {
      final file = fs.file('/path/to/my_file.txt');
      expect(file.name, 'my_file');
      expect(file.ext, 'txt');
      expect(file.filename, 'my_file.txt');
    });
  });

  group('IntExtension', () {
    test('size conversions', () {
      const size = 1024 * 1024;
      expect(size.inKb, 1024);
      expect(size.inMb, 1);
      expect(size.inGb, 1 / 1024);
    });

    test('formattedSize', () {
      expect(500.formattedSize, '500 b');
      expect((1024 * 500).formattedSize, '500.0 Kb');
      expect((1024 * 1024 * 500).formattedSize, '500.0 Mb');
      expect((1024 * 1024 * 1024 * 500).formattedSize, '500.0 Gb');
    });
  });

  group('DirectorySize', () {
    test('size', () async {
      final dir = fs.directory('/test');
      await dir.create();
      await fs.file('/test/f1.txt').writeAsBytes(List.filled(10, 0));
      await fs.directory('/test/sub').create();
      await fs.file('/test/sub/f2.txt').writeAsBytes(List.filled(20, 0));
      
      expect(await dir.size, 30);
    });
  });
}
