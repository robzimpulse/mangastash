import 'package:entity_manga/entity_manga.dart';

abstract class GetMangaFromLibraryUseCase {
  Future<List<Manga>> get libraryState;
}