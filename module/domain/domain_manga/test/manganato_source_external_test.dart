import 'package:domain_manga/src/sources/manganato_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';

/// Search-results fixture (one `div.item`), mirroring manganato.gg
/// /search/story/one_piece.
const _searchHtml = '''
<div class="panel-search-story">
  <div class="item">
    <a class="item-img book_avatar" href="https://manganato.gg/manga/op001/">
      <img src="https://avt.mkklcdnv6temp.com/one-piece-cover.jpg" alt="cover">
    </a>
    <div class="search_result_item_right">
      <div class="search_result_row1">
        <a class="searchstory_name" href="https://manganato.gg/manga/op001/">One Piece</a>
      </div>
      <div class="search_result_row2">Author(s) : ODA Eiichiro</div>
      <div class="search_result_row3">Updated : 2 hours ago</div>
    </div>
  </div>
</div>
''';

/// Search-results fixture with a pagination link, mirroring a real next page.
const _nextPageHtml = '''
<div class="panel-search-story">
  <div class="item">
    <a class="item-img book_avatar" href="https://manganato.gg/manga/op001/">
      <img src="https://avt.mkklcdnv6temp.com/one-piece-cover.jpg" alt="cover">
    </a>
    <div class="search_result_item_right">
      <div class="search_result_row1">
        <a class="searchstory_name" href="https://manganato.gg/manga/op001/">One Piece</a>
      </div>
    </div>
  </div>
  <div class="panel-page-number">
    <a class="page-next page_blue" href="/search/story/one_piece?page=2">Next</a>
  </div>
</div>
''';

/// Series-detail fixture (manganato.gg /manga/op001/).
const _detailHtml = '''
<html><body>
  <div class="manga-detail">
    <div class="manga-info-pic">
      <img src="https://avt.mkklcdnv6temp.com/one-piece-cover.jpg" alt="cover">
    </div>
    <div class="manga-info-content">
      <h1>One Piece</h1>
      <ul class="manga-info-text">
        <li><i class="fa fa-user"></i>Author(s) : ODA Eiichiro</li>
        <li><i class="fa fa-check-circle"></i>Status : Ongoing</li>
        <li class="genres">
          <i class="fa fa-tags"></i>Genres :
          <a href="/genre/action" title="Action">Action</a>,
          <a href="/genre/adventure" title="Adventure">Adventure</a>
        </li>
      </ul>
    </div>
  </div>
  <div id="contentBox">
    <h3 class="info-title">Summary :</h3>
    <p>Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.</p>
  </div>
</body></html>
''';

/// Chapter-list fixture: the AJAX script renders `<a data-chapter-title>`
/// rows into `#chapter-list-container` before HTML capture.
const _chaptersHtml = '''
<html><body>
  <div id="chapter-list-container" data-comic-slug="op001"
       data-api-url="/api/manga/op001/chapters"
       data-chapter-url-template="/manga/__MANGA__/chapter-__CHAPTER__">
    <a href="/manga/op001/chapter-1" data-chapter-title="Chapter 1"
       data-chapter-date="2026-08-07T10:00:00.000Z">Chapter 1</a>
    <a href="/manga/op001/chapter-2" data-chapter-title="Chapter 2"
       data-chapter-date="2026-08-01T10:00:00.000Z">Chapter 2</a>
  </div>
</body></html>
''';

/// Reader fixture (manganato.gg /manga/op001/chapter-1): page <img>s inside
/// `div.container-chapter-reader`, one carrying an onerror fallback duplicate.
const _readerHtml = '''
<html><body>
  <div class="container-chapter-reader">
    <img src="https://2xstorage.gg/op001/ch1/1.jpg" alt="Page 1">
    <img src="https://2xstorage.gg/op001/ch1/2.jpg" alt="Page 2"
         onerror="this.onerror=null;this.src='https://2xstorage.gg/op001/ch1/2-fallback.jpg';">
    <img src="https://2xstorage.gg/op001/ch1/2.jpg" alt="Page 2 dup">
    <img src="https://2xstorage.gg/op001/ch1/3.jpg" alt="Page 3">
  </div>
</body></html>
''';

/// Genre-page fixture (manganato.gg /genre/action): `a` links inside
/// `div.genre-list`.
const _genreHtml = '''
<html><body>
  <div class="genre-list">
    <a href="/genre/action" title="Action">Action</a>
    <a href="/genre/adventure" title="Adventure">Adventure</a>
    <a href="/genre/comedy" title="Comedy">Comedy</a>
  </div>
</body></html>
''';

void main() {
  final source = ManganatoSourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Manganato');
    expect(source.baseUrl, 'https://manganato.gg');
    expect(source.builtIn, isFalse);
    expect(source.getMangaUseCase, isA<GetMangaSourceExternalUseCase>());
    expect(source.getChapterImageUseCase, isA<GetChapterImageSourceExternalUseCase>());
    expect(source.searchMangaUseCase, isA<SearchMangaSourceExternalUseCase>());
    expect(source.listChapterUseCase, isA<ListChapterSourceExternalUseCase>());
    expect(source.listTagUseCase, isA<ListTagSourceExternalUseCase>());
  });

  test('search url maps title to slug and page', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece'),
      ),
      'https://manganato.gg/search/story/one_piece',
    );
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece', page: 2),
      ),
      'https://manganato.gg/search/story/one_piece?page=2',
    );
  });

  test('search parses a result block with absolute webUrl', () async {
    final results = await source.searchMangaUseCase
        .parse(root: html_parser.parse(_searchHtml));
    expect(results, hasLength(1));
    expect(results.single.title, 'One Piece');
    expect(
      results.single.webUrl,
      'https://manganato.gg/manga/op001/',
    );
    expect(
      results.single.coverUrl,
      'https://avt.mkklcdnv6temp.com/one-piece-cover.jpg',
    );
    expect(results.single.author, 'ODA Eiichiro');
  });

  test('search haveNextPage false when no pagination link', () async {
    final next = await source.searchMangaUseCase
        .haveNextPage(root: html_parser.parse(_searchHtml));
    expect(next, isFalse);
  });

  test('search haveNextPage true when a ?page= link is present', () async {
    final next = await source.searchMangaUseCase
        .haveNextPage(root: html_parser.parse(_nextPageHtml));
    expect(next, isTrue);
  });

  test('detail parses series page', () async {
    final manga = await source.getMangaUseCase
        .parse(root: html_parser.parse(_detailHtml));
    expect(manga.title, 'One Piece');
    expect(manga.author, 'ODA Eiichiro');
    expect(manga.status, 'Ongoing');
    expect(
      manga.description,
      'Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.',
    );
    expect(manga.tags, ['Action', 'Adventure']);
    expect(
      manga.coverUrl,
      'https://avt.mkklcdnv6temp.com/one-piece-cover.jpg',
    );
  });

  test('chapter list parses injected rows in order', () async {
    final chapters = await source.listChapterUseCase
        .parse(root: html_parser.parse(_chaptersHtml));
    expect(chapters, hasLength(2));
    expect(chapters.first.title, 'Chapter 1');
    expect(chapters.first.chapter, '1');
    expect(chapters.first.webUrl, 'https://manganato.gg/manga/op001/chapter-1');
    expect(chapters.first.publishAt, '2026-08-07T10:00:00.000Z');
  });

  test('chapter list use case serves the AJAX fetch scripts', () {
    final scripts = source.listChapterUseCase.scripts;
    expect(scripts, isNotEmpty);
    expect(scripts.first, contains('chapter-list-container'));
    expect(scripts.length, greaterThan(1));
  });

  test('reader parses and dedupes image srcs', () async {
    final images = await source.getChapterImageUseCase
        .parse(root: html_parser.parse(_readerHtml));
    expect(
      images,
      [
        'https://2xstorage.gg/op001/ch1/1.jpg',
        'https://2xstorage.gg/op001/ch1/2.jpg',
        'https://2xstorage.gg/op001/ch1/3.jpg',
      ],
    );
  });

  test('tags parse genre page links', () async {
    final tags = await source.listTagUseCase
        .parse(root: html_parser.parse(_genreHtml));
    expect(tags, hasLength(3));
    expect(tags.first.id, 'action');
    expect(tags.first.name, 'Action');
  });
}
