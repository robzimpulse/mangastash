import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenSourcesUseCase {
  ValueStream<List<SourceEnum>> get sourceStateStream;
}
