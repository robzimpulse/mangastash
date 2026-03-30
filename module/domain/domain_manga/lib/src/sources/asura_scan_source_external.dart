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
  // TODO: implement scripts
  List<String> get scripts => [];
}

class _GetMangaSourceExternalUseCase implements GetMangaSourceExternalUseCase {
  @override
  Future<MangaScrapped> parse({required Document root}) async {
    final region = root.querySelector('div.px-4.py-5');

    final area = region?.querySelector('div.flex.gap-3.mb-4');
    final coverUrl = area?.querySelector('img')?.attributes['src'];
    final title = area?.querySelector('h2.font-bold.text-base.line-clamp-2');
    final description = region?.querySelector(
      'div.text-xs.leading-relaxed.prose.prose-invert.max-w-full',
    );

    final attributes = region?.querySelectorAll(
      'div.flex.items-center.justify-between.rounded.px-4',
    );

    final rows = attributes?.map((e) {
      final key = e.querySelector('div.flex.items-center.gap-2')?.text.trim();
      final value = e.querySelector('span.text-sm.font-medium')?.text.trim();
      if (key == null || value == null) return null;
      return MapEntry(key, value);
    });

    final genres = region?.querySelector(
      'div.flex.flex-wrap.gap-2.text-xs.mt-4',
    );

    final data = MangaScrapped(
      title: title?.text.trim(),
      author: rows?.nonNulls.firstOrNull?.value,
      description: description?.text.trim(),
      coverUrl: coverUrl,
      tags: genres?.children.map((e) => e.text.trim()).toList(),
    );

    return data;
  }

  @override
  List<String> get scripts {
    final selector = [
      'div',
      'flex',
      'z-10',
      'relative',
      'mt-2',
      'justify-end',
    ].join('.');

    final script = [
      'window',
      'document',
      'querySelectorAll(\'$selector\')[0]',
      'querySelector(\'button\')',
      'click()',
    ].join('.');

    return [script];
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
  // TODO: implement scripts
  List<String> get scripts => [];
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
  // TODO: implement scripts
  List<String> get scripts => [];

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
  // TODO: implement scripts
  List<String> get scripts => [];
}
