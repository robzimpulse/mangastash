import 'package:entity_manga/entity_manga.dart';

abstract class GetMangaTagUseCase {
  MangaTag? get(String id);
}