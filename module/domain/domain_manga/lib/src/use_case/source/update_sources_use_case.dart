import 'package:entity_manga/entity_manga.dart';

abstract class UpdateSourcesUseCase {
  void updateSources({required List<SourceEnum> sources});
}
