import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class ListTagUseCase {
  final MangaRepository _repository;

  const ListTagUseCase({
    required MangaRepository repository,
  }) : _repository = repository;

  Future<Response<List<MangaTag>>> execute() async {
    try {
      final result = await _repository.tags();

      final tags = result.data?.map(
        (e) => MangaTag(
          id: e.id,
          name: e.attributes?.name?.en,
          group: e.attributes?.group,
        ),
      );

      return Success(tags?.toList() ?? []);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
