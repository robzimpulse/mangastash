import 'package:entity_manga/entity_manga.dart';

abstract class GetMangaSourceUseCase {
  Source? get(String name);
}