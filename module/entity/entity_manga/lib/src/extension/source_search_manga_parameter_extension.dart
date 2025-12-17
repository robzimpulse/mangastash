import 'package:core_environment/core_environment.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../enum/source_enum.dart';
import '../source_search_manga_parameter.dart';

extension SearchUrlExtension on SourceSearchMangaParameter {
  Uri? get uri => url?.let((e) => Uri.tryParse(e));

  String? get url {
    switch (source) {
      case SourceEnum.mangadex:
        // mangadex provider using API
        return null;
      case SourceEnum.mangaclash:
        return [
          ['https://toonclash.com', 'page', '${parameter.page}'].join('/'),
          [
            const MapEntry('post_type', 'wp-manga'),
            MapEntry('s', parameter.title ?? ''),
            if (parameter.orders?.containsKey(SearchOrders.rating) == true)
              const MapEntry('m_orderby', 'rating'),
            if (parameter.orders?.containsKey(SearchOrders.updatedAt) == true)
              const MapEntry('m_orderby', 'latest'),
            for (final status in parameter.status ?? <MangaStatus>[])
              MapEntry(
                'status[]',
                switch (status) {
                  MangaStatus.ongoing => 'on-going',
                  MangaStatus.completed => 'end',
                  MangaStatus.hiatus => 'on-hold',
                  MangaStatus.cancelled => 'canceled',
                },
              ),
            for (final tag in parameter.includedTags ?? <String>[])
              MapEntry('genre[]', tag),
            if (parameter.includedTags?.isNotEmpty == true)
              switch (parameter.includedTagsMode) {
                TagsMode.or => const MapEntry('op', ''),
                TagsMode.and => const MapEntry('op', '1'),
              },
          ].nonNulls.map((e) => '${e.key}=${e.value}').join('&'),
        ].join('?');
      case SourceEnum.asurascan:
        return [
          ['https://asuracomic.net', 'series'].join('/'),
          [
            MapEntry('name', parameter.title ?? ''),
            MapEntry('page', parameter.page),
            if (parameter.orders?.containsKey(SearchOrders.rating) == true)
              const MapEntry('order', 'rating'),
            if (parameter.orders?.containsKey(SearchOrders.updatedAt) == true)
              const MapEntry('order', 'update'),
            if (parameter.includedTags?.isNotEmpty == true)
              MapEntry('genres', [...?parameter.includedTags].join(',')),
          ].map((e) => '${e.key}=${e.value}').join('&'),
        ].join('?');
    }
  }
}
