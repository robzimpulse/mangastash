import 'package:file/file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_shim/fs_memory.dart' show newFileSystemMemory;
import 'package:path/path.dart' as p;
import 'package:persistent_file_system/persistent_file_system.dart';

/// Fresh wrapped memory filesystem (same FileSystemIdb code path as web).
FileSystem newTestFileSystem() => FsShimFileSystem(newFileSystemMemory());

void main() {
  late FileSystem fs;

  setUp(() {
    fs = newTestFileSystem();
  });

  group('FsShimFileSystem', () {
    test('directory() is stable across calls — the #104 regression', () async {
      await fs.directory('/root').create(recursive: true);
      final secondLookup = fs.directory('/root');
      expect(await secondLookup.exists(), isTrue);
    });

    test('type() reports file, directory and notFound', () async {
      await fs.directory('/a/b').create(recursive: true);
      await fs.file('/a/b/c.txt').writeAsString('hi');
      expect(await fs.type('/a/b/c.txt'), FileSystemEntityType.file);
      expect(await fs.type('/a/b'), FileSystemEntityType.directory);
      expect(await fs.type('/missing'), FileSystemEntityType.notFound);
    });

    test('stat() maps size and type', () async {
      await fs.file('/s.txt').writeAsString('hello');
      final stat = await fs.stat('/s.txt');
      expect(stat.size, 5);
      expect(stat.type, FileSystemEntityType.file);
    });

    test('path context is posix', () {
      expect(fs.path.style, p.Style.posix);
    });

    test('isFile/isDirectory come from package:file defaults', () async {
      await fs.file('/f.bin').writeAsBytes([1, 2]);
      expect(await fs.isFile('/f.bin'), isTrue);
      expect(await fs.isDirectory('/f.bin'), isFalse);
    });

    test('systemTempDirectory resolves a fixed /tmp directory', () async {
      expect(fs.systemTempDirectory.path, '/tmp');
    });

    test('link() returns a Link with correct path plumbing', () {
      final link = fs.link('/somewhere/l');
      expect(link.path, '/somewhere/l');
      expect(link.basename, 'l');
      expect(link.parent.path, '/somewhere');
      expect(link.fileSystem, same(fs));
    });
  });
}
