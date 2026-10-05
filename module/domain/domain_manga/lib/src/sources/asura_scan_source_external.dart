import 'dart:convert';

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
  Duration? get timeout => Duration(seconds: 30);

  /// Reader container chain — the Astro-rebuilt site wraps each page in
  /// <div data-page="n" class="w-full"> under the `select-none` reader; the
  /// page <img> carries `data-page-index`. Matching on that stable attribute
  /// (instead of Tailwind classes that drift with redesigns) keeps the parse
  /// working without touching this file again.
  static final _readerQuery = [
    'div.select-none',
    'img[data-page-index]',
  ].join(' ');

  @override
  List<String> get readyWhenSelectors => [_readerQuery];

  @override
  Future<List<String>> parse({required Document root}) async {
    final regions = root.querySelectorAll(_readerQuery);

    return regions.map((e) => e.attributes['src']).nonNulls.toList();
  }

  @override
  List<String> get scripts {
    return [
      '''
      var elements = document.querySelectorAll('$_readerQuery');
      for (let i = 0; i < elements.length; i++) {
        setTimeout(() => elements[i].scrollIntoView(), 100 * i);
      }
      ''',
    ];
  }
}

class _GetMangaSourceExternalUseCase implements GetMangaSourceExternalUseCase {

  @override
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 20);

  /// Series-detail parser for the Astro-rebuilt site (captured live
  /// 2026-10). Anchors are ids, headings and href shapes — not Tailwind
  /// class chains, which drifted again and left the old parse matching
  /// nothing: title `h1`, cover `img#mobile-cover-img`, synopsis
  /// `#description-text`, author `a[href^="/browse?author="]`, genres
  /// `a[href^="/browse?genres="]`, status via the "Status" label cell.
  @override
  Future<MangaScrapped> parse({required Document root}) async {
    // Scope the title to the content area — a page-global `h1` would pick
    // up a site-header heading on a redesign.
    final title =
        (root.querySelector('article h1') ??
                root.querySelector('main h1') ??
                root.querySelector('h1'))
            ?.text
            .trim();
    // img#mobile-cover-img is the live cover id, but the app webview runs a
    // DESKTOP user agent (user_agent_mixin) — if the id is renamed or only
    // rendered on mobile layouts, fall back to the og:image meta.
    final coverUrl =
        root.querySelector('img#mobile-cover-img')?.attributes['src'] ??
        root.querySelector('meta[property="og:image"]')?.attributes['content'];
    final description = root
        .querySelector('#description-text')
        ?.text
        .trim();

    // The Status/Type row pair: a small label cell reading exactly
    // "Status", whose sibling value is the capitalized status span.
    // NOTE: `div.text-xs` + `span.capitalize` are the next hooks expected
    // to drift — unlike the ids/labels around them they are pure styling
    // classes. If status ever reads null, start here.
    String? status;
    for (final label in root.querySelectorAll('div.text-xs')) {
      if (label.text.trim() != 'Status') continue;
      status = label.parent?.querySelector('span.capitalize')?.text.trim();
      break;
    }

    final author = root
        .querySelector('a[href^="/browse?author="]')
        ?.text
        .trim();

    final tags = [
      for (final link in root.querySelectorAll('a[href^="/browse?genres="]'))
        if (link.text.trim().isNotEmpty) link.text.trim(),
    ];

    return MangaScrapped(
      title: title,
      author: author,
      description: description,
      status: status,
      coverUrl: coverUrl,
      tags: tags,
    );
  }

  @override
  List<String> get scripts {
    // Expand the chapter list ("Show more" toggle) before the snapshot.
    // Matched by visible text instead of the old positional
    // querySelectorAll('div.flex.z-10...')[0] chain — Tailwind classes and
    // button order drift with redesigns, the label does not.
    return [
      '''
      (() => {
        const buttons = [...document.querySelectorAll('button')];
        const target = buttons.find(b =>
          (b.textContent || '').trim().toLowerCase().startsWith('show more'),
        );
        if (target) target.click();
      })();
      ''',
    ];
  }
}

class _ListChapterSourceExternalUseCase
    implements ListChapterSourceExternalUseCase {
  final String _name;
  final String _baseUrl;

  const _ListChapterSourceExternalUseCase(this._baseUrl, this._name);

  /// Chapter hrefs END in /chapter/{slug} — the `.` covers decimal
  /// specials ("Chapter 10.5"), the `/?$` anchor excludes reader sub-pages
  /// and fragments.
  static final _chapterHref = RegExp(r'/chapter/[\w.-]+/?$');

  @override
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    // Chapter rows ship in the Astro SSR fallback (and after React
    // hydration keep the same shape): anchors whose href ENDS in
    // /chapter/{slug} — reader sub-pages and query strings do not count.
    // The page also carries same-shaped "continue reading" hero links and
    // related-row chapter links, so the scan scopes to the astro-island
    // holding the most chapter anchors (the chapter list) and falls back
    // to the whole document only when no island holds any; rows are then
    // deduped by webUrl. There is NO per-row lock marker in the current
    // DOM — premium ("Read Offline") chapters render identically to free
    // ones — so rows are never filtered (verified live 2026-10; the old
    // amber-gradient check matched nothing).
    final candidates = root.querySelectorAll('a').where(
      (e) => _chapterHref.hasMatch(e.attributes['href'] ?? ''),
    );
    if (candidates.isEmpty) return [];

    final byIsland = <Element?, List<Element>>{};
    for (final candidate in candidates) {
      byIsland.putIfAbsent(_nearestIsland(candidate), () => []).add(candidate);
    }
    final islandGroups = [
      for (final entry in byIsland.entries)
        if (entry.key != null) entry.value,
    ];
    final rows = islandGroups.isNotEmpty
        ? islandGroups.reduce(
            (best, group) => group.length > best.length ? group : best,
          )
        : byIsland[null]!;

    final seen = <String>{};
    final chapters = <ChapterScrapped>[];
    for (final row in rows) {
      final href = row.attributes['href'];
      // Unreachable in practice — candidates matched _chapterHref — but the
      // type system needs the null check before joining.
      if (href == null) continue;
      final webUrl = [_baseUrl, href].join('');
      if (!seen.add(webUrl)) continue;
      final title = row.querySelector('span.font-medium')?.text.trim();
      final date = row.querySelector('.text-right')?.text.trim();

      chapters.add(
        ChapterScrapped(
          title: title,
          chapter: title?.split(' ').lastOrNull,
          readableAt: date,
          webUrl: webUrl,
          scanlationGroup: _name,
        ),
      );
    }
    return chapters;
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
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    // The pagination buttons carry stable aria-labels; the next page exists
    // only while its button is enabled. (The old nav.flex.…-mt-8.pb-8 class
    // chain was the fragile part; the buttons outlive it.)
    final nextButton = root.querySelector('button[aria-label="Next page"]');

    return nextButton != null &&
        !nextButton.attributes.containsKey('disabled');
  }

  @override
  Future<List<MangaScrapped>> parse({
    required Document root,
    String? searchTerm,
  }) async {
    // Card anchor is the single `series-card` class — the site's card class
    // list already drifted from rounded-lg to rounded-md once (2026-10),
    // which silently matched zero cards with the old full-chain selector.
    final region = root.querySelectorAll('div.series-card');

    final mangas = region.map((card) {
      final title = card.querySelector('h3')?.text.trim();
      // Title link: the anchor wrapping the h3 when one exists, falling
      // back to the card's first /comics/ anchor (the cover link). The old
      // selector required the `div.p-3` wrapper — a padding hook that
      // drifts with redesigns and silently left webUrl null (dead nav).
      final link =
          _enclosingAnchor(card.querySelector('h3')) ??
          card.querySelector('a[href^="/comics/"]');
      final coverUrl = card.querySelector('img')?.attributes['src'];
      final webUrl = link?.attributes['href'].let(
        (href) => [_baseUrl, href].join(''),
      );
      // The status is the only capitalized meta span (chapter-count spans
      // never carry `capitalize`).
      final status = card.querySelector('span.capitalize')?.text.trim();

      return MangaScrapped(
        title: title,
        coverUrl: coverUrl,
        webUrl: webUrl,
        status: status,
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

  /// Genres are listed on the search page this source already opens.
  @override
  String? get url => null;


  @override
  Duration? get timeout => Duration(seconds: 20);

  @override
  List<String> get readyWhenSelectors => [
    // Readiness is the props-bearing genre island, not just any island —
    // a bare `astro-island` matches every island on the page and proves
    // nothing about the props being SSR'd.
    'astro-island[props*="availableGenres"]',
  ];

  /// The genre list ships server-rendered inside the browse page's filter
  /// astro-island: its `props` attribute carries devalue-encoded
  /// `availableGenres` ([1, [[0, {name: [0, "Action"], slug: [0,
  /// "action"]}], …]]). The html package decodes the entities, so plain
  /// [jsonDecode] walks it — no dropdown click, no client-rendered DOM, no
  /// Tailwind chain (same approach as the Flame Comics `__NEXT_DATA__`
  /// parser; see CLAUDE.md).
  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    String? props;
    for (final island in root.querySelectorAll('astro-island')) {
      final value = island.attributes['props'];
      if (value != null && value.contains('availableGenres')) {
        props = value;
        break;
      }
    }
    if (props == null) return [];

    // A truncated/reshaped props payload must degrade to "no tags", not
    // throw a FormatException out of parse.
    dynamic decoded;
    try {
      decoded = jsonDecode(props);
    } on FormatException {
      return [];
    }
    if (decoded is! Map<String, dynamic>) return [];

    final genres = decoded['availableGenres'];
    if (genres is! List || genres.length < 2) return [];
    final entries = genres[1];
    // Only the OUTER list is checked above; the payload shape lives in
    // entries, so a scalar second element must bail instead of throwing
    // a TypeError on the loop below.
    if (entries is! List) return [];

    final tags = <TagScrapped>[];
    for (final entry in entries) {
      if (entry is! List || entry.length < 2 || entry[1] is! Map) continue;
      final name = entry[1]['name'];
      final slug = entry[1]['slug'];
      final nameValue = name is List && name.length > 1 ? name[1] : null;
      final slugValue = slug is List && slug.length > 1 ? slug[1] : null;
      if (nameValue is! String) continue;
      tags.add(
        TagScrapped(
          id: slugValue is String ? slugValue : nameValue.toLowerCase(),
          name: nameValue,
        ),
      );
    }

    return tags;
  }

  @override
  List<String> get scripts {
    // The island props are server-rendered — no script is needed; the
    // dropdown never has to open for the genre list to be readable.
    return [];
  }
}

/// Nearest `<a>` ancestor of [element] (package:html has no closest()).
Element? _enclosingAnchor(Element? element) {
  for (Element? node = element; node != null; node = node.parent) {
    if (node.localName == 'a') return node;
  }
  return null;
}

/// Nearest `astro-island` ancestor of [element], or null when it sits
/// outside every island.
Element? _nearestIsland(Element element) {
  for (Element? node = element.parent; node != null; node = node.parent) {
    if (node.localName == 'astro-island') return node;
  }
  return null;
}
