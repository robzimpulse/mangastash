// `Uri.source`: the registered source whose base URL host matches this URI
// (e.g. a pasted series link), resolved through the SourceRegistry bound to
// the `Sources` facade (issue #115).
//
// Usage: `Uri.tryParse(link)?.source` → SourceExternal or null.
import 'package:entity_manga_external/entity_manga_external.dart';

import '../sources/sources.dart';

extension SourceOfUri on Uri {
  SourceExternal? get source => Sources.fromHost(host);
}
