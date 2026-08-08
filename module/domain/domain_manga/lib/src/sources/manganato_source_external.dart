import 'package:collection/collection.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

/// Manganato (https://manganato.gg) external manga source.
///
/// The site is server-rendered HTML on the classic Manganato theme. Search,
/// detail, and reader pages are static DOM; only the chapter list is loaded
/// via an AJAX API, so the list use case injects a script that fetches the
/// JSON and renders rows into `#chapter-list-container` before HTML capture.
class ManganatoSourceExternal implements SourceExternal {
  @override
  String get baseUrl => 'https://manganato.gg';

  @override
  String get iconUrl => '$baseUrl/favicon.ico';

  @override
  String get name => 'Manganato';

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
  if (url.startsWith('/')) return '$baseUrl$url';
  return url;
}

class _GetChapterImageSourceExternalUseCase
    implements GetChapterImageSourceExternalUseCase {
  final String _baseUrl;

  const _GetChapterImageSourceExternalUseCase(this._baseUrl);

  @override
  Duration? get timeout => Duration(seconds: 30);

  @override
  Future<List<String>> parse({required Document root}) async {
    // Every page <img> inside the reader container; each image may also carry
    // an onerror fallback that duplicates the src, so dedupe while keeping
    // document order (toSet on an Iterable preserves insertion order).
    final images = root.querySelectorAll('div.container-chapter-reader img');

    return images
        .map((e) => e.attributes['src'])
        .nonNulls
        .map((src) => _absolute(_baseUrl, src))
        .toSet()
        .toList();
  }

  @override
  // Server-rendered; the page <img>s are present without any script.
  List<String> get scripts => [];
}

class _GetMangaSourceExternalUseCase implements GetMangaSourceExternalUseCase {
  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<MangaScrapped> parse({required Document root}) async {
    return MangaScrapped(
      title: root.querySelector('div.manga-info-content h1')?.text.trim(),
      author: _infoValue(root, 'Author(s)'),
      description: _summary(root),
      status: _infoValue(root, 'Status'),
      tags:
          root
              .querySelectorAll('li.genres a[href^="/genre/"]')
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      coverUrl: root.querySelector('div.manga-info-pic img')?.attributes['src'],
    );
  }

  @override
  List<String> get scripts => [];
}

/// Reads a `ul.manga-info-text li` value by label prefix, e.g.
/// "Author(s) : ODA Eiichiro" for label "Author(s)".
String? _infoValue(Document root, String label) {
  for (final li in root.querySelectorAll('ul.manga-info-text li')) {
    final text = li.text.trim();
    if (!text.startsWith(label)) continue;
    return text
        .substring(label.length)
        .replaceFirst(RegExp(r'^[\s:]+'), '')
        .trim();
  }
  return null;
}

/// Extracts the summary paragraph from `#contentBox`, i.e. the sibling text
/// that follows the heading whose text contains "summary".
String? _summary(Document root) {
  final box = root.querySelector('#contentBox');
  if (box == null) return null;

  final heading = box
      .querySelectorAll('h2, h3, h4')
      .firstWhereOrNull((e) => e.text.toLowerCase().contains('summary'));
  if (heading == null) return null;

  final parts = <String>[];
  var node = heading.nextElementSibling;
  while (node != null) {
    final tag = node.localName?.toLowerCase();
    final isHeading = tag == 'h2' || tag == 'h3' || tag == 'h4';
    if (isHeading) break;
    final text = node.text.trim();
    if (text.isNotEmpty) parts.add(text);
    node = node.nextElementSibling;
  }

  return parts.isEmpty ? null : parts.join('\n');
}

class _ListChapterSourceExternalUseCase
    implements ListChapterSourceExternalUseCase {
  final String _baseUrl;

  const _ListChapterSourceExternalUseCase(this._baseUrl);

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final rows = root.querySelectorAll(
      '#chapter-list-container a[data-chapter-title]',
    );

    return rows.map((row) {
      final title = row.attributes['data-chapter-title']?.trim();
      final date = row.attributes['data-chapter-date']?.trim();
      final href = row.attributes['href'];

      return ChapterScrapped(
        title: title,
        chapter: _chapterNumber(title),
        readableAt: date,
        publishAt: date,
        webUrl: href == null ? null : _absolute(_baseUrl, href),
      );
    }).toList();
  }

  @override
  List<String> get scripts {
    return [
      // The detail page renders an empty #chapter-list-container and loads
      // the chapters from {baseUrl}/api/manga/{slug}/chapters via AJAX. Fetch
      // the JSON and render <a> rows (the same markup the parser reads) into
      // the container before getHtml() snapshots the DOM.
      '''
      (async () => {
        const el = document.querySelector('#chapter-list-container');
        if (!el) return;
        const slug = el.getAttribute('data-comic-slug') || (el.getAttribute('data-api-url')||'').split('/')[4];
        const api = el.getAttribute('data-api-url').replace('__SLUG__', slug);
        const chapTpl = el.getAttribute('data-chapter-url-template');
        const r = await fetch(api);
        const j = await r.json();
        const list = j.data?.chapters || [];
        el.innerHTML = list.map(c => '<a href="' + chapTpl.replace('__MANGA__', slug).replace('__CHAPTER__', c.chapter_slug) + '" data-chapter-title="' + c.chapter_name + '" data-chapter-date="' + c.updated_at + '">' + c.chapter_name + '</a>').join('');
      })();
      ''',
      // Allow the AJAX fetch + DOM injection to settle before getHtml().
      'setTimeout(function(){}, 2500);',
    ];
  }
}

/// Extracts the first numeric run from a chapter title (e.g. "1" from
/// "Chapter 1: Dawn"), falling back to the last space-delimited token.
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
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    // Manganato appends ?page=N once more results exist.
    return root.querySelector('a[href*="?page="]') != null;
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    final mangas = <MangaScrapped>[];

    for (final item in root.querySelectorAll('div.item')) {
      final link =
          item.querySelector('a.searchstory_name') ??
          item.querySelector('a[href*="/manga/"]');
      if (link == null) continue;

      final href = link.attributes['href'];
      mangas.add(
        MangaScrapped(
          title: link.text.trim(),
          coverUrl: item.querySelector('img')?.attributes['src'],
          webUrl: href == null ? null : _absolute(_baseUrl, href),
          author: _itemLabel(item.text, 'Author(s)'),
        ),
      );
    }

    return mangas;
  }

  @override
  // Server-rendered; results are present without any script.
  List<String> get scripts => [];

  @override
  String url({required SearchMangaParameter parameter}) {
    final q = (parameter.title ?? '').toLowerCase().replaceAll(' ', '_');
    final page = parameter.page;
    final base = '$_baseUrl/search/story/$q';
    return page > 1 ? '$base?page=$page' : base;
  }
}

/// Reads a value from an item text blob by label prefix, e.g. "ODA Eiichiro"
/// from the line "Author(s) : ODA Eiichiro".
String? _itemLabel(String text, String label) {
  for (final line in text.split('\n')) {
    final trimmed = line.trim();
    if (!trimmed.startsWith(label)) continue;
    return trimmed
        .substring(label.length)
        .replaceFirst(RegExp(r'^[\s:]+'), '')
        .trim();
  }
  return null;
}

class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {
  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    // Genres appear as <a href="/genre/{slug}"> links in the search sidebar,
    // on genre pages, and inline on the detail page; any such link is a valid
    // tag. Dedupe by name.
    final tags = <String, String>{};

    for (final link in root.querySelectorAll('a[href^="/genre/"]')) {
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
