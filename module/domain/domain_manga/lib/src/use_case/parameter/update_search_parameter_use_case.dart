import 'package:manga_dex_api/manga_dex_api.dart';

abstract class UpdateSearchParameterUseCase {
  void updateSearchParameter({
    required SearchMangaParameter parameter,
  });
}