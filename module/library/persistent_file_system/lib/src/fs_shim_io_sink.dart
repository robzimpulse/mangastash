import 'dart:async';
import 'dart:convert';
import 'dart:io' show IOSink;

import 'package:fs_shim/fs_shim.dart' as fs;

import 'fs_shim_mapping.dart';

/// dart:io [IOSink] over an fs_shim write sink.
///
/// The delegate is typed as a plain `StreamSink<List<int>>` because
/// fs_shim 2.4.0's [fs.File.openWrite] returns that; strings are encoded
/// with the immutable [encoding] captured at open time. fs_shim sinks
/// flush pending writes on `add`/`close`, so [flush] only forwards to the
/// sink's own `flush()` when the runtime type has one.
class FsShimIOSink implements IOSink {
  FsShimIOSink(this._delegate, this._encoding);

  final StreamSink<List<int>> _delegate;
  final Encoding _encoding;

  @override
  Encoding get encoding => _encoding;

  @override
  set encoding(Encoding value) => unsupported('IOSink.encoding setter');

  @override
  Future get done => _delegate.done;

  @override
  void add(List<int> data) => _delegate.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _delegate.addError(error, stackTrace);

  @override
  Future addStream(Stream<List<int>> stream) => _delegate.addStream(stream);

  @override
  Future flush() async {
    final sink = _delegate as dynamic;
    try {
      await sink.flush();
    } on NoSuchMethodError {
      // Nothing to force: writes are already accepted by the sink.
    }
  }

  @override
  Future close() => _delegate.close();

  @override
  void write(Object? object) => _write('$object');

  @override
  void writeln([Object? object = '']) => _write('$object\n');

  @override
  void writeAll(Iterable objects, [String separator = '']) =>
      _write(objects.join(separator));

  @override
  void writeCharCode(int charCode) => _write(String.fromCharCode(charCode));

  void _write(String text) => _delegate.add(_encoding.encode(text));
}
