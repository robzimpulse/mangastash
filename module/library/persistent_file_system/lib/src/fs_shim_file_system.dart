import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:fs_shim/fs_shim.dart' as fs;
import 'package:path/path.dart' as p;

import 'fs_shim_directory.dart';
import 'fs_shim_file.dart';
import 'fs_shim_file_stat.dart';
import 'fs_shim_link.dart';
import 'fs_shim_mapping.dart';

/// A `package:file` [FileSystem] delegating to an fs_shim filesystem.
///
/// The backend is async-only: every `*Sync` member, path identity checks,
/// and the current-directory setter throw [UnsupportedError]. Concrete
/// helpers ([isFile], [isDirectory], [isLink], `getPath`) are inherited by
/// extending [FileSystem], mirroring package:file's own memory backend.
class FsShimFileSystem extends FileSystem {
  /// Wraps [delegate] as a package:file compatible filesystem.
  FsShimFileSystem(this.delegate);

  /// The fs_shim filesystem every entity of this wrapper delegates to.
  final fs.FileSystem delegate;

  @override
  FsShimDirectory directory(dynamic path) =>
      FsShimDirectory(delegate.directory(getPath(path)), this);

  @override
  FsShimFile file(dynamic path) =>
      FsShimFile(delegate.file(getPath(path)), this);

  @override
  FsShimLink link(dynamic path) =>
      FsShimLink(delegate.link(getPath(path)), this);

  @override
  p.Context get path => p.Context(style: p.Style.posix);

  @override
  Directory get systemTempDirectory => directory('/tmp');

  @override
  Directory get currentDirectory => directory(delegate.currentDirectory.path);

  @override
  set currentDirectory(dynamic path) =>
      unsupported('FileSystem.currentDirectory setter');

  @override
  Future<io.FileStat> stat(String path) => guardFs(
        () async => FsShimFileStat.fromFsStat(
          await delegate.file(path).stat(),
        ),
      );

  @override
  io.FileStat statSync(String path) => unsupported('FileSystem.statSync');

  @override
  Future<bool> identical(String path1, String path2) =>
      unsupported('FileSystem.identical');

  @override
  bool identicalSync(String path1, String path2) =>
      unsupported('FileSystem.identicalSync');

  @override
  bool get isWatchSupported => false;

  @override
  Future<io.FileSystemEntityType> type(
    String path, {
    bool followLinks = true,
  }) =>
      guardFs(
        () async => mapEntityType(
          await delegate.type(path, followLinks: followLinks),
        ),
      );

  @override
  io.FileSystemEntityType typeSync(String path, {bool followLinks = true}) =>
      unsupported('FileSystem.typeSync');
}
