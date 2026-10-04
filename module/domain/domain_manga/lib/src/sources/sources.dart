import 'package:collection/collection.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import 'asura_scan_source_external.dart';
import 'manga_dex_source_external.dart';
import 'mangakatana_source_external.dart';
import 'manhua_plus_source_external.dart';
import 'weeb_central_source_external.dart';

class Sources {
  static List<SourceExternal> values = [
    MangaDexSourceExternal(),
    AsuraScanSourceExternal(),
    WeebCentralSourceExternal(),
    MangakatanaSourceExternal(),
    ManhuaPlusSourceExternal(),
    // Flame Comics and Isekai Scans were removed 2026-10 (#166): the
    // flamecomics.xyz site is gone (every domain redirects to a Discord
    // invite) and isekaiscans.org returns HTTP 522 (origin down). Restore
    // from git history only after verifying the site is back.
  ];

  static SourceExternal? fromName(String name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}
