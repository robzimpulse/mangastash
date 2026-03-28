import 'package:entity_manga_external/entity_manga_external.dart';

import 'asura_scan_source_external.dart';
import 'manga_clash_source_external.dart';
import 'manga_dex_source_external.dart';

class Sources {
  static List<SourceExternal> all = [
    MangaDexSourceExternal(),
    AsuraScanSourceExternal(),
    MangaClashSourceExternal(),
  ];
}
