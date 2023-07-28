class CoverRepository {
  CoverRepository();

  String coverUrl(String mangaId, String filename) {
    return 'https://uploads.mangadex.org/covers/$mangaId/$filename';
  }
}
