import 'dart:typed_data' show Uint8List;

import 'package:file/file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fs_shim_file_system_test.dart' show newTestFileSystem;

void main() {
  late FileSystem fs;

  setUp(() {
    fs = newTestFileSystem();
  });

  group('FsShimFile', () {
    test('writeAsBytes/readAsBytes roundtrip', () async {
      final file = fs.file('/data.bin');
      await file.writeAsBytes([1, 2, 3, 4]);
      expect(await file.readAsBytes(), [1, 2, 3, 4]);
    });

    test('writeAsString/readAsString roundtrip', () async {
      final file = fs.file('/text.txt');
      await file.writeAsString('héllo');
      expect(await file.readAsString(), 'héllo');
    });

    test('readAsLines splits lines', () async {
      final file = fs.file('/lines.txt');
      await file.writeAsString('a\nb\nc');
      expect(await file.readAsLines(), ['a', 'b', 'c']);
    });

    test('create(recursive: true) creates missing parents', () async {
      final file = fs.file('/deep/nested/file.txt');
      await file.create(recursive: true);
      expect(await file.exists(), isTrue);
    });

    test('openWrite().addStream(openRead()) — the FileDao pattern', () async {
      final content = List<int>.generate(1024, (i) => i % 256);
      final source = fs.file('/src.bin');
      await source.writeAsBytes(content);
      final destination = fs.file('/dest.bin');
      final sink = destination.openWrite();
      await sink.addStream(source.openRead());
      await sink.close();
      final readBack = await destination.readAsBytes();
      expect(readBack, isA<Uint8List>());
      expect(readBack, content);
    });

    test('IOSink text methods encode strings', () async {
      final file = fs.file('/sink.txt');
      final sink = file.openWrite();
      sink
        ..write('a')
        ..writeln('b')
        ..writeCharCode(0x63);
      await sink.close();
      expect(await file.readAsString(), 'ab\nc');
    });

    test('reading a missing file throws dart:io FileSystemException',
        () async {
      await expectLater(
        fs.file('/missing.bin').readAsBytes(),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('openRead() stream errors are dart:io FileSystemException', () async {
      // FileDao.addFromFile consumes exactly this stream; an unmapped
      // fs_shim error would leak IdbFileSystemException across the boundary.
      await expectLater(
        fs.file('/missing.bin').openRead().drain<void>(),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('length() and lastModified() derive from stat()', () async {
      final file = fs.file('/stat.bin');
      await file.writeAsBytes([1, 2, 3]);
      expect(await file.length(), 3);
      expect(await file.lastModified(), isNotNull);
    });

    test('copy duplicates content at the new path', () async {
      await fs.file('/orig.txt').writeAsString('copy me');
      final copied = await fs.file('/orig.txt').copy('/copy.txt');
      expect(copied.path, '/copy.txt');
      expect(await fs.file('/copy.txt').readAsString(), 'copy me');
    });

    test('rename moves the file', () async {
      await fs.file('/old.txt').writeAsString('x');
      final moved = await fs.file('/old.txt').rename('/new.txt');
      expect(moved.path, '/new.txt');
      expect(await fs.file('/new.txt').exists(), isTrue);
      expect(await fs.file('/old.txt').exists(), isFalse);
    });

    test('delete removes the file', () async {
      final file = fs.file('/gone.txt');
      await file.writeAsString('x');
      await file.delete();
      expect(await file.exists(), isFalse);
    });
  });
}
