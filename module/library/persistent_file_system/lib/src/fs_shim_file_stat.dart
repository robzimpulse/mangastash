import 'dart:io' as io;

import 'package:fs_shim/fs_shim.dart' as fs;

import 'fs_shim_mapping.dart';

/// dart:io [io.FileStat] view over an fs_shim stat result.
///
/// fs_shim only tracks `modified`, so [changed] and [accessed] mirror it.
class FsShimFileStat implements io.FileStat {
  const FsShimFileStat(
    this.changed,
    this.modified,
    this.accessed,
    this.type,
    this.mode,
    this.size,
  );

  /// Builds a dart:io stat from an fs_shim [stat].
  factory FsShimFileStat.fromFsStat(fs.FileStat stat) => FsShimFileStat(
        stat.modified,
        stat.modified,
        stat.modified,
        mapEntityType(stat.type),
        stat.mode,
        stat.size,
      );

  @override
  final DateTime changed;

  @override
  final DateTime modified;

  @override
  final DateTime accessed;

  @override
  final io.FileSystemEntityType type;

  @override
  final int mode;

  @override
  final int size;

  /// Mirrors dart:io's own `modeString` formatting of the [mode] bits.
  @override
  String modeString() {
    final permissions = mode & 0xFFF;
    const codes = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'];
    final result = <String>[];
    if ((permissions & 0x800) != 0) result.add('(suid) ');
    if ((permissions & 0x400) != 0) result.add('(guid) ');
    if ((permissions & 0x200) != 0) result.add('(sticky) ');
    result
      ..add(codes[(permissions >> 6) & 0x7])
      ..add(codes[(permissions >> 3) & 0x7])
      ..add(codes[permissions & 0x7]);
    return result.join();
  }
}
