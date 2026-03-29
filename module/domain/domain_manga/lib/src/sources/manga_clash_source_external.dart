import 'package:collection/collection.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class MangaClashSourceExternal extends SourceExternal {
  @override
  String get baseUrl => 'https://mangaclash.com';

  @override
  String get iconUrl => '$baseUrl/wp-content/uploads/2020/03/cropped-22.jpg';

  @override
  String get name => 'Manga Clash';

  @override
  bool get builtIn => false;

  @override
  GetChapterImageSourceExternalUseCase get getChapterImageUseCase =>
      _GetChapterImageSourceExternalUseCase();

  @override
  GetMangaSourceExternalUseCase get getMangaUseCase =>
      _GetMangaSourceExternalUseCase();

  @override
  ListChapterSourceExternalUseCase get listChapterUseCase =>
      _ListChapterSourceExternalUseCase();

  @override
  SearchMangaSourceExternalUseCase get searchMangaUseCase =>
      _SearchMangaSourceExternalUseCase(baseUrl);

  @override
  ListTagSourceExternalUseCase get listTagUseCase =>
      _ListTagSourceExternalUseCase();
}

class _GetChapterImageSourceExternalUseCase
    implements GetChapterImageSourceExternalUseCase {
  @override
  Future<List<String>> parse({required Document root}) async {
    final region = root.querySelector('.reading-content');
    final containers = region?.querySelectorAll('img') ?? [];
    final List<(num, String)> data = [];
    for (final image in containers) {
      final id = image.attributes['id']?.split('-').lastOrNull;
      if (id == null) continue;
      final url = image.attributes['data-src'];
      final index = int.tryParse(id);
      if (index == null || url == null) continue;
      data.add((index, url.trim()));
    }
    return data.sortedBy((e) => e.$1).map((e) => e.$2).toList();
  }

  @override
  // TODO: implement scripts
  List<String> get scripts => [];
}

class _GetMangaSourceExternalUseCase implements GetMangaSourceExternalUseCase {
  @override
  Future<MangaScrapped> parse({required Document root}) async {
    final description = root
        .querySelector('div.description-summary')
        ?.querySelectorAll('p')
        .map((e) => e.text.trim())
        .join('\n\n');

    final title = root.querySelector('div.post-title')?.text.trim();

    final authors = root.querySelector('div.author-content')?.text.trim();

    final coverUrl =
        root
            .querySelector('div.summary_image')
            ?.querySelector('img')
            ?.attributes['src'];

    final tags = root
        .querySelector('div.genres-content')
        ?.text
        .trim()
        .split(',');

    return MangaScrapped(
      title: title,
      author: authors,
      coverUrl: coverUrl,
      description: description,
      tags: tags?.toList(),
    );
  }

  @override
  // TODO: implement scripts
  List<String> get scripts => [];
}

class _ListChapterSourceExternalUseCase
    implements ListChapterSourceExternalUseCase {
  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final List<ChapterScrapped> data = [];

    for (final element in root.querySelectorAll('li.wp-manga-chapter')) {
      final url = element.querySelector('a')?.attributes['href'];
      final title = element.querySelector('a')?.text.split('-').lastOrNull;
      final text = element.querySelector('a')?.text.split(' ').map((text) {
        final value = double.tryParse(text);

        if (value != null) {
          final fraction = value - value.truncate();
          if (fraction > 0.0) return value;
        }

        return int.tryParse(text);
      });
      final releaseDate =
          element.querySelector('.chapter-release-date')?.text.trim();
      final chapter = text?.nonNulls.firstOrNull;

      data.add(
        ChapterScrapped(
          title: title?.trim(),
          chapter: chapter != null ? '$chapter' : null,
          readableAt: releaseDate,
          webUrl: url,
        ),
      );
    }
    return data;
  }

  @override
  // TODO: implement scripts
  List<String> get scripts => [];
}

class _SearchMangaSourceExternalUseCase
    implements SearchMangaSourceExternalUseCase {
  final String _baseUrl;

  const _SearchMangaSourceExternalUseCase(this._baseUrl);

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    final values =
        root
            .querySelector('.wp-pagenavi')
            ?.querySelector('.pages')
            ?.text
            .split(' ')
            .map((e) => int.tryParse(e))
            .nonNulls;

    return values?.firstOrNull != values?.lastOrNull;
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    final List<MangaScrapped> mangas = [];
    for (final element in root.querySelectorAll('.c-tabs-item__content')) {
      final title = element.querySelector('div.post-title')?.text.trim();
      final webUrl =
          element
              .querySelector('div.post-title')
              ?.querySelector('a')
              ?.attributes['href']
              ?.trim();
      final coverUrl =
          element
              .querySelector('.tab-thumb')
              ?.querySelector('img')
              ?.attributes['data-src']
              ?.trim();
      final genres = element
          .querySelector('div.post-content_item.mg_genres')
          ?.querySelector('div.summary-content')
          ?.text
          .split(',');
      final status =
          element
              .querySelector('div.post-content_item.mg_status')
              ?.querySelector('div.summary-content')
              ?.text
              .trim();

      mangas.add(
        MangaScrapped(
          title: title,
          coverUrl: coverUrl,
          webUrl: webUrl,
          status: status,
          tags: genres?.toList(),
        ),
      );
    }
    return mangas;
  }

  @override
  // TODO: implement scripts
  List<String> get scripts => [];

  @override
  String url({required SearchMangaParameter parameter}) {
    return [
      [_baseUrl, 'page', '${parameter.page}'].join('/'),
      [
        const MapEntry('post_type', 'wp-manga'),
        MapEntry('s', parameter.title ?? ''),
        if (parameter.orders?.containsKey(SearchOrders.rating) == true)
          const MapEntry('m_orderby', 'rating'),
        if (parameter.orders?.containsKey(SearchOrders.updatedAt) == true)
          const MapEntry('m_orderby', 'latest'),
        for (final status in parameter.status ?? <MangaStatus>[])
          MapEntry('status[]', switch (status) {
            MangaStatus.ongoing => 'on-going',
            MangaStatus.completed => 'end',
            MangaStatus.hiatus => 'on-hold',
            MangaStatus.cancelled => 'canceled',
          }),
        for (final tag in parameter.includedTags ?? <String>[])
          MapEntry('genre[]', tag),
        if (parameter.includedTags?.isNotEmpty == true)
          switch (parameter.includedTagsMode) {
            TagsMode.or => const MapEntry('op', ''),
            TagsMode.and => const MapEntry('op', '1'),
          },
      ].nonNulls.map((e) => '${e.key}=${e.value}').join('&'),
    ].join('?');
  }
}

class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {
  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    final region = root.querySelector('div.form-group.checkbox-group.row');

    return [
      for (final child in [...?region?.children])
        TagScrapped(
          id: child.querySelector('input')?.attributes['value'],
          name: child.text.trim(),
        ),
    ];
  }

  @override
  // TODO: implement scripts
  List<String> get scripts => [];
}
