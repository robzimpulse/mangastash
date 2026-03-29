import 'package:entity_manga_external/entity_manga_external.dart';

import '../sources/sources.dart';

extension SourceOfUri on Uri {
  SourceExternal? get source {
    for (final source in Sources.values) {
      if (Uri.tryParse(source.baseUrl)?.host == host) {
        return source;
      }
    }

    return null;
  }
}
