import 'package:data_manga/data_manga.dart';

abstract class GetMangaSourcesUseCase {
  Map<String, MangaSourceFirebase> get mangaSourceState;
}
