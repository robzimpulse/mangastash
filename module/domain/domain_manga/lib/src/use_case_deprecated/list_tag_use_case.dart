import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class ListTagUseCaseDeprecated {
  final MangaRepository _repository;

  const ListTagUseCaseDeprecated({
    required MangaRepository repository,
  }) : _repository = repository;

  Future<Result<List<MangaTagDeprecated>>> execute() async {
    try {
      final result = await _repository.tags();

      final tags = result.data?.map(
        (e) => MangaTagDeprecated(
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
