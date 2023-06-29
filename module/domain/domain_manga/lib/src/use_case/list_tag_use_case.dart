import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class ListTagUseCase {
  final MangaRepository _mangaRepository;

  const ListTagUseCase({
    required MangaRepository mangaRepository,
  }) : _mangaRepository = mangaRepository;

  Future<Response<List<Tag>>> execute() async {
    try {
      final result = await _mangaRepository.tags();

      final tags = result.data?.map(
        (e) => Tag(id: e.id, name: e.attributes.name?.en),
      );

      return Success(tags?.toList() ?? []);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
