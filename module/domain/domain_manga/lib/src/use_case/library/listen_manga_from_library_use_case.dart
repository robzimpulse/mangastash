import 'package:entity_manga/entity_manga.dart';

abstract class ListenMangaFromLibraryUseCase {
  Stream<List<Manga>> get libraryStateStream;
  Stream<Set<String>> get libraryMangaIds;
}
