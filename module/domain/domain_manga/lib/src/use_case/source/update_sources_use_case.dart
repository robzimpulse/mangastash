import 'package:entity_manga_external/entity_manga_external.dart';

abstract class UpdateSourcesUseCase {
  Future<void> updateSources({required List<SourceExternal> sources});
}
