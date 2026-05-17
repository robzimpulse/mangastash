import 'package:entity_manga_external/entity_manga_external.dart';

import 'asura_scan_source_external.dart';
import 'manga_clash_source_external.dart';
import 'manga_dex_source_external.dart';

abstract class BuiltInSourceProvider {
  List<SourceExternal> get sources;
  SourceExternal? fromName(String name);
}

class BuiltInSourceProviderImpl implements BuiltInSourceProvider {
  @override
  List<SourceExternal> get sources => [
    MangaDexSourceExternal(),
    AsuraScanSourceExternal(),
    MangaClashSourceExternal(),
  ];

  @override
  SourceExternal? fromName(String name) {
    for (final source in sources) {
      if (source.name == name) {
        return source;
      }
    }
    return null;
  }
}
