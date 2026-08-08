import 'package:domain_manga/src/sources/weeb_central_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';

/// Search-results fixture (one <article class="bg-base-300 flex gap-4 p-4">),
/// trimmed to the nodes the parser reads. Mirrors weebcentral.com /search/data.
const _searchHtml = '''
<div>
  <article class="bg-base-300 flex gap-4 p-4">
    <section class="w-full lg:w-[25%] xl:w-[20%]">
      <a href="https://weebcentral.com/series/01J76XY7E9FNDZ1DBBM6PBJPFK/One-Piece">
        <img src="https://temp.compsci88.com/cover/fallback/01J76XY7E9FNDZ1DBBM6PBJPFK.jpg" alt="cover">
      </a>
    </section>
    <section class="hidden lg:block lg:w-[75%] xl:w-[80%]">
      <a href="https://weebcentral.com/series/01J76XY7E9FNDZ1DBBM6PBJPFK/One-Piece"
         class="line-clamp-1 link link-hover">One Piece</a>
      <div class="opacity-70"><strong>Status:</strong><span>Ongoing</span></div>
      <div class="opacity-70"><strong>Author(s):</strong><a class="link link-info link-hover">ODA Eiichiro</a></div>
      <div class="opacity-70"><strong>Tag(s):</strong><span>Action</span><span>Adventure</span></div>
    </section>
  </article>
</div>
''';

/// Series-detail fixture (weebcentral.com /series/{id}/{slug}).
const _seriesHtml = '''
<html><body>
  <h1 class="hidden md:block text-2xl font-bold">One Piece</h1>
  <p class="whitespace-pre-wrap break-words">A pirate adventure.</p>
  <img src="https://temp.compsci88.com/cover/fallback/01J76XY7E9FNDZ1DBBM6PBJPFK.jpg" alt="cover">
  <div class="opacity-70"><strong>Author(s): </strong><a>ODA Eiichiro</a></div>
  <div class="opacity-70"><strong>Tags(s): </strong><span>Action</span><span>Adventure</span></div>
  <div class="opacity-70"><strong>Status: </strong><span>Ongoing</span></div>
  <div id="chapter-list" class="flex flex-col mt-2 divide-y divide-slate-500">
    <div class="flex items-center" x-data="{ new_chapter: checkNewChapter('2026-08-07T15:10:56.544424Z') }">
      <a href="/chapters/01KZECDZH06AWDQEJZAAQA9C2P" class="hover:bg-base-300 flex-1 flex items-center p-2">
        <span class="grow flex items-center gap-2"><span class="">Chapter 1190</span></span>
        <time class="text-datetime opacity-50" datetime="2026-08-07T15:10:56.544Z">2026-08-07T15:10:56.544424Z</time>
      </a>
    </div>
    <div class="flex items-center" x-data="{ new_chapter: checkNewChapter('2026-07-24T17:48:43.166298Z') }">
      <a href="/chapters/01KYAKWT8Y9JFC21GGD0X3KG9C" class="hover:bg-base-300 flex-1 flex items-center p-2">
        <span class="grow flex items-center gap-2"><span class="">Chapter 1189</span></span>
        <time class="text-datetime opacity-50" datetime="2026-07-24T17:48:43.166Z">2026-07-24T17:48:43.166298Z</time>
      </a>
    </div>
  </div>
</body></html>
''';

/// Search-results fixture with a "View More Results…" button carrying an
/// offset param, mirroring a real next page of /search/data.
const _nextPageHtml = '''
<div>
  <article class="bg-base-300 flex gap-4 p-4">
    <section class="w-full lg:w-[25%] xl:w-[20%]">
      <a href="https://weebcentral.com/series/01J76XY7E9FNDZ1DBBM6PBJPFK/One-Piece">
        <img src="https://temp.compsci88.com/cover/fallback/01J76XY7E9FNDZ1DBBM6PBJPFK.jpg" alt="cover">
      </a>
    </section>
    <section class="hidden lg:block lg:w-[75%] xl:w-[80%]">
      <a href="https://weebcentral.com/series/01J76XY7E9FNDZ1DBBM6PBJPFK/One-Piece"
         class="line-clamp-1 link link-hover">One Piece</a>
      <div class="opacity-70"><strong>Status:</strong><span>Ongoing</span></div>
    </section>
  </article>
  <button hx-get="/search/data?limit=32&offset=32&text=One+Piece"
          hx-swap="innerHTML" hx-target="#search_results" class="btn btn-primary btn-wide btn-lg">
    View More Results…
  </button>
</div>
''';

/// Search-results fixture with a view-more button that carries NO offset
/// param (last page — the server renders the button even when there is no
/// further batch); must report no next page.
const _lastPageHtml = '''
<div>
  <button hx-get="/search/data?limit=32&text=One+Piece"
          hx-swap="innerHTML" hx-target="#search_results" class="btn btn-primary btn-wide btn-lg">
    View More Results…
  </button>
</div>
''';

/// Chapter-images fixture: htmx injects page <img>s into #chapter-images
/// before HTML capture; one image carries an onerror handler (as real pages
/// do) and must still be returned.
const _imagesHtml = '''
<html><body>
<section id="chapter-images" class="w-full flex-1 flex flex-col pb-4">
  <img src="https://temp.compsci88.com/manga/One-Piece/1190-001.png" alt="Page 1">
  <img src="https://temp.compsci88.com/manga/One-Piece/1190-002.png" alt="Page 2" onerror="this.onerror=null;this.src='https://temp.compsci88.com/manga/One-Piece/1190-002.png';">
  <img src="https://temp.compsci88.com/manga/One-Piece/1190-003.png" alt="Page 3">
</section>
</body></html>
''';

/// Tag-panel fixture: genre checkboxes live only on /search, inside the
/// filter panel hidden behind the Alpine `show_filter` flag. Each is shaped
/// <input type="checkbox" form="advanced-search-form" id="tag-{Name}"> with
/// the name in the label's <span class="ml-2">. The sort radio row must be
/// ignored.
const _tagPanelHtml = '''
<html><body>
<section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mt-4"
         x-show="show_filter" x-transition>
  <fieldset class="fieldset text-base mt-2">
    <label class="fieldset-label">
      <input type="radio" class="radio" name="sort" value="Best Match" checked>
      <span class="ml-2 cursor-pointer">Best Match</span>
    </label>
  </fieldset>
  <fieldset class="fieldset text-base mt-2">
    <label class="fieldset-label">
      <input type="checkbox" class="checkbox " form="advanced-search-form"
             id="tag-Action" value="0">
      <span class="ml-2 cursor-pointer">Action</span>
    </label>
  </fieldset>
  <fieldset class="fieldset text-base mt-2">
    <label class="fieldset-label">
      <input type="checkbox" class="checkbox " form="advanced-search-form"
             id="tag-Adventure" value="0">
      <span class="ml-2 cursor-pointer">Adventure</span>
    </label>
  </fieldset>
</section>
</body></html>
''';

void main() {
  final source = WeebCentralSourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Weeb Central');
    expect(source.baseUrl, 'https://weebcentral.com');
    expect(source.builtIn, isFalse);
    expect(source.getMangaUseCase, isA<GetMangaSourceExternalUseCase>());
    expect(source.getChapterImageUseCase, isA<GetChapterImageSourceExternalUseCase>());
    expect(source.searchMangaUseCase, isA<SearchMangaSourceExternalUseCase>());
    expect(source.listChapterUseCase, isA<ListChapterSourceExternalUseCase>());
    expect(source.listTagUseCase, isA<ListTagSourceExternalUseCase>());
  });

  test('search parses a result block', () async {
    final results = await source.searchMangaUseCase
        .parse(root: html_parser.parse(_searchHtml));
    expect(results, hasLength(1));
    expect(results.single.title, 'One Piece');
    expect(
      results.single.webUrl,
      'https://weebcentral.com/series/01J76XY7E9FNDZ1DBBM6PBJPFK/One-Piece',
    );
    expect(results.single.status, 'Ongoing');
    expect(results.single.author, 'ODA Eiichiro');
    expect(results.single.tags, ['Action', 'Adventure']);
  });

  test('search haveNextPage false when no view-more button', () async {
    final next = await source.searchMangaUseCase
        .haveNextPage(root: html_parser.parse(_searchHtml));
    expect(next, isFalse);
  });

  test('detail parses series page', () async {
    final manga = await source.getMangaUseCase
        .parse(root: html_parser.parse(_seriesHtml));
    expect(manga.title, 'One Piece');
    expect(manga.author, 'ODA Eiichiro');
    expect(manga.description, 'A pirate adventure.');
    expect(manga.status, 'Ongoing');
    expect(manga.tags, ['Action', 'Adventure']);
  });

  test('chapter list parses rows in order', () async {
    final chapters = await source.listChapterUseCase
        .parse(root: html_parser.parse(_seriesHtml));
    expect(chapters, hasLength(2));
    expect(chapters.first.title, 'Chapter 1190');
    expect(chapters.first.chapter, '1190');
    expect(chapters.first.webUrl, 'https://weebcentral.com/chapters/01KZECDZH06AWDQEJZAAQA9C2P');
    expect(chapters.first.publishAt, '2026-08-07T15:10:56.544424Z');
  });

  test('search url maps sort, order, status, tags', () {
    final url = source.searchMangaUseCase.url(
      parameter: const SearchMangaParameter(
        title: 'One Piece',
        limit: 32,
        page: 1,
        orders: {SearchOrders.rating: OrderDirections.descending},
        status: [MangaStatus.ongoing],
        includedTags: ['Action', 'Adventure'],
      ),
    );
    expect(
      url,
      'https://weebcentral.com/search/data'
      '?text=One+Piece&limit=32&offset=0&display_mode=Full+Display'
      '&sort=Popularity&order=Descending&included_status=Ongoing'
      '&included_tag=Action&included_tag=Adventure',
    );
  });

  test('search url hardcodes the server page size', () {
    final url = source.searchMangaUseCase.url(
      parameter: const SearchMangaParameter(
        title: 'One Piece',
        limit: 20,
        page: 2,
      ),
    );
    expect(
      url,
      'https://weebcentral.com/search/data'
      '?text=One+Piece&limit=32&offset=32&display_mode=Full+Display',
    );
  });

  test('chapter images parse orders srcs and keeps onerror', () async {
    final images = await source.getChapterImageUseCase
        .parse(root: html_parser.parse(_imagesHtml));
    expect(
      images,
      [
        'https://temp.compsci88.com/manga/One-Piece/1190-001.png',
        'https://temp.compsci88.com/manga/One-Piece/1190-002.png',
        'https://temp.compsci88.com/manga/One-Piece/1190-003.png',
      ],
    );
  });

  test('search haveNextPage true when the view-more button carries an offset', () async {
    final next = await source.searchMangaUseCase
        .haveNextPage(root: html_parser.parse(_nextPageHtml));
    expect(next, isTrue);
  });

  test('search haveNextPage false when the view-more button has no offset', () async {
    final next = await source.searchMangaUseCase
        .haveNextPage(root: html_parser.parse(_lastPageHtml));
    expect(next, isFalse);
  });

  test('tags parse genre checkboxes', () async {
    final tags = await source.listTagUseCase
        .parse(root: html_parser.parse(_tagPanelHtml));
    expect(tags, hasLength(2));
    expect(tags.first.id, 'Action');
    expect(tags.first.name, 'Action');
  });

  test('tags use case serves the filter-panel reveal scripts', () {
    final scripts = source.listTagUseCase.scripts;
    expect(scripts, isNotEmpty);
    expect(scripts.first, contains('show_filter'));
    expect(scripts.length, greaterThan(1));
  });
}
