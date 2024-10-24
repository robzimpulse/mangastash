import 'package:entity_manga/entity_manga.dart';

abstract class GetMangaSourceUseCase {
  MangaSource? get(String? id);
}