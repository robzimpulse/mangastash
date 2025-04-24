import 'package:data_manga/data_manga.dart';

abstract class GetMangaSourcesUseCase {
  Map<String, MangaSource> get mangaSourceState;
}
