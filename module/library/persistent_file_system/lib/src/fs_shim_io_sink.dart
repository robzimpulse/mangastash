import 'dart:async';
import 'dart:convert';
import 'dart:io' show IOSink;

import 'package:fs_shim/fs_shim.dart' as fs;

import 'fs_shim_mapping.dart';

/// dart:io [IOSink] over an fs_shim write sink.
///
/// The delegate is typed as a plain `StreamSink<List<int>>` because
/// fs_shim 2.4.0's [fs.File.openWrite] returns that; strings are encoded
/// with the immutable [encoding] captured at open time.
class FsShimIOSink implements IOSink {
  FsShimIOSink(this._delegate, this._encoding) {
    // fs_shim's write sinks persist on `add`/`close`; the idb backend
    // additionally exposes a real `flush()`. Probe for the tear-off once so
    // an error thrown *inside* a real flush propagates instead of being
    // mistaken for a missing method.
    try {
      _flush = (_delegate as dynamic).flush as Future<void> Function()?;
    } on NoSuchMethodError {
      _flush = null;
    }
  }

  final StreamSink<List<int>> _delegate;
  final Encoding _encoding;
  Future<void> Function()? _flush;

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
    final flush = _flush;
    if (flush != null) await flush();
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
