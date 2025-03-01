import 'package:rxdart/streams.dart';

abstract class ListenMangaFromLibraryUseCase {
  ValueStream<List<String>> get libraryStateStream;
}