import 'package:domain_manga/src/sources/mangakatana_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';

/// Search-results fixture (one `div.item`), mirroring mangakatana.com
/// /search?keyword=one+piece.
const _searchHtml = '''
<div class="covers">
  <div class="item" data-id="123" data-genre="Action, Adventure">
    <div class="d-cell media">
      <div class="wrap_img">
        <a href="https://mangakatana.com/manga/one-piece.123">
          <img data-src="https://mkcdn.mangakatana.com/cover/one-piece.jpg" alt="cover">
        </a>
      </div>
    </div>
    <div class="d-cell text">
      <h3 class="title"><a href="https://mangakatana.com/manga/one-piece.123">One Piece</a></h3>
      <div class="status ongoing">Ongoing</div>
      <div class="chapter"><a href="https://mangakatana.com/manga/one-piece.123/c1040">Chapter 1040</a></div>
    </div>
  </div>
</div>
''';

/// Search-results fixture using the root-search `.media` template
/// (mangakatana.com/?search=one+piece&search_by=m_name real results block):
/// `div.item[data-id]` → `.media .wrap_img img[src]` cover + `h3.title a` link.
const _searchRootHtml = '''
<div class="widget-body"></div>
<div id="book_list">
  <div class="item" data-genre=",14,15,2,3,24,17,45,21," data-id="49">
    <div class="media">
      <div class="wrap_img">
        <a href="https://mangakatana.com/manga/one-piece.49">
          <picture><img src="https://mangakatana.com/imgs/cover/04e/01/dc9fd.jpg" alt="[Cover]"></picture>
        </a>
      </div>
      <div class="status ongoing"><i class="uk-icon-tasks"></i> Ongoing</div>
    </div>
    <div class="text">
      <h3 class="title">
        <a href="https://mangakatana.com/manga/one-piece.49" target="_blank">One Piece</a><span> - Update chapter 1190</span>
      </h3>
    </div>
  </div>
</div>
''';

/// Series-detail fixture (mangakatana.com /manga/one-piece.123): `h1` title,
/// `li.d-row` info rows, `div.summary > p` description, and a chapter
/// `<table>` with `div.chapter` + `div.update_time` cells.
const _detailHtml = '''
<html><body>
  <h1>One Piece</h1>
  <div class="info">
    <ul>
      <li class="d-row">
        <div class="d-cell-small label">Author(s):</div>
        <div class="d-cell-small value">ODA Eiichiro</div>
      </li>
      <li class="d-row">
        <div class="d-cell-small label">Artist(s):</div>
        <div class="d-cell-small value">ODA Eiichiro</div>
      </li>
      <li class="d-row">
        <div class="d-cell-small label">Genres:</div>
        <div class="d-cell-small value">
          <a href="/genre/action">Action</a>, <a href="/genre/adventure">Adventure</a>
        </div>
      </li>
      <li class="d-row">
        <div class="d-cell-small label">Status:</div>
        <div class="d-cell-small value">Ongoing</div>
      </li>
    </ul>
  </div>
  <div class="summary">
    <h2>Summary</h2>
    <p>Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.</p>
  </div>
  <table>
    <tr>
      <td><div class="chapter"><a href="https://mangakatana.com/manga/one-piece.123/c1040">Chapter 1040</a></div></td>
      <td><div class="update_time">August 7, 2026</div></td>
    </tr>
    <tr>
      <td><div class="chapter"><a href="https://mangakatana.com/manga/one-piece.123/c1039">Chapter 1039</a></div></td>
      <td><div class="update_time">August 1, 2026</div></td>
    </tr>
  </table>
</body></html>
''';

/// Reader fixture (mangakatana.com /manga/one-piece.123/c1040): after the
/// injected script resolves `thzq`, each `#imgs .wrap_img img` carries its
/// real URL in `data-src`. One still-unresolved `#` placeholder must be
/// dropped by the parser.
const _readerHtml = '''
<html><body>
  <div id="imgs">
    <div class="wrap_img" data-pages="3">
      <img data-src="https://mkcdn.mangakatana.com/manga/one-piece.123/1040/1.jpg">
    </div>
    <div class="wrap_img" data-pages="3">
      <img data-src="https://mkcdn.mangakatana.com/manga/one-piece.123/1040/2.jpg">
    </div>
    <div class="wrap_img" data-pages="3">
      <img data-src="#">
    </div>
  </div>
</body></html>
''';

/// Genre-index fixture (mangakatana.com /genre): `a` links grouped by genre.
const _genreHtml = '''
<html><body>
  <div class="list">
    <a href="/genre/action">Action</a>
    <a href="/genre/adventure">Adventure</a>
    <a href="/genre/comedy">Comedy</a>
  </div>
</body></html>
''';

void main() {
  final source = MangakatanaSourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Manga Katana');
    expect(source.baseUrl, 'https://mangakatana.com');
    expect(source.builtIn, isFalse);
    expect(source.getMangaUseCase, isA<GetMangaSourceExternalUseCase>());
    expect(
      source.getChapterImageUseCase,
      isA<GetChapterImageSourceExternalUseCase>(),
    );
    expect(source.searchMangaUseCase, isA<SearchMangaSourceExternalUseCase>());
    expect(source.listChapterUseCase, isA<ListChapterSourceExternalUseCase>());
    expect(source.listTagUseCase, isA<ListTagSourceExternalUseCase>());
  });

  test('search url maps title to root path and ignores page', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece'),
      ),
      'https://mangakatana.com/?search=One+Piece&search_by=m_name',
    );
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece', page: 2),
      ),
      'https://mangakatana.com/?search=One+Piece&search_by=m_name',
    );
  });

  test('browse url maps empty title to homepage (search page is empty after JS)', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(),
      ),
      'https://mangakatana.com/',
    );
  });

  test('search url maps title to root path with search_by', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece'),
      ),
      'https://mangakatana.com/?search=One+Piece&search_by=m_name',
    );
  });

  test('search parses root-search .media template items', () async {
    final results = await source.searchMangaUseCase.parse(
      root: html_parser.parse(_searchRootHtml),
    );
    expect(results, hasLength(1));
    expect(results.single.title, 'One Piece');
    expect(
      results.single.webUrl,
      'https://mangakatana.com/manga/one-piece.49',
    );
    expect(
      results.single.coverUrl,
      'https://mangakatana.com/imgs/cover/04e/01/dc9fd.jpg',
    );
    expect(results.single.status, 'Ongoing');
  });

  test('search parses a result block with absolute webUrl', () async {
    final results = await source.searchMangaUseCase.parse(
      root: html_parser.parse(_searchHtml),
    );
    expect(results, hasLength(1));
    expect(results.single.title, 'One Piece');
    expect(
      results.single.webUrl,
      'https://mangakatana.com/manga/one-piece.123',
    );
    expect(
      results.single.coverUrl,
      'https://mkcdn.mangakatana.com/cover/one-piece.jpg',
    );
    expect(results.single.status, 'Ongoing');
    expect(results.single.tags, ['Action', 'Adventure']);
  });

  test('search haveNextPage is always false (single batch)', () async {
    final next = await source.searchMangaUseCase.haveNextPage(
      root: html_parser.parse(_searchHtml),
    );
    expect(next, isFalse);
  });

  test('detail parses series page', () async {
    final manga = await source.getMangaUseCase.parse(
      root: html_parser.parse(_detailHtml),
    );
    expect(manga.title, 'One Piece');
    expect(manga.author, 'ODA Eiichiro');
    expect(manga.status, 'Ongoing');
    expect(
      manga.description,
      'Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.',
    );
    expect(manga.tags, ['Action', 'Adventure']);
  });

  test('chapter list parses table rows in order', () async {
    final chapters = await source.listChapterUseCase.parse(
      root: html_parser.parse(_detailHtml),
    );
    expect(chapters, hasLength(2));
    expect(chapters.first.title, 'Chapter 1040');
    expect(chapters.first.chapter, '1040');
    expect(
      chapters.first.webUrl,
      'https://mangakatana.com/manga/one-piece.123/c1040',
    );
    expect(chapters.first.publishAt, 'August 7, 2026');
  });

  test('reader parses data-srcs and drops unresolved placeholders', () async {
    final images = await source.getChapterImageUseCase.parse(
      root: html_parser.parse(_readerHtml),
    );
    expect(images, [
      'https://mkcdn.mangakatana.com/manga/one-piece.123/1040/1.jpg',
      'https://mkcdn.mangakatana.com/manga/one-piece.123/1040/2.jpg',
    ]);
  });

  test('reader use case serves the thzq population script', () {
    final scripts = source.getChapterImageUseCase.scripts;
    expect(scripts, isNotEmpty);
    expect(scripts.first, contains('thzq'));
    expect(scripts.first, contains('#imgs .wrap_img img'));
    expect(scripts.length, greaterThan(1));
  });

  test('tags parse genre index links', () async {
    final tags = await source.listTagUseCase.parse(
      root: html_parser.parse(_genreHtml),
    );
    expect(tags, hasLength(3));
    expect(tags.first.id, 'action');
    expect(tags.first.name, 'Action');
  });
}
