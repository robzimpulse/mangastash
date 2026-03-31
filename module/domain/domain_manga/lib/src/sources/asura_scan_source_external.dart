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
      _ListChapterSourceExternalUseCase(baseUrl, name);

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
    final regions = root.querySelectorAll(
      [
        'div.min-h-screen.bg-black',
        'div.select-none',
        'div.max-w-full.mx-auto.overflow-hidden.flex.flex-col',
        'div.relative.w-full',
        'img.w-full.block.relative.z-10',
      ].join(' > '),
    );

    return regions.map((e) => e.attributes['src']).nonNulls.toList();
  }

  @override
  List<String> get scripts {
    final query = [
      'div.min-h-screen.bg-black',
      'div.select-none',
      'div.max-w-full.mx-auto.overflow-hidden.flex.flex-col',
      'div.relative.w-full',
    ].join(' > ');

    return [
      'var elements = document.querySelectorAll(\'$query\');',
      '''
      for (let i = 0; i < elements.length; i++) {
        setTimeout(() => elements[i].scrollIntoView(), 100 * i);
      }
      ''',
    ];
  }
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

    return MangaScrapped(
      title: title?.text.trim(),
      author: rows?.nonNulls.firstOrNull?.value,
      description: description?.text.trim(),
      coverUrl: coverUrl,
      tags: genres?.children.map((e) => e.text.trim()).toList(),
    );
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
  final String _baseUrl;

  const _ListChapterSourceExternalUseCase(this._baseUrl, this._name);

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final regions = root.querySelectorAll(
      'a.group.flex.items-center.justify-between.px-4.py-4.transition-colors',
    );

    final chapters = regions.map((e) {
      final isLocked = e.attributes['class']?.contains(
        'bg-gradient-to-r from-amber-500/5 to-transparent',
      );
      if (isLocked == true) return null;

      final title = e.querySelector(
        [
          'div.flex.items-center.gap-3.min-w-0.flex-1',
          'div.min-w-0.flex-1',
          'div.flex.items-center.gap-2',
        ].join(' > '),
      );
      final date = e.querySelector('div.flex-shrink-0.ml-3.text-right');

      return ChapterScrapped(
        title: title?.text.trim(),
        chapter: title?.text.trim().split(' ').lastOrNull,
        readableAt: date?.text.trim(),
        webUrl: e.attributes['href'].let((e) => [_baseUrl, e].join('')),
        scanlationGroup: _name,
      );
    });

    final data = chapters.nonNulls.toList();

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
    final genreQuery = [
      'div.flex-1.overflow-y-auto',
      'div',
      'div',
      [
        'div',
        'absolute',
        'top-full',
        'left-0',
        'right-0',
        'mt-2',
        'border',
        'rounded-md',
        'shadow-lg',
        'z-50',
      ].join('.'),

      'div.p-1',
      'div.space-y-1.px-1.py-1.overflow-y-auto',
      'div',
      'span',
    ].join(' > ');

    final regions = root.querySelectorAll(genreQuery);

    final tags = regions.map(
      (e) => TagScrapped(id: e.text.trim().toLowerCase(), name: e.text.trim()),
    );

    return tags.nonNulls.toList();
  }

  @override
  List<String> get scripts {
    final filterQuery = [
      'div.flex.flex-col.gap-3',
      'div',
      [
        'button',
        'cursor-pointer',
        'transition-colors',
        'gap-2',
        'justify-center',
        'items-center',
        'flex',
        'rounded-md',
        'text-white',
        'border',
        'px-4',
        'w-full',
      ].join('.'),
    ].join(' > ');

    final genreQuery = [
      'div.flex-1.overflow-y-auto',
      'div',
      'div',
      'button',
    ].join(' > ');

    final tapFilter = [
      'window',
      'document',
      'querySelectorAll(\'$filterQuery\')[0]',
      'click()',
    ].join('.');

    final tapGenre = [
      'window',
      'document',
      'querySelectorAll(\'$genreQuery\')[3]',
      'click()',
    ].join('.');

    return [tapFilter, tapGenre];
  }
}
