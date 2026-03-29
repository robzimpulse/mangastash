import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenSourcesUseCase {
  ValueStream<List<SourceExternal>> get sourceStateStream;
}
