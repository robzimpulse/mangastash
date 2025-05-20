import '../../domain_manga.dart';

extension SearchUrlMixin on SearchMangaParameter {
  String get mangaclash {
    return [
      [
        'https://toonclash.com',
        'page',
        '$page',
      ].join('/'),
      {
        's': title ?? '',
        'post_type': 'wp-manga',
        if (orders?.containsKey(SearchOrders.rating) == true)
          'm_orderby': 'rating',
        if (orders?.containsKey(SearchOrders.updatedAt) == true)
          'm_orderby': 'latest',
      }.entries.map((e) => '${e.key}=${e.value}').join('&'),
    ].join('?');
  }

  String get asurascan {
    return [
      [
        'https://asuracomic.net',
        'series',
      ].join('/'),
      {
        'name': title ?? '',
        'page': page,
        if (orders?.containsKey(SearchOrders.rating) == true) 'order': 'rating',
        if (orders?.containsKey(SearchOrders.updatedAt) == true)
          'order': 'update',
      }.entries.map((e) => '${e.key}=${e.value}').join('&'),
    ].join('?');
  }
}
