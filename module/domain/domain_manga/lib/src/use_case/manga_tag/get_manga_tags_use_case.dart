import 'package:entity_manga/entity_manga.dart';

abstract class GetMangaTagsUseCase {
  Map<String, MangaTag> get mangaTagState;
}