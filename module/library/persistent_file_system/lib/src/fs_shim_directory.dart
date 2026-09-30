import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:fs_shim/fs_shim.dart' as fs;

import 'fs_shim_file_stat.dart';
import 'fs_shim_file_system.dart';
import 'fs_shim_mapping.dart';

/// `package:file` [Directory] backed by an fs_shim directory.
///
/// Async-only: every `*Sync` member plus [createTemp] throws
/// [UnsupportedError] (fixed persistent paths replace temp directories).
class FsShimDirectory implements Directory {
  FsShimDirectory(this._delegate, this._owner);

  final fs.Directory _delegate;
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
  Directory get absolute => _owner.directory(_delegate.absolute.path);

  @override
  Directory get parent => _owner.directory(_delegate.parent.path);

  @override
  Future<Directory> create({bool recursive = false}) => guardFs(
        () async => _owner.directory(
          (await _delegate.create(recursive: recursive)).path,
        ),
      );

  @override
  void createSync({bool recursive = false}) =>
      unsupported('Directory.createSync');

  @override
  Future<Directory> createTemp([String? prefix]) =>
      unsupported('Directory.createTemp');

  @override
  Directory createTempSync([String? prefix]) =>
      unsupported('Directory.createTempSync');

  @override
  Future<Directory> rename(String newPath) => guardFs(
        () async => _owner.directory((await _delegate.rename(newPath)).path),
      );

  @override
  Directory renameSync(String newPath) => unsupported('Directory.renameSync');

  @override
  Future<bool> exists() => guardFs(_delegate.exists);

  @override
  bool existsSync() => unsupported('Directory.existsSync');

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) => guardFs(
        () async => _owner.directory(
          (await _delegate.delete(recursive: recursive)).path,
        ),
      );

  @override
  void deleteSync({bool recursive = false}) =>
      unsupported('Directory.deleteSync');

  @override
  Future<io.FileStat> stat() =>
      guardFs(() async => FsShimFileStat.fromFsStat(await _delegate.stat()));

  @override
  io.FileStat statSync() => unsupported('Directory.statSync');

  @override
  Stream<FileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  }) =>
      guardFsStream<fs.FileSystemEntity>(
        _delegate.list(recursive: recursive, followLinks: followLinks),
      ).map(_wrapEntity);

  @override
  List<FileSystemEntity> listSync({
    bool recursive = false,
    bool followLinks = true,
  }) => unsupported('Directory.listSync');

  @override
  Future<String> resolveSymbolicLinks() =>
      unsupported('Directory.resolveSymbolicLinks');

  @override
  String resolveSymbolicLinksSync() =>
      unsupported('Directory.resolveSymbolicLinksSync');

  @override
  Stream<io.FileSystemEvent> watch({
    int events = io.FileSystemEvent.all,
    bool recursive = false,
  }) => unsupported('Directory.watch');

  @override
  Directory childDirectory(String basename) =>
      _owner.directory(_owner.path.join(path, basename));

  @override
  File childFile(String basename) =>
      _owner.file(_owner.path.join(path, basename));

  @override
  Link childLink(String basename) =>
      _owner.link(_owner.path.join(path, basename));

  FileSystemEntity _wrapEntity(fs.FileSystemEntity entity) {
    if (entity is fs.File) {
      return _owner.file(entity.path);
    }
    if (entity is fs.Directory) {
      return _owner.directory(entity.path);
    }
    return _owner.link(entity.path);
  }

  @override
  String toString() => "Directory: '$path'";
}
