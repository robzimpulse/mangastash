import '../../domain_manga.dart';

class SearchMangaUseCase {

  final SearchRepository _searchRepository;

  const SearchMangaUseCase({
    required SearchRepository searchRepository,
  }): _searchRepository = searchRepository;

  Future<void> execute() async {

  }

}