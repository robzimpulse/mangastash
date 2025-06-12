import 'package:core_environment/core_environment.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

extension SearchUrlMixin on SearchMangaParameter {
  String get mangaclash {
    return [
      [
        'https://toonclash.com',
        'page',
        '$page',
      ].join('/'),
      [
        const MapEntry('post_type', 'wp-manga'),
        MapEntry('s', title ?? ''),
        if (orders?.containsKey(SearchOrders.rating) == true)
          const MapEntry('m_orderby', 'rating'),
        if (orders?.containsKey(SearchOrders.updatedAt) == true)
          const MapEntry('m_orderby', 'latest'),
        for (final status in status ?? <MangaStatus>[])
          MapEntry(
            'status[]',
            switch (status) {
              MangaStatus.ongoing => 'on-going',
              MangaStatus.completed => 'end',
              MangaStatus.hiatus => 'on-hold',
              MangaStatus.cancelled => 'canceled',
            },
          ),
        for (final tag in includedTags ?? <String>[])
          MapEntry('genre[]', tag.toLowerCase().replaceAll(' ', '-')),
        if (includedTags?.isNotEmpty == true)
          includedTagsMode?.let(
                (value) => switch (value) {
              TagsMode.or => const MapEntry('op', ''),
              TagsMode.and => const MapEntry('op', '1'),
            },
          ),
      ].nonNulls.map((e) => '${e.key}=${e.value}').join('&'),
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
