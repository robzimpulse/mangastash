import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/streams.dart';

abstract class ListenMangaFromLibraryUseCase {
  ValueStream<List<Manga>> get libraryStateStream;
  ValueStream<List<String>> get libraryIdsStateStream;
}