import 'package:data_manga/data_manga.dart';
import 'package:rxdart/streams.dart';

abstract class ListenListTagUseCase {
  ValueStream<List<Tag>> get listTagsStream;
}