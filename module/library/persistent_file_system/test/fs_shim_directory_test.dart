import 'package:file/file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fs_shim_file_system_test.dart' show newTestFileSystem;

void main() {
  late FileSystem fs;

  setUp(() {
    fs = newTestFileSystem();
  });

  group('FsShimDirectory', () {
    test('create(recursive: true) builds parents and exists()', () async {
      final dir = fs.directory('/root/sub/dir');
      expect(await dir.exists(), isFalse);
      await dir.create(recursive: true);
      expect(await fs.directory('/root/sub/dir').exists(), isTrue);
    });

    test(
      'non-recursive create on a fresh root throws (#104) — FileDao pattern needs a created root',
      () async {
        // The web backend starts completely empty: a non-recursive create
        // more than one level deep throws, which is why the database root
        // must be created before FileDao.directory() runs.
        final dir = fs.directory('/database/mangastash-local/file');
        await expectLater(dir.create(), throwsA(isA<FileSystemException>()));
      },
    );

    test('non-recursive create succeeds when only the parent is missing', () async {
      // What FileDao.directory() does after Executor.databaseDirectory()
      // created `/database/mangastash-local` recursively.
      await fs.directory('/database/mangastash-local').create(recursive: true);
      final dir = fs.directory('/database/mangastash-local/file');
      await dir.create();
      expect(await dir.exists(), isTrue);
    });

    test('list() returns wrapped File and Directory children', () async {
      await fs.directory('/root').create();
      await fs.file('/root/a.txt').writeAsString('a');
      await fs.directory('/root/sub').create();
      final children = await fs.directory('/root').list().toList();
      expect(
        children.map((entity) => entity.path).toSet(),
        {'/root/a.txt', '/root/sub'},
      );
      expect(children.whereType<File>(), hasLength(1));
      expect(children.whereType<Directory>(), hasLength(1));
    });

    test('delete() on non-empty directory throws FileSystemException',
        () async {
      final dir = fs.directory('/full');
      await dir.create();
      await fs.file('/full/a.txt').writeAsString('a');
      await expectLater(dir.delete(), throwsA(isA<FileSystemException>()));
    });

    test('delete(recursive: true) removes the whole tree', () async {
      final dir = fs.directory('/tree');
      await dir.create();
      await fs.file('/tree/a.txt').writeAsString('a');
      await fs.directory('/tree/nested').create();
      await dir.delete(recursive: true);
      expect(await dir.exists(), isFalse);
    });

    test('childFile/childDirectory/childLink compose paths', () {
      final root = fs.directory('/root');
      expect(root.childFile('a.txt').path, '/root/a.txt');
      expect(root.childDirectory('sub').path, '/root/sub');
      expect(root.childLink('l').path, '/root/l');
    });

    test('rename moves the directory', () async {
      await fs.directory('/before').create();
      final moved = await fs.directory('/before').rename('/after');
      expect(moved.path, '/after');
      expect(await fs.directory('/after').exists(), isTrue);
      expect(await fs.directory('/before').exists(), isFalse);
    });

    test('parent, basename and dirname', () {
      final dir = fs.directory('/root/sub');
      expect(dir.parent.path, '/root');
      expect(dir.basename, 'sub');
      expect(dir.dirname, '/root');
    });

    test('stat() reports directory type', () async {
      await fs.directory('/statme').create();
      final stat = await fs.directory('/statme').stat();
      expect(stat.type, FileSystemEntityType.directory);
    });
  });
}
