import 'package:data_manga/data_manga.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenMangaSourceUseCase {
  ValueStream<Map<String, MangaSourceFirebase>> get mangaSourceStateStream;
}