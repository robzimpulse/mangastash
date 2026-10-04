import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

/// WeebCentral (https://weebcentral.com) external manga source.
///
/// The site is server-rendered HTML driven by htmx + Alpine. All parsers read
/// the static DOM; only the chapter reader needs a script to trigger the
/// in-page htmx fetch that injects the page <img>s before HTML capture.
class WeebCentralSourceExternal implements SourceExternal {
  @override
  String get baseUrl => 'https://weebcentral.com';

  @override
  String get iconUrl => '$baseUrl/favicon.ico';

  @override
  String get name => 'Weeb Central';

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
      _ListChapterSourceExternalUseCase(baseUrl);

  @override
  SearchMangaSourceExternalUseCase get searchMangaUseCase =>
      _SearchMangaSourceExternalUseCase(baseUrl);

  @override
  ListTagSourceExternalUseCase get listTagUseCase =>
      _ListTagSourceExternalUseCase(baseUrl);
}

class _GetChapterImageSourceExternalUseCase
    implements GetChapterImageSourceExternalUseCase {
  @override
  Duration? get timeout => Duration(seconds: 30);

  @override
  Future<List<String>> parse({required Document root}) async {
    final region = root.querySelector('section#chapter-images');
    final images = region?.querySelectorAll('img') ?? [];

    return [
      for (final image in images) image.attributes['src'],
    ].nonNulls.toList();
  }

  @override
  List<String> get readyWhenSelectors {
    // The htmx swap replaces #chapter-images wholesale; the snapshot is
    // only valid once it holds the page <img>s.
    return ['section#chapter-images img'];
  }

  @override
  List<String> get scripts {
    return [
      // The source class does not know the chapter id (the use case receives
      // only the Document), so the script derives it from the page URL:
      // /chapters/{id}. It then triggers the same htmx ajax the reader's
      // Alpine singlePageNavigation init performs. reading_style=long_strip
      // injects all page <img>s into #chapter-images before getHtml().
      '''
      (function() {
        const el = document.getElementById('chapter-images');
        if (!el || typeof htmx === 'undefined') return;
        const segments = location.pathname.split('/').filter(Boolean);
        const chapterId = segments[segments.length - 1];
        if (!chapterId) return;
        const url = location.origin + '/chapters/' + chapterId +
          '/images?is_prev=False&current_page=1&reading_style=long_strip';
        htmx.ajax('GET', url, {
          target: el,
          swap: 'outerHTML',
          values: { reading_style: 'long_strip' },
        });
      })();
      ''',
      // The readiness beacon (readyWhenSelectors above) replaced the old
      // fixed `setTimeout(function(){}, 2500)` sleep: it polls until the
      // injected <img>s actually exist instead of hoping 2.5s was enough.
    ];
  }
}

class _GetMangaSourceExternalUseCase implements GetMangaSourceExternalUseCase {
  @override
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<MangaScrapped> parse({required Document root}) async {
    // The series page renders the title in two <h1>s (mobile + desktop), both
    // with the same text; the first is fine. Avoids Tailwind colon-classes in
    // the selector, which are fragile in the html package.
    final title = root.querySelector('h1');
    final description = root.querySelector('p.whitespace-pre-wrap.break-words');
    final coverUrl = root
        .querySelector('main')
        ?.querySelector('img[src*="temp.compsci88.com/cover"]')
        ?.attributes['src'];

    // Author(s) sits in an <a>, the other rows in a <span>; fall back to <a>.
    String? rowValue(Document root, String label) {
      for (final strong in root.querySelectorAll('strong')) {
        if (strong.text.trim().contains(label)) {
          final container = strong.parent;
          final value =
              container?.querySelector('span') ??
              container?.querySelector('a');
          if (value != null) return value.text.trim();
        }
      }
      return null;
    }

    return MangaScrapped(
      title: title?.text.trim(),
      author: rowValue(root, 'Author'),
      description: description?.text.trim(),
      status: rowValue(root, 'Status'),
      tags: _tagRow(root),
      coverUrl: coverUrl,
    );
  }

  List<String>? _tagRow(Document root) {
    for (final strong in root.querySelectorAll('strong')) {
      if (!strong.text.trim().contains('Tag')) continue;
      return strong.parent
          ?.querySelectorAll('span')
          .map((e) => e.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return null;
  }

  @override
  // TODO: implement scripts
  List<String> get scripts => [];
}

class _ListChapterSourceExternalUseCase
    implements ListChapterSourceExternalUseCase {
  final String _baseUrl;

  const _ListChapterSourceExternalUseCase(this._baseUrl);

  @override
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 15);

  /// The series page's #chapter-list only carries ~9 latest chapters; the
  /// complete list (102 rows for Beck, verified live 2026-10) is served by
  /// the endpoint the "Show All Chapters" htmx button targets — so fetch
  /// that directly (issue #161).
  @override
  String url({required String webUrl}) => '$webUrl/full-chapter-list';

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    // The full-chapter-list endpoint returns the htmx fragment that
    // REPLACES #chapter-list's inner HTML — no #chapter-list wrapper — so
    // fall back to every chapter anchor when the wrapper is absent.
    var rows = root.querySelectorAll('#chapter-list a[href^="/chapters/"]');
    if (rows.isEmpty) {
      rows = root.querySelectorAll('a[href^="/chapters/"]');
    }

    final chapters = <ChapterScrapped>[];
    for (final row in rows) {
      final url = row.attributes['href'];
      final title = row.querySelector('span.grow')?.querySelector('span')?.text.trim();
      final time = row.querySelector('time');
      chapters.add(
        ChapterScrapped(
          title: title,
          chapter: title?.split(' ').lastOrNull,
          webUrl: url?.let((e) => [_baseUrl, e].join('')),
          readableAt: time?.text.trim(),
          publishAt: time?.text.trim(),
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
    // The server always renders a "View More Results…" button; a real next
    // page is present only when that button carries an `offset` param.
    final button = root.querySelector('button[hx-get*="/search/data"]');
    return button?.attributes['hx-get']?.contains('offset=') ?? false;
  }

  @override
  Future<List<MangaScrapped>> parse({
    required Document root,
    String? searchTerm,
  }) async {
    final mangas = <MangaScrapped>[];
    final seen = <String>{};
    // Card anchor is structural: an <article> that IS a card — not nested
    // inside another article (nested cover wrappers made outer and inner
    // both parse as cards and double-counted the series), and holding BOTH
    // a series link and a cover image (text rows / non-card articles with
    // a bare series link produced phantoms). Cards are deduped by webUrl
    // as a final guard.
    final articles = root.querySelectorAll('article').where(
          (article) =>
              !_hasArticleAncestor(article) &&
              article.querySelector('a[href*="/series/"]') != null &&
              article.querySelector('img') != null,
        );

    for (final article in articles) {
      // The metadata section is the one whose series link has non-empty
      // text — but live 2026-10 cards wrap a mobile cover whose anchor
      // carries text (an "Official" ribbon + an overlay title) inside the
      // FIRST section, so text alone no longer identifies metadata (#162).
      // Real metadata ships LABELED rows — strongs whose text carries a
      // colon ("Status:", "Author(s):", "Tag(s):") — which badges like a
      // tooltip's <strong>New</strong> or a future ribbon markup lack
      // (review on #169).
      final sectionsWithTextLinks = article
          .querySelectorAll('section')
          .where(
            (section) =>
                section
                    .querySelectorAll('a[href*="/series/"]')
                    .any((a) => a.text.trim().isNotEmpty),
          );
      final metadata =
          sectionsWithTextLinks
              .firstWhereOrNull(
                (section) => section
                    .querySelectorAll('strong')
                    .any((s) => s.text.contains(':')),
              ) ??
          // No section carries labeled rows — degrade to the last text-link
          // section WITHOUT a cover image. Excluding img-bearing sections
          // makes the pick order-proof (observed layouts ship the cover
          // first, but a metadata-first card must not lose to a cover-last
          // section) — review on #169. If every text-link section carries
          // an image, fall back to plain last.
          sectionsWithTextLinks
              .where((section) => section.querySelector('img') == null)
              .lastOrNull ??
          sectionsWithTextLinks.lastOrNull;
      final link = metadata
          ?.querySelectorAll('a[href*="/series/"]')
          .firstWhereOrNull((a) => a.text.trim().isNotEmpty);

      // No title link → not a card (image-only recommendation rows); skip
      // instead of emitting a phantom. Also dedupes repeated webUrls.
      final webUrl = link?.attributes['href'];
      if (webUrl == null || !seen.add(webUrl)) continue;

      final title = link?.text.trim();
      final coverUrl = article
          .querySelector('img[src*="temp.compsci88.com"]')
          ?.attributes['src'];

      // Scan the metadata rows for the "Status:" label — Year is the first
      // .opacity-70 row, so we cannot rely on position.
      String? rowValue(Element container, String label) {
        for (final strong in container.querySelectorAll('strong')) {
          if (strong.text.trim().contains(label)) {
            return strong.parent?.querySelector('span')?.text.trim();
          }
        }
        return null;
      }

      final status = metadata?.let((e) => rowValue(e, 'Status'));
      final author = metadata?.querySelector('a[href*="author="]')?.text.trim();
      // The Tag row is the div holding a "Tag" strong — but a nested
      // wrapper CONTAINING that row matches too (its descendant strong
      // satisfies querySelector), and the wrapper's own spans would
      // pollute the tag list. Rows come in document order, so pick the
      // innermost match: the first row that is not an ancestor of another.
      final tagRows = metadata
          ?.querySelectorAll('div')
          .where((e) => e.querySelector('strong')?.text.contains('Tag') ?? false)
          .toList();
      Element? tagRow;
      for (final row in tagRows ?? const <Element>[]) {
        final isWrapper = (tagRows ?? const <Element>[]).any(
          (other) => !identical(other, row) && _isAncestorOf(row, other),
        );
        if (!isWrapper) {
          tagRow = row;
          break;
        }
      }
      final tags = tagRow
          ?.querySelectorAll('span')
          .map((e) => e.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      mangas.add(
        MangaScrapped(
          title: title,
          coverUrl: coverUrl,
          webUrl: webUrl,
          status: status,
          author: author,
          tags: tags,
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
    final order = parameter.orders?.entries.firstOrNull;
    final sort = order.let(
      (entry) => switch (entry.key) {
        SearchOrders.title => 'Alphabet',
        SearchOrders.relevance => 'Best Match',
        SearchOrders.followedCount => 'Subscribers',
        SearchOrders.createdAt => 'Recently Added',
        SearchOrders.latestUploadedChapter => 'Latest Updates',
        SearchOrders.rating => 'Popularity',
        _ => null,
      },
    );

    final status = parameter.status?.firstOrNull.let(
      (e) => switch (e) {
        MangaStatus.ongoing => 'Ongoing',
        MangaStatus.completed => 'Complete',
        MangaStatus.hiatus => 'Hiatus',
        MangaStatus.cancelled => 'Canceled',
      },
    );

    final orderDirection = order?.value.let(
      (d) => d == OrderDirections.ascending ? 'Ascending' : 'Descending',
    );

    // The server clamps the batch to 32 and ignores `limit`, and the app
    // forces limit:20; hardcode 32 so offset-based pagination stays correct.
    const pageSize = 32;

    return [
      [_baseUrl, 'search', 'data'].join('/'),
      [
        MapEntry('text', parameter.title ?? ''),
        const MapEntry('limit', '$pageSize'),
        MapEntry('offset', '${(parameter.page - 1) * pageSize}'),
        const MapEntry('display_mode', 'Full Display'),
        if (sort != null) MapEntry('sort', sort),
        if (orderDirection != null) MapEntry('order', orderDirection),
        if (status != null) MapEntry('included_status', status),
        for (final tag in parameter.includedTags ?? <String>[])
          MapEntry('included_tag', tag),
      ].map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&'),
    ].join('?');
  }
}

class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {
  final String _baseUrl;

  const _ListTagSourceExternalUseCase(this._baseUrl);

  @override
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  // The genre checkboxes live ONLY on /search; searchMangaUseCase.url()
  // points at the /search/data htmx fragment, which ships zero checkboxes
  // (issue #163).
  String? get url => '$_baseUrl/search';

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    // Genre checkboxes live only on /search, shaped id="tag-{Name}" inside
    // label.fieldset-label; the human-readable name sits in the sibling
    // <span class="ml-2">.
    final labels = root
        .querySelectorAll('input[type="checkbox"][id^="tag-"]')
        .map((input) => input.parent?.querySelector('span.ml-2')?.text.trim())
        .where((e) => e != null && e.isNotEmpty)
        .toSet();

    return [
      for (final name in labels)
        TagScrapped(id: name, name: name),
    ];
  }

  @override
  List<String> get scripts {
    // The filter panel is hidden behind the Alpine `show_filter` flag; the
    // section carries x-show="show_filter", so force it visible and let the
    // panel settle before HTML capture.
    return [
      '''

      (function() {
        document
          .querySelectorAll('section[x-show="show_filter"]')
          .forEach((el) => { el.style.display = 'block'; });
      })();

      ''',
      // Allow the Alpine x-show transition to settle before getHtml().
      'setTimeout(function(){}, 2500);',
    ];
  }
}

/// Whether [element] sits inside another <article> — nested cover wrappers
/// made outer and inner articles both parse as cards (package:html has no
/// closest()).
bool _hasArticleAncestor(Element element) {
  for (Element? node = element.parent; node != null; node = node.parent) {
    if (node.localName == 'article') return true;
  }
  return false;
}

/// Whether [ancestor] contains [node] anywhere below it (package:html has
/// no deep Node.contains).
bool _isAncestorOf(Element ancestor, Element node) {
  for (Element? current = node.parent; current != null; current = current.parent) {
    if (identical(current, ancestor)) return true;
  }
  return false;
}
