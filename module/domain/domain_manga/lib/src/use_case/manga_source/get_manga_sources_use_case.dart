import 'package:entity_manga/entity_manga.dart';

abstract class GetMangaSourcesUseCase {
  Map<String, MangaSource> get mangaSourceState;
}
