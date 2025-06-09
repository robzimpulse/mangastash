import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenMangaSourceUseCase {
  ValueStream<Map<String, Source>> get mangaSourceStateStream;
}