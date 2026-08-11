import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

/// Flame Comics (https://flamecomics.xyz) external manga source.
///
/// The site is a custom Next.js/Mantine SPA. All browse/detail/reader content
/// is server-rendered into a `#__NEXT_DATA__` JSON script tag (SSG), so every
/// use case parses that JSON directly — no injected scripts. The browse page
/// serves the full series list; typed search is client-side on the site, so
/// the app filters the embedded series array in Dart using the searchTerm
/// threaded through SearchMangaSourceExternalUseCase.parse.
class FlameComicsSourceExternal implements SourceExternal {
  @override
  String get baseUrl => 'https://flamecomics.xyz';

  @override
  String get iconUrl => '$baseUrl/favicon.ico';

  @override
  String get name => 'Flame Comics';

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
      _ListTagSourceExternalUseCase();
}

/// Parses `#__NEXT_DATA__` JSON script tag [root].
Map<String, dynamic> _nextData(Document root) {
  final script = root.querySelector('#__NEXT_DATA__');
  if (script == null) return const {};
  final raw = script.text.trim();
  if (raw.isEmpty) return const {};
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic>
        ? (decoded['props']?['pageProps'] as Map<String, dynamic>? ?? const {})
        : const {};
  } catch (_) {
    return const {};
  }
}

/// Builds CDN cover URL for a [series], honoring the `?t=` cache-buster.
String _coverUrl(String baseUrl, dynamic series) {
  if (series is! Map) return '';
  final id = series['series_id'];
  final cover = series['cover'];
  final lastEdit = series['last_edit'];
  if (id == null || cover == null) return '';
  final base = '$baseUrl/uploads/images/series/$id/$cover';
  final t = lastEdit;
  return t is int && t > 0 ? '$base?t=$t' : base;
}

/// Joins a list field (e.g. author) into a comma-separated string, or null
/// when the value is an empty list.
String? _join(dynamic value) {
  if (value is List) {
    final joined = value.map((e) => e.toString()).join(', ');
    return joined.isEmpty ? null : joined;
  }
  return value?.toString();
}

/// Removes HTML tags from the series description (stored as HTML in the JSON).
String? _stripHtml(String? html) {
  if (html == null) return null;
  return html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class _SearchMangaSourceExternalUseCase
    implements SearchMangaSourceExternalUseCase {
  final String _baseUrl;

  const _SearchMangaSourceExternalUseCase(this._baseUrl);

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  Future<bool?> haveNextPage({required Document root}) async => false;

  @override
  Future<List<MangaScrapped>> parse({
    required Document root,
    String? searchTerm,
  }) async {
    final page = _nextData(root);
    final list = page['series'];
    if (list is! List) return const [];
    final term = searchTerm?.toLowerCase();
    final mangas = <MangaScrapped>[];
    for (final raw in list) {
      final series = raw is Map ? raw : null;
      if (series == null) continue;
      final title = series['title']?.toString() ?? '';
      if (term != null && !title.toLowerCase().contains(term)) continue;
      final id = series['series_id'];
      final webUrl = id == null ? null : '$_baseUrl/series/$id';
      mangas.add(
        MangaScrapped(
          title: title,
          coverUrl: _coverUrl('https://cdn.flamecomics.xyz', series),
          webUrl: webUrl,
          author: _join(series['author']),
          status: series['status']?.toString(),
          tags: (series['categories'] is List)
              ? (series['categories'] as List).map((e) => e.toString()).toList()
              : null,
        ),
      );
    }
    return mangas;
  }

  @override
  List<String> get scripts => const [];

  @override
  String url({required SearchMangaParameter parameter}) {
    final tagId = parameter.includedTags?.firstOrNull;
    if ((parameter.title ?? '').isEmpty && tagId != null) {
      return '$_baseUrl/genre/$tagId';
    }
    return '$_baseUrl/browse';
  }
}

class _GetMangaSourceExternalUseCase implements GetMangaSourceExternalUseCase {
  const _GetMangaSourceExternalUseCase();

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  Future<MangaScrapped> parse({required Document root}) async {
    final page = _nextData(root);
    final series = page['series'];
    if (series is! Map) {
      return const MangaScrapped();
    }
    return MangaScrapped(
      title: series['title']?.toString(),
      author: _join(series['author']),
      description: _stripHtml(series['description']?.toString()),
      status: series['status']?.toString(),
      tags: (series['categories'] is List)
          ? (series['categories'] as List).map((e) => e.toString()).toList()
          : null,
      coverUrl: _coverUrl('https://cdn.flamecomics.xyz', series),
    );
  }

  @override
  List<String> get scripts => const [];
}

class _ListChapterSourceExternalUseCase
    implements ListChapterSourceExternalUseCase {
  final String _baseUrl;

  const _ListChapterSourceExternalUseCase(this._baseUrl);

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final page = _nextData(root);
    final list = page['chapters'];
    if (list is! List) return const [];
    final chapters = <ChapterScrapped>[];
    for (final raw in list) {
      final c = raw is Map ? raw : null;
      if (c == null) continue;
      final id = c['series_id'];
      final token = c['token'];
      final webUrl = (id == null || token == null)
          ? null
          : '$_baseUrl/series/$id/$token';
      final release = c['release_date'];
      chapters.add(
        ChapterScrapped(
          title: 'Chapter ${c['chapter']}',
          chapter: c['chapter']?.toString(),
          readableAt: release?.toString(),
          publishAt: release?.toString(),
          webUrl: webUrl,
        ),
      );
    }
    return chapters;
  }

  @override
  List<String> get scripts => const [];
}

class _GetChapterImageSourceExternalUseCase
    implements GetChapterImageSourceExternalUseCase {
  const _GetChapterImageSourceExternalUseCase();

  @override
  Duration? get timeout => const Duration(seconds: 30);

  @override
  Future<List<String>> parse({required Document root}) async {
    final page = _nextData(root);
    final chapter = page['chapter'];
    if (chapter is! Map) return const [];
    final images = chapter['images'];
    final seriesId = chapter['series_id'];
    final token = chapter['token'];
    final release = chapter['release_date'];
    if (images is! Map || seriesId == null || token == null) return const [];
    final urls = <String>[];
    for (final meta in images.values) {
      final name = meta is Map ? meta['name']?.toString() : null;
      if (name == null) continue;
      final base =
          'https://cdn.flamecomics.xyz/uploads/images/series/$seriesId/$token/$name';
      urls.add(release == null ? base : '$base?$release');
    }
    return urls;
  }

  @override
  List<String> get scripts => const [];
}

class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {
  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    final tags = <String, String>{};
    for (final link in root.querySelectorAll('a[href^="/genre/"]')) {
      final name = link.text.trim();
      if (name.isEmpty) continue;
      final slug = (link.attributes['href'] ?? '')
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
  List<String> get scripts => const [];
}
