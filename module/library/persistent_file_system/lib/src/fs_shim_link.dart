import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:fs_shim/fs_shim.dart' as fs;

import 'fs_shim_file_stat.dart';
import 'fs_shim_file_system.dart';
import 'fs_shim_mapping.dart';

/// `package:file` [Link] backed by an fs_shim link.
///
/// The IndexedDB backend does not support links, so `create`/`target` fail
/// with a dart:io [io.FileSystemException] at runtime (fs_shim's own error,
/// mapped). The class exists so [FileSystem.link] and directory listings
/// stay type-correct; sync members throw [UnsupportedError].
class FsShimLink implements Link {
  FsShimLink(this._delegate, this._owner);

  final fs.Link _delegate;
  final FsShimFileSystem _owner;

  @override
  FileSystem get fileSystem => _owner;

  @override
  String get path => _delegate.path;

  @override
  Uri get uri => Uri.file(path);

  @override
  bool get isAbsolute => _delegate.isAbsolute;

  @override
  String get basename => _owner.path.basename(path);

  @override
  String get dirname => _owner.path.dirname(path);

  @override
  Link get absolute => _owner.link(_delegate.absolute.path);

  @override
  Directory get parent => _owner.directory(_delegate.parent.path);

  @override
  Future<Link> create(String target, {bool recursive = false}) => guardFs(
        () async => _owner.link(
          (await _delegate.create(target, recursive: recursive)).path,
        ),
      );

  @override
  void createSync(String target, {bool recursive = false}) =>
      unsupported('Link.createSync');

  @override
  Future<Link> update(String target) => unsupported('Link.update');

  @override
  void updateSync(String target) => unsupported('Link.updateSync');

  @override
  Future<String> target() => guardFs(_delegate.target);

  @override
  String targetSync() => unsupported('Link.targetSync');

  @override
  Future<Link> rename(String newPath) => guardFs(
        () async => _owner.link((await _delegate.rename(newPath)).path),
      );

  @override
  Link renameSync(String newPath) => unsupported('Link.renameSync');

  @override
  Future<bool> exists() => guardFs(_delegate.exists);

  @override
  bool existsSync() => unsupported('Link.existsSync');

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) => guardFs(
        () async => _owner.link(
          (await _delegate.delete(recursive: recursive)).path,
        ),
      );

  @override
  void deleteSync({bool recursive = false}) => unsupported('Link.deleteSync');

  @override
  Future<io.FileStat> stat() =>
      guardFs(() async => FsShimFileStat.fromFsStat(await _delegate.stat()));

  @override
  io.FileStat statSync() => unsupported('Link.statSync');

  @override
  Future<String> resolveSymbolicLinks() =>
      unsupported('Link.resolveSymbolicLinks');

  @override
  String resolveSymbolicLinksSync() =>
      unsupported('Link.resolveSymbolicLinksSync');

  @override
  Stream<io.FileSystemEvent> watch({
    int events = io.FileSystemEvent.all,
    bool recursive = false,
  }) => unsupported('Link.watch');

  @override
  String toString() => "Link: '$path'";
}
