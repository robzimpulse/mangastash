import 'package:domain_manga/src/sources/toonily_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';

/// Search-results fixture (one `div.page-item-detail`), mirroring toonily.com
/// /?s=one+piece&post_type=wp-manga.
const _searchHtml = '''
<div class="c-tabs-item__content">
  <div class="row">
    <div class="col-4 col-md-3">
      <div class="page-item-detail">
        <div class="item-thumb">
          <a href="https://toonily.com/serie/one-piece-123/">
            <img data-src="https://toonily.com/wp-content/uploads/cover/one-piece.jpg"
                 src="https://toonily.com/wp-content/uploads/cover/one-piece-lazy.jpg" alt="cover">
          </a>
        </div>
        <div class="item-summary">
          <div class="post-title">
            <h3><a href="https://toonily.com/serie/one-piece-123/">One Piece</a></h3>
          </div>
          <div class="latest-chap">
            <a href="https://toonily.com/serie/one-piece-123/chapter-1100/">Chapter 1100</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
''';

/// Search-results fixture without a next-page link: `haveNextPage` is false.
const _noNextPageHtml = '''
<div class="page-item-detail">
  <div class="item-thumb">
    <a href="https://toonily.com/serie/one-piece-123/">
      <img data-src="https://toonily.com/wp-content/uploads/cover/one-piece.jpg" alt="cover">
    </a>
  </div>
  <div class="item-summary">
    <div class="post-title">
      <h3><a href="https://toonily.com/serie/one-piece-123/">One Piece</a></h3>
    </div>
  </div>
</div>
''';

/// Search-results fixture with a wp-pagenavi `.next` link: `haveNextPage` is
/// true.
const _nextPageHtml = '''
<div class="page-item-detail">
  <div class="item-summary">
    <div class="post-title">
      <h3><a href="https://toonily.com/serie/one-piece-123/">One Piece</a></h3>
    </div>
  </div>
</div>
<div class="wp-pagenavi" role="navigation">
  <a class="next page-numbers" href="https://toonily.com/page/2/?s=one+piece&post_type=wp-manga">Next</a>
</div>
''';

/// Series-detail fixture (toonily.com /serie/one-piece-123/): Madara
/// `div.post-content_item` info rows, `div.summary__content` synopsis,
/// badge-stripped `h1`, and `li.wp-manga-chapter` rows.
const _detailHtml = '''
<html><body>
  <div class="tab-summary">
    <div class="summary_image">
      <img src="https://toonily.com/wp-content/uploads/cover/one-piece.jpg" alt="cover">
    </div>
  </div>
  <div class="post-title">
    <h1>One Piece <span class="manga-title-badges">New</span></h1>
  </div>
  <div class="summary__content">
    <p>Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.</p>
  </div>
  <div class="post-content">
    <div class="post-content_item">
      <div class="summary-heading"><h5>Rating</h5></div>
      <div class="summary-content">4.5</div>
    </div>
    <div class="post-content_item">
      <div class="summary-heading"><h5>Status</h5></div>
      <div class="summary-content">Ongoing</div>
    </div>
    <div class="post-content_item">
      <div class="summary-heading"><h5>Author(s)</h5></div>
      <div class="summary-content author-content">
        <a href="https://toonily.com/author/oda-eiichiro/">ODA Eiichiro</a>
      </div>
    </div>
    <div class="post-content_item">
      <div class="summary-heading"><h5>Genres</h5></div>
      <div class="summary-content genres-content">
        <a href="https://toonily.com/genre/action/">Action</a>,
        <a href="https://toonily.com/genre/adventure/">Adventure</a>
      </div>
    </div>
  </div>
  <div class="listing-chapters_wrap">
    <ul class="main version-chap">
      <li class="wp-manga-chapter">
        <a href="https://toonily.com/serie/one-piece-123/chapter-1100/">Chapter 1100</a>
        <span class="chapter-release-date"><i>August 7, 2026</i></span>
      </li>
      <li class="wp-manga-chapter">
        <a href="https://toonily.com/serie/one-piece-123/chapter-1099/">Chapter 1099</a>
        <span class="chapter-release-date"><i>August 1, 2026</i></span>
      </li>
    </ul>
  </div>
</body></html>
''';

/// Reader fixture (toonily.com /serie/one-piece-123/chapter-1100/): page
/// <img>s inside `div.reading-content` carry real CDN URLs in `src`.
const _readerHtml = '''
<html><body>
  <div class="reading-content">
    <div class="page-break no-gap">
      <img class="wp-manga-chapter-img" src="https://data.tnlycdn.com/op/1100/1.jpg" alt="Page 1">
    </div>
    <div class="page-break no-gap">
      <img class="wp-manga-chapter-img" src="https://data.tnlycdn.com/op/1100/2.jpg" alt="Page 2">
    </div>
    <div class="page-break no-gap">
      <img class="wp-manga-chapter-img" src="https://data.tnlycdn.com/op/1100/3.jpg" alt="Page 3">
    </div>
  </div>
</body></html>
''';

/// Genre-index fixture (toonily.com /genres/): `a` links grouped by genre.
const _genreHtml = '''
<html><body>
  <div class="genres">
    <a href="/genre/action/">Action</a>
    <a href="/genre/adventure/">Adventure</a>
    <a href="/genre/comedy/">Comedy</a>
  </div>
</body></html>
''';

void main() {
  final source = ToonilySourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Toonily');
    expect(source.baseUrl, 'https://toonily.com');
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

  test('search url maps title to Madara query', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece'),
      ),
      'https://toonily.com/?s=One+Piece&post_type=wp-manga',
    );
  });

  test('search url maps page 2 to paginated search path', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece', page: 2),
      ),
      'https://toonily.com/page/2/?s=One+Piece&post_type=wp-manga',
    );
  });

  test('search parses a result block with absolute webUrl', () async {
    final results = await source.searchMangaUseCase.parse(
      root: html_parser.parse(_searchHtml),
    );
    expect(results, hasLength(1));
    expect(results.single.title, 'One Piece');
    expect(results.single.webUrl, 'https://toonily.com/serie/one-piece-123/');
    expect(
      results.single.coverUrl,
      'https://toonily.com/wp-content/uploads/cover/one-piece.jpg',
    );
  });

  test('search haveNextPage false without a next-page link', () async {
    final next = await source.searchMangaUseCase.haveNextPage(
      root: html_parser.parse(_noNextPageHtml),
    );
    expect(next, isFalse);
  });

  test('search haveNextPage true when a .next link is present', () async {
    final next = await source.searchMangaUseCase.haveNextPage(
      root: html_parser.parse(_nextPageHtml),
    );
    expect(next, isTrue);
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
    expect(
      manga.coverUrl,
      'https://toonily.com/wp-content/uploads/cover/one-piece.jpg',
    );
  });

  test('chapter list parses rows in order', () async {
    final chapters = await source.listChapterUseCase.parse(
      root: html_parser.parse(_detailHtml),
    );
    expect(chapters, hasLength(2));
    expect(chapters.first.title, 'Chapter 1100');
    expect(chapters.first.chapter, '1100');
    expect(
      chapters.first.webUrl,
      'https://toonily.com/serie/one-piece-123/chapter-1100/',
    );
    expect(chapters.first.publishAt, 'August 7, 2026');
  });

  test('reader parses real srcs and serves no scripts', () async {
    final images = await source.getChapterImageUseCase.parse(
      root: html_parser.parse(_readerHtml),
    );
    expect(images, [
      'https://data.tnlycdn.com/op/1100/1.jpg',
      'https://data.tnlycdn.com/op/1100/2.jpg',
      'https://data.tnlycdn.com/op/1100/3.jpg',
    ]);
    expect(source.getChapterImageUseCase.scripts, isEmpty);
  });

  test('tags parse genre page links', () async {
    final tags = await source.listTagUseCase.parse(
      root: html_parser.parse(_genreHtml),
    );
    expect(tags, hasLength(3));
    expect(tags.first.id, 'action');
    expect(tags.first.name, 'Action');
  });
}
