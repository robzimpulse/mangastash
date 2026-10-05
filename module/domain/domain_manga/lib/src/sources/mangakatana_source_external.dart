import 'package:collection/collection.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

/// Manga Katana (https://mangakatana.com) external manga source.
///
/// The site is server-rendered HTML. Search, detail, and genre pages are
/// static DOM; only the chapter reader needs a script: the image URLs live in
/// inline JS (`var thzq = ['url1', ...]`) while the reader <img>s carry
/// `data-src="#"` placeholders, so the reader use case injects a script that
/// copies each real URL into the matching placeholder's `data-src` before
/// HTML capture. Browsing with an empty query uses the homepage: the root
/// search route renders "Not found any results" and the site's small-viewport
/// JS empties the Hot Manga widget (it only repopulates from `#hot_update`,
/// which exists on the homepage alone), so the search page's post-JS DOM has
/// zero `div.item[data-id]` cards.
class MangakatanaSourceExternal implements SourceExternal {
  @override
  String get baseUrl => 'https://mangakatana.com';

  @override
  String get iconUrl => '$baseUrl/favicon.ico';

  @override
  String get name => 'Manga Katana';

  @override
  bool get builtIn => false;

  @override
  GetChapterImageSourceExternalUseCase get getChapterImageUseCase =>
      _GetChapterImageSourceExternalUseCase(baseUrl);

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
      _ListTagSourceExternalUseCase();
}

/// Prefixes a URL with the source base URL when it is a root-relative path.
String _absolute(String baseUrl, String url) {
  if (url.startsWith('http')) return url;
  if (url.startsWith('//')) return 'https:$url';
  if (url.startsWith('/')) return '$baseUrl$url';
  return url;
}

class _GetChapterImageSourceExternalUseCase
    implements GetChapterImageSourceExternalUseCase {
  final String _baseUrl;

  const _GetChapterImageSourceExternalUseCase(this._baseUrl);

  @override
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 30);

  @override
  Future<List<String>> parse({required Document root}) async {
    // The injected script replaces the data-src="#" placeholders with the
    // real URLs from the inline `thzq` array; drop any that remain "#".
    final images = root.querySelectorAll('#imgs .wrap_img img');

    return images
        .map((e) => e.attributes['data-src'])
        .nonNulls
        .where((src) => src != '#')
        .map((src) => _absolute(_baseUrl, src))
        .toList();
  }

  @override
  List<String> get scripts {
    return [
      // The reader image URLs are in an inline JS `var thzq = [...]` array;
      // the reader <img>s only carry `data-src="#"` placeholders. Copy each
      // real URL into the matching placeholder before getHtml() snapshots.
      '''
      (() => {
        if (typeof thzq === 'undefined') return;
        document.querySelectorAll('#imgs .wrap_img img').forEach((img, i) => {
          if (thzq[i]) img.setAttribute('data-src', thzq[i]);
        });
      })();
      ''',
      // Allow the DOM mutation to settle before getHtml().
      'setTimeout(function(){}, 2500);',
    ];
  }
}

class _GetMangaSourceExternalUseCase implements GetMangaSourceExternalUseCase {
  const _GetMangaSourceExternalUseCase();

  @override
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<MangaScrapped> parse({required Document root}) async {
    return MangaScrapped(
      title: root.querySelector('h1')?.text.trim(),
      author: _infoValue(root, 'Author(s)'),
      description: _summary(root),
      status: _infoValue(root, 'Status'),
      // Captured live 2026-10: info rows are li.d-row-small and genre
      // links carry ABSOLUTE hrefs — anchor on the row classes so the
      // navbar's genre dropdown (plain <li>) never leaks in (#164).
      tags:
          root
              .querySelectorAll(
                'li.d-row a[href*="/genre/"], li.d-row-small a[href*="/genre/"]',
              )
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      coverUrl:
          root.querySelector('div.wrap_img img')?.attributes['data-src'] ??
          root.querySelector('div.wrap_img img')?.attributes['src'],
    );
  }

  @override
  List<String> get scripts => [];
}

/// Reads a `li.d-row`/`li.d-row-small` value by label prefix, e.g.
/// "Ziki Masaya" from the row whose label cell says "Author(s) / Artist(s):"
/// (the row class changed to d-row-small in 2026-10 — match both).
String? _infoValue(Document root, String label) {
  for (final row in root.querySelectorAll('li.d-row, li.d-row-small')) {
    final rowLabel = row.querySelector('div.d-cell-small.label')?.text.trim();
    if (rowLabel == null || !rowLabel.contains(label)) continue;
    return row.querySelector('div.d-cell-small.value')?.text.trim();
  }
  return null;
}

/// Extracts the summary text from `div.summary > p`.
String? _summary(Document root) {
  return root.querySelector('div.summary p')?.text.trim();
}

class _ListChapterSourceExternalUseCase
    implements ListChapterSourceExternalUseCase {
  final String _baseUrl;

  const _ListChapterSourceExternalUseCase(this._baseUrl);

  @override
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final chapters = <ChapterScrapped>[];

    for (final row in root.querySelectorAll('table tr')) {
      final link = row.querySelector('td div.chapter a');
      if (link == null) continue;

      final title = link.text.trim();
      final href = link.attributes['href'];
      final updateTime = row.querySelector('td div.update_time')?.text.trim();

      chapters.add(
        ChapterScrapped(
          title: title,
          chapter: _chapterNumber(title),
          readableAt: updateTime,
          publishAt: updateTime,
          webUrl: href == null ? null : _absolute(_baseUrl, href),
        ),
      );
    }

    return chapters;
  }

  @override
  List<String> get scripts => [];
}

/// Extracts the first numeric run from a chapter title (e.g. "1040" from
/// "Chapter 1040").
String? _chapterNumber(String? title) {
  if (title == null) return null;
  return RegExp(r'\d+(\.\d+)?').firstMatch(title)?.group(0) ??
      title.split(' ').lastOrNull;
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
    // Both browse (/page/N) and search (/page/N?search=…) render a
    // `ul.uk-pagination` whose final entry is an `<a class="next …">` link
    // to the next page; the last page has no such link.
    return root.querySelector('ul.uk-pagination a.next') != null;
  }

  @override
  Future<List<MangaScrapped>> parse({
    required Document root,
    String? searchTerm,
  }) async {
    final mangas = <MangaScrapped>[];

    // Both the `.d-cell` search-route template and the `.media` root-search
    // template share the shape: `div.item[data-id]` → `h3.title a` link +
    // an `img` cover + an optional `div.status.ongoing`. Scope to `#book_list`
    // — on the homepage the `#hot_book` sidebar repeats its own `.item`
    // cards on every page (captured live 2026-10), which would otherwise
    // leak into every browse page.
    for (final item in root.querySelectorAll('#book_list div.item[data-id]')) {
      final link = item.querySelector('h3.title a');
      if (link == null) continue;

      final img = item.querySelector('img');
      final href = link.attributes['href'];
      mangas.add(
        MangaScrapped(
          title: link.text.trim(),
          coverUrl: img?.attributes['data-src'] ?? img?.attributes['src'],
          webUrl: href == null ? null : _absolute(_baseUrl, href),
          status: item.querySelector('div.status.ongoing')?.text.trim(),
          tags: _dataGenre(item),
        ),
      );
    }

    return mangas;
  }

  @override
  List<String> get scripts => [];

  @override
  String url({required SearchMangaParameter parameter}) {
    final q = Uri.encodeQueryComponent(parameter.title ?? '');
    if (q.isEmpty) {
      // Browse (empty query): the root search route renders "Not found any
      // results" in `#book_list`, and on viewports < 768px the site's JS
      // empties the Hot Manga widget, leaving zero `div.item[data-id]` cards
      // in the DOM. Serve the paginated latest-manga list instead — page 1
      // is the homepage, further pages are /page/N (20 cards each).
      final page = parameter.page;
      return page <= 1 ? '$_baseUrl/' : '$_baseUrl/page/$page';
    }
    // The site's search form posts to the root path; `/search` is a 404.
    // `search_by=m_name` makes the query match against manga names. The
    // route is paginated (captured live 2026-10: the nav's next link is
    // /page/2?search=…&search_by=m_name), so page 2+ must follow that form
    // or every next page re-fetches page 1 (#165).
    final page = parameter.page;
    return page <= 1
        ? '$_baseUrl/?search=$q&search_by=m_name'
        : '$_baseUrl/page/$page?search=$q&search_by=m_name';
  }
}

/// Splits a `div.item[data-genre]` attribute (comma-separated genre names).
List<String>? _dataGenre(Element item) {
  final raw = item.attributes['data-genre']?.trim();
  if (raw == null || raw.isEmpty) return null;
  return raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {

  /// Genres are listed on the search page this source already opens.
  @override
  String? get url => null;

  @override
  List<String> get readyWhenSelectors => [];

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    // Genres appear as <a href="/genre/{slug}"> links on the genre index and
    // inline on detail pages; any such link is a valid tag. Dedupe by name.
    final tags = <String, String>{};

    for (final link in root.querySelectorAll('a[href*="/genre/"]')) {
      final name = link.text.trim();
      if (name.isEmpty) continue;
      final slug =
          (link.attributes['href'] ?? '')
              .split('/')
              .where((e) => e.isNotEmpty)
              .lastOrNull;
      tags[name] = slug ?? name.toLowerCase();
    }

    return [
      for (final entry in tags.entries)
        TagScrapped(id: entry.value, name: entry.key),
    ];
  }

  @override
  List<String> get scripts => [];
}
