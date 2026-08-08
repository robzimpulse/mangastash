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
/// HTML capture.
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
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<MangaScrapped> parse({required Document root}) async {
    return MangaScrapped(
      title: root.querySelector('h1')?.text.trim(),
      author: _infoValue(root, 'Author(s)'),
      description: _summary(root),
      status: _infoValue(root, 'Status'),
      tags:
          root
              .querySelectorAll('li.d-row a[href^="/genre/"]')
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

/// Reads a `li.d-row` value by label prefix, e.g. "ODA Eiichiro" from the
/// row whose label cell says "Author(s):".
String? _infoValue(Document root, String label) {
  for (final row in root.querySelectorAll('li.d-row')) {
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
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    // Results are a single batch; Katana ignores the page parameter.
    return false;
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    final mangas = <MangaScrapped>[];

    for (final item in root.querySelectorAll('div.item[data-id]')) {
      final link = item.querySelector('div.d-cell.text h3.title a');
      if (link == null) continue;

      final href = link.attributes['href'];
      mangas.add(
        MangaScrapped(
          title: link.text.trim(),
          coverUrl:
              item
                  .querySelector('div.d-cell.media div.wrap_img img')
                  ?.attributes['data-src'],
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
    return '$_baseUrl/search?keyword=$q';
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
