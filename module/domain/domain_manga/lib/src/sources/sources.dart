import 'package:collection/collection.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import 'asura_scan_source_external.dart';
import 'manga_dex_source_external.dart';
import 'mangakatana_source_external.dart';
import 'manganato_source_external.dart';
import 'weeb_central_source_external.dart';

class Sources {
  static List<SourceExternal> values = [
    MangaDexSourceExternal(),
    AsuraScanSourceExternal(),
    WeebCentralSourceExternal(),
    ManganatoSourceExternal(),
    MangakatanaSourceExternal(),
  ];

  static SourceExternal? fromName(String name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}
