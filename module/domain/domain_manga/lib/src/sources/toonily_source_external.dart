import 'package:collection/collection.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

/// Toonily (https://toonily.com) external manga source.
///
/// The site runs the Madara WordPress theme and is fully server-rendered
/// HTML. Search, detail, chapter list, and reader pages are static DOM, so
/// every use case parses directly and no use case injects scripts.
class ToonilySourceExternal implements SourceExternal {
  @override
  String get baseUrl => 'https://toonily.com';

  @override
  String get iconUrl => '$baseUrl/favicon.ico';

  @override
  String get name => 'Toonily';

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
    // Each reader page <img> carries its real CDN URL in `src` (no lazyload).
    final images = root.querySelectorAll(
      'div.reading-content img.wp-manga-chapter-img',
    );

    return images
        .map((e) => e.attributes['src'])
        .nonNulls
        .map((src) => _absolute(_baseUrl, src))
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
      title: _title(root),
      author: root.querySelector('div.author-content a')?.text.trim(),
      description: _summary(root),
      status: _infoValue(root, 'Status'),
      tags:
          root
              .querySelectorAll('div.genres-content a')
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      coverUrl:
          root.querySelector('div.tab-summary img')?.attributes['data-src'] ??
          root.querySelector('div.tab-summary img')?.attributes['src'],
    );
  }

  @override
  List<String> get scripts => [];
}

/// Extracts the `h1` title, stripping Madara badge spans (e.g. "New", "Hot")
/// that the theme appends to the heading.
String? _title(Document root) {
  final h1 = root.querySelector('h1');
  if (h1 == null) return null;

  final clone = h1.clone(true);
  clone.querySelectorAll('.manga-title-badges').forEach((e) => e.remove());
  return clone.text.trim();
}

/// Reads a `div.post-content_item` value by heading label, e.g. "Ongoing"
/// for the block whose heading says "Status".
String? _infoValue(Document root, String label) {
  for (final item in root.querySelectorAll('div.post-content_item')) {
    final heading = item.querySelector('.summary-heading, h5')?.text.trim();
    if (heading == null || !heading.contains(label)) continue;
    return item.querySelectorAll('.summary-content').lastOrNull?.text.trim();
  }
  return null;
}

/// Extracts the series synopsis from the Madara `div.summary__content` block,
/// falling back to `.description-summary`.
String? _summary(Document root) {
  return root.querySelector('div.summary__content')?.text.trim() ??
      root.querySelector('.description-summary')?.text.trim();
}

class _ListChapterSourceExternalUseCase
    implements ListChapterSourceExternalUseCase {
  final String _baseUrl;

  const _ListChapterSourceExternalUseCase(this._baseUrl);

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    return root.querySelectorAll('li.wp-manga-chapter').map((row) {
      final link = row.querySelector('a');
      final title = link?.text.trim();
      final href = link?.attributes['href'];
      final date =
          row.querySelector('span.chapter-release-date i')?.text.trim();

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
  List<String> get scripts => [];
}

/// Extracts the first numeric run from a chapter title (e.g. "1100" from
/// "Chapter 1100"), falling back to the last space-delimited token.
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
    // Madara search pagination renders a wp-pagenavi `.next` link, or a
    // `/page/{n}/` (n > 1) URL, once more results exist.
    if (root.querySelector('.wp-pagenavi .next') != null) return true;

    for (final link in root.querySelectorAll('a[href*="/page/"]')) {
      final page = RegExp(
        r'/page/(\d+)/',
      ).firstMatch(link.attributes['href'] ?? '')?.group(1);
      if (page != null && (int.tryParse(page) ?? 0) > 1) return true;
    }
    return false;
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    final mangas = <MangaScrapped>[];

    for (final item in root.querySelectorAll('div.page-item-detail')) {
      final link =
          item.querySelector('div.item-summary div.post-title h3 a') ??
          item.querySelector('a[href*="/serie/"]');
      if (link == null) continue;

      final href = link.attributes['href'];
      final cover = item.querySelector('div.item-thumb img');
      mangas.add(
        MangaScrapped(
          title: link.text.trim(),
          coverUrl: cover?.attributes['data-src'] ?? cover?.attributes['src'],
          webUrl: href == null ? null : _absolute(_baseUrl, href),
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
    final q = Uri.encodeQueryComponent(parameter.title ?? '');
    if (parameter.page > 1) {
      return '$_baseUrl/search/$q/page/${parameter.page}/';
    }
    return '$_baseUrl/?s=$q&post_type=wp-manga';
  }
}

class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {
  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    // Genres appear as <a href="/genre/{slug}"> links on the genre index and
    // inline on detail pages; any such link is a valid tag. Dedupe by name.
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
