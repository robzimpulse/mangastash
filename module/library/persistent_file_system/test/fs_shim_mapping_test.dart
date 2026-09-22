import 'dart:io' show FileMode, FileSystemEntityType;

import 'package:flutter_test/flutter_test.dart';
import 'package:fs_shim/fs_memory.dart' show newFileSystemMemory;
import 'package:fs_shim/fs_shim.dart' as fs;
import 'package:persistent_file_system/persistent_file_system.dart';

void main() {
  group('mapEntityType', () {
    test('maps fs_shim entity types to dart:io equivalents', () {
      expect(
        mapEntityType(fs.FileSystemEntityType.file),
        FileSystemEntityType.file,
      );
      expect(
        mapEntityType(fs.FileSystemEntityType.directory),
        FileSystemEntityType.directory,
      );
      expect(
        mapEntityType(fs.FileSystemEntityType.link),
        FileSystemEntityType.link,
      );
      expect(
        mapEntityType(fs.FileSystemEntityType.notFound),
        FileSystemEntityType.notFound,
      );
    });

    test('maps null to notFound', () {
      expect(mapEntityType(null), FileSystemEntityType.notFound);
    });
  });

  group('mapFileMode', () {
    test('maps dart:io open modes to fs_shim singletons', () {
      expect(mapFileMode(FileMode.read), same(fs.FileMode.read));
      expect(mapFileMode(FileMode.write), same(fs.FileMode.write));
      expect(mapFileMode(FileMode.append), same(fs.FileMode.append));
    });

    test('maps writeOnly modes to writable fs_shim modes, never read', () {
      // fs_shim has no writeOnly; mapping it to read would make openWrite
      // throw a confusing ArgumentError deep in the backend.
      expect(mapFileMode(FileMode.writeOnly), same(fs.FileMode.write));
      expect(
        mapFileMode(FileMode.writeOnlyAppend),
        same(fs.FileMode.append),
      );
    });
  });

  group('FsShimFileStat', () {
    test('fromFsStat maps a missing file to notFound with size -1', () async {
      final delegate = newFileSystemMemory();
      final stat = await delegate.file('/missing').stat();
      final mapped = FsShimFileStat.fromFsStat(stat);
      expect(mapped.type, FileSystemEntityType.notFound);
      expect(mapped.size, -1);
    });
  });
}
