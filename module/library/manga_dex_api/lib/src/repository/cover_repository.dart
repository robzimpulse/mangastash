import '../enums/includes.dart';
import '../model/cover_art/cover_art_response.dart';
import '../service/cover_art_service.dart';

class CoverRepository {
  final CoverArtService _service;

  CoverRepository({
    required CoverArtService service,
  }) : _service = service;

  Future<CoverArtResponse> detail(String id, {List<Include>? includes}) {
    return _service.detail(
      id: id,
      includes: includes?.map((e) => e.rawValue).toList(),
    );
  }

  String coverUrl(String mangaId, String filename) {
    return 'https://uploads.mangadex.org/covers/$mangaId/$filename';
  }
}
