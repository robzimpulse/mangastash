import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenMangaChapterConfig {
  ValueStream<MangaChapterConfig> get mangaChapterConfigStream;
}
