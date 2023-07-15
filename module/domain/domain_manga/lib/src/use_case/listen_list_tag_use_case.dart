import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/streams.dart';

abstract class ListenListTagUseCase {
  ValueStream<List<MangaTag>> get listTagsStream;
}