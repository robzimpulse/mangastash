import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/streams.dart';

abstract class ListenListTagUseCaseDeprecated {
  ValueStream<List<MangaTagDeprecated>> get listTagsStream;
}
