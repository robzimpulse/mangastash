class BrowseRoutePath {
  static const browse = '/browse_source';

  static const browseManga = '/browse_manga/${BrowsePathParam.source}';

  static String get mangaDetail => [
    'browse_manga',
    BrowsePathParam.source,
    BrowsePathParam.mangaId,
  ].join('/');

  static String get chapterDetail => [
    'browse_manga',
    BrowsePathParam.source,
    BrowsePathParam.mangaId,
    BrowsePathParam.chapterId,
  ].join('/');

  static const chapterConfig = '/manga_chapter_config';
  static const searchParam = '/manga_search_param';
  static const addManga = '/add_manga';
}

class BrowsePathParam {
  static const source = ':source';
  static const mangaId = ':mangaId';
  static const chapterId = ':chapterId';
}

class BrowseQueryParam {
  static const tagId = 'tagId';
}
