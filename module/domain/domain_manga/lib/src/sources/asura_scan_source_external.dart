import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class AsuraScanSourceExternal implements SourceExternal {
  @override
  String get baseUrl => 'https://asurascans.com';

  @override
  String get iconUrl => '$baseUrl/images/logo.webp';

  @override
  String get name => 'Asura Scans';

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
      _ListChapterSourceExternalUseCase(name);

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
    final region = root.querySelector(
      'div.py-8.-mx-5.flex.flex-col.items-center.justify-center',
    );
    final containers = region?.querySelectorAll('img') ?? [];
    final List<(num, String)> data = [];
    for (final image in containers) {
      final id = image.attributes['alt']?.split(' ').lastOrNull;
      if (id == null) continue;
      final url = image.attributes['src'];
      final index = int.tryParse(id);
      if (index == null || url == null) continue;
      data.add((index, url.trim()));
    }
    return data.sortedBy((e) => e.$1).map((e) => e.$2).toList();
  }

  @override
  List<String> get scripts {
    final selector = [
      'button',
      'inline-flex',
      'items-center',
      'whitespace-nowrap',
      'px-4',
      'py-2',
      'w-full',
      'justify-center',
      'font-normal',
      'align-middle',
      'border-solid',
    ].join('.');

    return ['window.document.querySelectorAll(\'$selector\')[0].click()'];
  }
}

class _GetMangaSourceExternalUseCase implements GetMangaSourceExternalUseCase {
  @override
  Future<MangaScrapped> parse({required Document root}) async {
    final query = ['div', 'float-left', 'relative', 'z-0'].join('.');
    final region = root.querySelector(query);

    final title = region?.querySelector('span.text-xl.font-bold')?.text.trim();

    final description =
        region?.querySelector('span.font-medium.text-sm')?.text.trim();

    final mQuery = ['div.grid', 'grid-cols-1', 'gap-5', 'mt-8'].join('.');
    final metas = region?.querySelector(mQuery)?.children.map((e) {
      final first = e.querySelector('h3.font-medium.text-sm');
      return MapEntry(
        first?.text.trim(),
        first?.nextElementSibling?.text.trim(),
      );
    });
    final metadata = Map.fromEntries(metas ?? <MapEntry<String?, String>>[]);
    final author = metadata['Author'];
    final genres = region
        ?.querySelector('div.space-y-1.pt-4')
        ?.querySelector('div.flex.flex-row.flex-wrap.gap-3')
        ?.children
        .map((e) => e.text.trim());

    final coverUrl =
        region
            ?.querySelector('div.relative.col-span-full.space-y-3.px-6')
            ?.querySelector('img')
            ?.attributes['src'];

    return MangaScrapped(
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl,
      tags: genres?.toList(),
    );
  }

  @override
  List<String> get scripts {
    final selector = [
      'button',
      'inline-flex',
      'items-center',
      'whitespace-nowrap',
      'px-4',
      'py-2',
      'w-full',
      'justify-center',
      'font-normal',
      'align-middle',
      'border-solid',
    ].join('.');

    return ['window.document.querySelectorAll(\'$selector\')[0].click()'];
  }
}

class _ListChapterSourceExternalUseCase
    implements ListChapterSourceExternalUseCase {
  final String _name;

  const _ListChapterSourceExternalUseCase(this._name);

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final region = root.querySelector(
      [
        'div',
        'pl-4',
        'pr-2',
        'pb-4',
        'overflow-y-auto',
        'scrollbar-thumb-themecolor',
        'scrollbar-track-transparent',
        'scrollbar-thin',
        'mr-3',
      ].join('.'),
    );

    final List<ChapterScrapped> data = [];
    for (final element in region?.children ?? <Element>[]) {
      final url = element.querySelector('a')?.attributes['href'];

      final container = element.querySelector(
        [
          'h3',
          'text-sm',
          'text-white',
          'font-medium',
          'flex',
          'flex-row',
        ].join('.'),
      );

      final spans = container?.querySelectorAll('span');
      final title = spans?.firstOrNull?.text.trim();
      final isNotPublished = spans?.lastOrNull?.hasChildNodes() == true;

      if (isNotPublished) continue;

      final chapterData = container?.nodes.firstOrNull?.text?.trim().split(' ');
      final chapter =
          chapterData?.map((text) {
            final value = double.tryParse(text);
            if (value != null) {
              final fraction = value - value.truncate();
              if (fraction > 0.0) return value;
            }
            return int.tryParse(text);
          }).lastOrNull;

      final releaseDate = element
          .querySelector('h3.text-xs')
          ?.text
          .trim()
          .replaceAll('st', '')
          .replaceAll('nd', '')
          .replaceAll('rd', '')
          .replaceAll('th', '');

      data.add(
        ChapterScrapped(
          title: title?.isNotEmpty == true ? title : null,
          chapter: '${chapter ?? url?.split('/').lastOrNull}',
          readableAt: releaseDate,
          webUrl: ['https://asuracomic.net', 'series', url].join('/'),
          scanlationGroup: _name,
        ),
      );
    }

    return data;
  }

  @override
  List<String> get scripts {
    final selector = [
      'button',
      'inline-flex',
      'items-center',
      'whitespace-nowrap',
      'px-4',
      'py-2',
      'w-full',
      'justify-center',
      'font-normal',
      'align-middle',
      'border-solid',
    ].join('.');

    return ['window.document.querySelectorAll(\'$selector\')[0].click()'];
  }
}

class _SearchMangaSourceExternalUseCase
    implements SearchMangaSourceExternalUseCase {
  final String _baseUrl;

  const _SearchMangaSourceExternalUseCase(this._baseUrl);

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    final queries = [
      'nav',
      'flex',
      'items-center',
      'justify-center',
      'mt-8',
      'pb-8',
    ].join('.');

    final region = root.querySelector(queries);
    final buttons = region?.querySelectorAll('button');
    final nextButton = buttons?.firstWhereOrNull(
      (e) => e.attributes['aria-label'] == 'Next page',
    );

    return nextButton != null && !nextButton.attributes.containsKey('disabled');
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    final queries = [
      'div',
      'series-card',
      'group',
      'rounded-lg',
      'overflow-hidden',
      'transition-all',
      'duration-200',
    ].join('.');

    final region = root.querySelectorAll(queries);

    final mangas = region.map((e) {
      final container = e.querySelector('div.p-3');
      final link = container?.querySelector('a');

      final coverUrl =
          e.querySelector('a')?.querySelector('img')?.attributes['src'];
      final webUrl = link.let((e) => [_baseUrl, e.attributes['href']].join(''));
      final status = container
          ?.querySelector('div.flex.items-center.gap-2.mt-2')
          .let(
            (e) => e.querySelector(
              'span.text-xs.font-medium.px-2.py-1.rounded.capitalize',
            ),
          );

      return MangaScrapped(
        title: link?.text.trim(),
        coverUrl: coverUrl,
        webUrl: webUrl,
        status: status?.text.trim(),
      );
    });

    return mangas.nonNulls.toList();
  }

  @override
  List<String> get scripts {
    final selector = [
      'button',
      'inline-flex',
      'items-center',
      'whitespace-nowrap',
      'px-4',
      'py-2',
      'w-full',
      'justify-center',
      'font-normal',
      'align-middle',
      'border-solid',
    ].join('.');

    return ['window.document.querySelectorAll(\'$selector\')[0].click()'];
  }

  @override
  String url({required SearchMangaParameter parameter}) {
    final order = parameter.orders?.entries.firstOrNull.let(
      (entry) => switch (entry.key) {
        SearchOrders.title => [
          const MapEntry('sort', 'name'),
          MapEntry('order', entry.value.rawValue),
        ],
        SearchOrders.relevance => [
          const MapEntry('sort', 'popular'),
          MapEntry('order', entry.value.rawValue),
        ],
        SearchOrders.rating => [
          const MapEntry('sort', 'rating'),
          MapEntry('order', entry.value.rawValue),
        ],
        _ => [MapEntry('order', entry.value.rawValue)],
      },
    );

    return [
      [_baseUrl, 'browse'].join('/'),
      [
        MapEntry('q', parameter.title ?? ''),
        MapEntry('page', parameter.page),
        if (order != null) ...order,
        if (parameter.includedTags?.isNotEmpty == true)
          MapEntry('genres', [...?parameter.includedTags].join(',')),
        if (parameter.status?.isNotEmpty == true)
          MapEntry(
            'status',
            [...?parameter.status?.map((e) => e.rawValue)].join(','),
          ),
      ].map((e) => '${e.key}=${e.value}').join('&'),
    ].join('?');
  }
}

class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {
  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    final region = root.querySelector('form#hook-form');

    final elements = region?.querySelectorAll(
      'div.flex.flex-row.items-start.space-x-1.space-y-0',
    );

    return [
      for (final (index, element) in [...?elements].indexed)
        TagScrapped(
          id: (index + 1).toString(),
          name: element.querySelector('label')?.text.trim(),
        ),
    ];
  }

  @override
  List<String> get scripts {
    final selector = [
      'button',
      'inline-flex',
      'items-center',
      'whitespace-nowrap',
      'px-4',
      'py-2',
      'w-full',
      'justify-center',
      'font-normal',
      'align-middle',
      'border-solid',
    ].join('.');

    return ['window.document.querySelectorAll(\'$selector\')[0].click()'];
  }
}
