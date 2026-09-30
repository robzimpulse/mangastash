/// package:file compatible filesystem backed by fs_shim.
library;

export 'src/fs_shim_directory.dart';
export 'src/fs_shim_file.dart';
export 'src/fs_shim_file_stat.dart';
export 'src/fs_shim_file_system.dart';
export 'src/fs_shim_io_sink.dart';
export 'src/fs_shim_link.dart';
export 'src/fs_shim_mapping.dart';

// `persistent_web_file_system.dart` (the `persistentFileSystem` singleton)
// is deliberately NOT exported: it throws `UnimplementedError` off-web, so
// only the conditional `*_web.dart` adapters may import it — from
// `package:persistent_file_system/src/persistent_web_file_system.dart`.
