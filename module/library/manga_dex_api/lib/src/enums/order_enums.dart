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

  factory SearchOrders.fromRawValue(String rawValue) {
    return SearchOrders.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => SearchOrders.rating,
    );
  }
}

enum AuthorOrders {
  name('name');

  final String rawValue;

  const AuthorOrders(this.rawValue);

  factory AuthorOrders.fromRawValue(String rawValue) {
    return AuthorOrders.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => AuthorOrders.name,
    );
  }
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

  factory ChapterOrders.fromRawValue(String rawValue) {
    return ChapterOrders.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => ChapterOrders.chapter,
    );
  }
}

enum CoverOrders {
  createdAt('createdAt'),
  updatedAt('updatedAt'),
  volume('volume');

  final String rawValue;

  const CoverOrders(this.rawValue);

  factory CoverOrders.fromRawValue(String rawValue) {
    return CoverOrders.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => CoverOrders.volume,
    );
  }
}

enum OrderDirections {
  ascending('asc'),
  descending('desc');

  final String rawValue;

  const OrderDirections(this.rawValue);

  factory OrderDirections.fromRawValue(String rawValue) {
    return OrderDirections.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => OrderDirections.descending,
    );
  }
}

enum ScanlationOrders {
  name('name'),
  createdAt('createdAt'),
  updatedAt('updatedAt'),
  followedCount('followedCount'),
  relevance('relevance');

  final String rawValue;

  const ScanlationOrders(this.rawValue);

  factory ScanlationOrders.fromRawValue(String rawValue) {
    return ScanlationOrders.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => ScanlationOrders.relevance,
    );
  }
}
