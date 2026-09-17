import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data' show Uint8List;

import 'package:file/file.dart';
import 'package:fs_shim/fs_shim.dart' as fs;

import 'fs_shim_file_stat.dart';
import 'fs_shim_file_system.dart';
import 'fs_shim_io_sink.dart';
import 'fs_shim_mapping.dart';

/// `package:file` [File] backed by an fs_shim file.
///
/// Async-only: every `*Sync` member, random-access [open], timestamp
/// setters, and [resolveSymbolicLinks] throw [UnsupportedError].
/// fs_shim exposes no `length`/`lastModified`, so both derive from
/// [stat]; `accessed` mirrors `modified` (see [FsShimFileStat]).
class FsShimFile implements File {
  FsShimFile(this._delegate, this._owner);

  final fs.File _delegate;
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
  File get absolute => _owner.file(_delegate.absolute.path);

  @override
  Directory get parent => _owner.directory(_delegate.parent.path);

  @override
  Future<File> create({bool recursive = false, bool exclusive = false}) {
    if (exclusive) {
      unsupported('File.create(exclusive: true)');
    }
    return guardFs(
      () async => _owner.file(
        (await _delegate.create(recursive: recursive)).path,
      ),
    );
  }

  @override
  void createSync({bool recursive = false, bool exclusive = false}) =>
      unsupported('File.createSync');

  @override
  Future<File> rename(String newPath) => guardFs(
        () async => _owner.file((await _delegate.rename(newPath)).path),
      );

  @override
  File renameSync(String newPath) => unsupported('File.renameSync');

  @override
  Future<File> copy(String newPath) => guardFs(
        () async => _owner.file((await _delegate.copy(newPath)).path),
      );

  @override
  File copySync(String newPath) => unsupported('File.copySync');

  @override
  Future<bool> exists() => guardFs(_delegate.exists);

  @override
  bool existsSync() => unsupported('File.existsSync');

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) => guardFs(
        () async => _owner.file(
          (await _delegate.delete(recursive: recursive)).path,
        ),
      );

  @override
  void deleteSync({bool recursive = false}) => unsupported('File.deleteSync');

  @override
  Future<io.FileStat> stat() =>
      guardFs(() async => FsShimFileStat.fromFsStat(await _delegate.stat()));

  @override
  io.FileStat statSync() => unsupported('File.statSync');

  @override
  Future<int> length() => guardFs(() async => (await _delegate.stat()).size);

  @override
  int lengthSync() => unsupported('File.lengthSync');

  @override
  Future<DateTime> lastModified() =>
      guardFs(() async => (await _delegate.stat()).modified);

  @override
  DateTime lastModifiedSync() => unsupported('File.lastModifiedSync');

  @override
  Future<DateTime> lastAccessed() =>
      guardFs(() async => (await _delegate.stat()).modified);

  @override
  DateTime lastAccessedSync() => unsupported('File.lastAccessedSync');

  @override
  Future<void> setLastModified(DateTime time) =>
      unsupported('File.setLastModified');

  @override
  void setLastModifiedSync(DateTime time) =>
      unsupported('File.setLastModifiedSync');

  @override
  Future<void> setLastAccessed(DateTime time) =>
      unsupported('File.setLastAccessed');

  @override
  void setLastAccessedSync(DateTime time) =>
      unsupported('File.setLastAccessedSync');

  @override
  Future<io.RandomAccessFile> open({io.FileMode mode = io.FileMode.read}) =>
      unsupported('File.open');

  @override
  io.RandomAccessFile openSync({io.FileMode mode = io.FileMode.read}) =>
      unsupported('File.openSync');

  @override
  Stream<List<int>> openRead([int? start, int? end]) =>
      _delegate.openRead(start, end);

  @override
  io.IOSink openWrite({
    io.FileMode mode = io.FileMode.write,
    Encoding encoding = utf8,
  }) =>
      FsShimIOSink(
        _delegate.openWrite(mode: mapFileMode(mode), encoding: encoding),
        encoding,
      );

  @override
  Future<Uint8List> readAsBytes() => guardFs(_delegate.readAsBytes);

  @override
  Uint8List readAsBytesSync() => unsupported('File.readAsBytesSync');

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      guardFs(() => _delegate.readAsString(encoding: encoding));

  @override
  String readAsStringSync({Encoding encoding = utf8}) =>
      unsupported('File.readAsStringSync');

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) async {
    final content = await readAsString(encoding: encoding);
    return const LineSplitter().convert(content);
  }

  @override
  List<String> readAsLinesSync({Encoding encoding = utf8}) =>
      unsupported('File.readAsLinesSync');

  @override
  Future<File> writeAsBytes(
    List<int> bytes, {
    io.FileMode mode = io.FileMode.write,
    bool flush = false,
  }) =>
      guardFs(
        () async => _owner.file(
          (await _delegate.writeAsBytes(
            Uint8List.fromList(bytes),
            mode: mapFileMode(mode),
            flush: flush,
          ))
              .path,
        ),
      );

  @override
  void writeAsBytesSync(
    List<int> bytes, {
    io.FileMode mode = io.FileMode.write,
    bool flush = false,
  }) => unsupported('File.writeAsBytesSync');

  @override
  Future<File> writeAsString(
    String contents, {
    io.FileMode mode = io.FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) =>
      guardFs(
        () async => _owner.file(
          (await _delegate.writeAsString(
            contents,
            mode: mapFileMode(mode),
            encoding: encoding,
            flush: flush,
          ))
              .path,
        ),
      );

  @override
  void writeAsStringSync(
    String contents, {
    io.FileMode mode = io.FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) => unsupported('File.writeAsStringSync');

  @override
  Future<String> resolveSymbolicLinks() =>
      unsupported('File.resolveSymbolicLinks');

  @override
  String resolveSymbolicLinksSync() =>
      unsupported('File.resolveSymbolicLinksSync');

  @override
  Stream<io.FileSystemEvent> watch({
    int events = io.FileSystemEvent.all,
    bool recursive = false,
  }) => unsupported('File.watch');

  @override
  String toString() => "File: '$path'";
}
