import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';

extension SourceOfUri on Uri {
  SourceEnum? get source {
    for (final source in SourceEnum.values) {
      if (source.url.let(Uri.tryParse)?.host == host) {
        return source;
      }
    }

    return null;
  }
}