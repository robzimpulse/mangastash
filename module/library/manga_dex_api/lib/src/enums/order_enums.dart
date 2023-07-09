enum SearchOrders {
  title('title'),
  year('year'),
  createdAt('createdAt'),
  updatedAt('updatedAt'),
  latestUploadedChapter('latestUploadedChapter'),
  followedCount('followedCount'),
  relevance('relevance'),
  rating('rating');

  final String rawValue;

  const SearchOrders(this.rawValue);
}

enum AuthorOrders {
  name('name');

  final String rawValue;

  const AuthorOrders(this.rawValue);
}

enum ChapterOrders {
  createdAt('createdAt'),
  updatedAt('updatedAt'),
  publishAt('publishAt'),
  readableAt('readableAt'),
  volume('volume'),
  chapter('chapter');

  final String rawValue;

  const ChapterOrders(this.rawValue);
}

enum CoverOrders {
  createdAt('createdAt'),
  updatedAt('updatedAt'),
  volume('volume');

  final String rawValue;

  const CoverOrders(this.rawValue);
}

enum OrderDirections {
  ascending('asc'),
  descending('desc');

  final String rawValue;

  const OrderDirections(this.rawValue);
}

enum ScanlationOrders {
  name('name'),
  createdAt('createdAt'),
  updatedAt('updatedAt'),
  followedCount('followedCount'),
  relevance('relevance');

  final String rawValue;

  const ScanlationOrders(this.rawValue);
}
