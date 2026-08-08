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
      _ListTagSourceExternalUseCase();
}

class _GetChapterImageSourceExternalUseCase
    implements GetChapterImageSourceExternalUseCase {
  @override
  Duration? get timeout => Duration(seconds: 30);

  @override
  Future<List<String>> parse({required Document root}) async => [];

  @override
  List<String> get scripts => [];
}

class _GetMangaSourceExternalUseCase implements GetMangaSourceExternalUseCase {
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
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final chapters = <ChapterScrapped>[];
    for (final row in root.querySelectorAll('#chapter-list a[href^="/chapters/"]')) {
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
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    return root.querySelector('button[hx-get*="/search/data"]') != null;
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    final mangas = <MangaScrapped>[];
    for (final article in root.querySelectorAll('article.bg-base-300.flex.gap-4.p-4')) {
      // The cover <a> also matches "/series/" but is empty; the title link
      // carries the line-clamp-1 class.
      final link = article.querySelector('a.line-clamp-1');
      final title = link?.text.trim();
      final coverUrl = article
          .querySelector('img[src*="temp.compsci88.com"]')
          ?.attributes['src'];
      final metadata = article.querySelectorAll('section').lastOrNull;

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
      final author = metadata?.querySelector('a.link-info')?.text.trim();
      final tags = metadata
          ?.querySelectorAll('div.opacity-70')
          .where((e) => e.querySelector('strong')?.text.contains('Tag') ?? false)
          .firstOrNull
          ?.querySelectorAll('span')
          .map((e) => e.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      mangas.add(
        MangaScrapped(
          title: title,
          coverUrl: coverUrl,
          webUrl: link?.attributes['href'],
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

    return [
      [_baseUrl, 'search', 'data'].join('/'),
      [
        MapEntry('text', parameter.title ?? ''),
        MapEntry('limit', '${parameter.limit}'),
        MapEntry('offset', '${(parameter.page - 1) * parameter.limit}'),
        const MapEntry('display_mode', 'Full Display'),
        if (sort != null) MapEntry('sort', sort),
        if (orderDirection != null) MapEntry('order', orderDirection),
        if (status != null) MapEntry('included_status', status),
        for (final tag in parameter.includedTags ?? <String>[])
          MapEntry('included_tags', tag),
      ].map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&'),
    ].join('?');
  }
}

class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {
  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    // Task 3 fills this in.
    return const [];
  }

  @override
  List<String> get scripts => [];
}
