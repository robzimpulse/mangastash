class BrowseRoutePath {
  static const browse = '/browse_source';
  static const browseManga = '/browse_manga/:$sourceQuery';
  static const mangaDetail = '/browse_manga/:$sourceQuery/:$mangaIdQuery';
  static const chapterDetail =
      '/browse_manga/:$sourceQuery/:$mangaIdQuery/:$chapterIdQuery';
  static const chapterConfig = '/manga_chapter_config';
  static const searchParam = '/manga_search_param';
  static const addManga = '/add_manga';

  static const sourceQuery = 'source';
  static const mangaIdQuery = 'mangaId';
  static const chapterIdQuery = 'chapterId';
  static const tagIdQuery = 'tagId';
}
