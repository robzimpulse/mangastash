import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenMangaTagUseCase {
  ValueStream<Map<String, MangaTag>> get mangaTagStateStream;
}