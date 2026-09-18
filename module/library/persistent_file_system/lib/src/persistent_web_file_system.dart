import 'package:file/file.dart';
import 'package:fs_shim/fs_shim.dart' show fileSystemWeb;

import 'fs_shim_file_system.dart';

/// Persistent, IndexedDB-backed [FileSystem] for web builds (issue #104).
///
/// A single lazy instance shared by both web adapter seams
/// (`manga_service_drift` and the `core_storage` path manager) so the app
/// opens one IndexedDB connection. Accessing it off-web throws
/// `UnimplementedError` from fs_shim's `fileSystemWeb` stub — only the
/// `*_web.dart` conditional adapters may touch it.
final FileSystem persistentFileSystem = FsShimFileSystem(fileSystemWeb);
