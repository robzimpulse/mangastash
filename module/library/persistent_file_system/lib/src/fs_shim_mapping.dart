import 'dart:async';
import 'dart:io' as io;

import 'package:fs_shim/fs_shim.dart' as fs;

/// Throws for members this backend cannot support (sync API, links, watch).
Never unsupported(String member) {
  throw UnsupportedError(
    '$member is not supported by the fs_shim (async-only) backend',
  );
}

/// Maps an fs_shim entity type to its dart:io equivalent; null → notFound.
io.FileSystemEntityType mapEntityType(fs.FileSystemEntityType? type) {
  switch (type) {
    case fs.FileSystemEntityType.file:
      return io.FileSystemEntityType.file;
    case fs.FileSystemEntityType.directory:
      return io.FileSystemEntityType.directory;
    case fs.FileSystemEntityType.link:
      return io.FileSystemEntityType.link;
    default:
      return io.FileSystemEntityType.notFound;
  }
}

/// Maps a dart:io open mode to its fs_shim equivalent.
fs.FileMode mapFileMode(io.FileMode mode) {
  if (identical(mode, io.FileMode.append)) {
    return fs.FileMode.append;
  }
  if (identical(mode, io.FileMode.write)) {
    return fs.FileMode.write;
  }
  return fs.FileMode.read;
}

/// Rewrites fs_shim errors into dart:io [io.FileSystemException]s so that
/// consumers catching the dart:io type keep working.
Object mapFsError(Object error) {
  if (error is fs.FileSystemException) {
    return io.FileSystemException(
      error.message,
      error.path,
      io.OSError(error.message, error.status ?? io.OSError.noErrorCode),
    );
  }
  return error;
}

/// Runs [body], rethrowing fs_shim errors as dart:io exceptions.
Future<T> guardFs<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on fs.FileSystemException catch (error) {
    throw mapFsError(error);
  }
}

/// Maps fs_shim stream errors to dart:io exceptions.
Stream<S> guardFsStream<S>(Stream<S> stream) {
  return stream.transform(
    StreamTransformer.fromHandlers(
      handleError: (error, stackTrace, sink) =>
          sink.addError(mapFsError(error), stackTrace),
    ),
  );
}
