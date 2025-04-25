import 'package:entity_manga/entity_manga.dart';

abstract class GetMangaSourceUseCase {
  MangaSource? get(MangaSourceEnum source);
}