import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

abstract class GetMangaSourceUseCase {
  MangaSource? get(MangaSourceEnum source);
}