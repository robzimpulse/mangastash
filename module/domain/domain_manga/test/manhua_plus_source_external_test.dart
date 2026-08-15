import 'package:domain_manga/src/sources/manhua_plus_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';

/// Search-results fixture (one `div.slider__item > div.item__wrap` card),
/// mirroring the manhuaplus.com /?s=martial+peak search/homepage card shape.
const _searchHtml = '''
<div class="slider__item">
  <div class="item__wrap">
    <div class="slider__thumb">
      <div class="slider__thumb_item c-image-hover">
        <a href="https://manhuaplus.com/manga/martial-peak/">
          <img data-src="https://manhuaplus.com/wp-content/uploads/2020/07/thumbbbbb-125x180.jpg" alt="Martial Peak">
        </a>
      </div>
    </div>
    <div class="slider__content">
      <div class="slider__content_item">
        <div class="post-title font-title">
          <h4><a href="https://manhuaplus.com/manga/martial-peak/">Martial Peak</a></h4>
        </div>
      </div>
    </div>
  </div>
</div>
''';

/// Search-results fixture without a next-page link: `haveNextPage` is false.
const _noNextPageHtml = '''
<div class="page-item-detail manga">
  <div class="item-thumb">
    <a href="https://manhuaplus.com/manga/one-piece/">
      <img src="https://manhuaplus.com/wp-content/uploads/2025/01/one-piece.jpg" alt="cover">
    </a>
  </div>
  <div class="item-summary">
    <div class="post-title">
      <h3><a href="https://manhuaplus.com/manga/one-piece/">One Piece</a></h3>
    </div>
  </div>
</div>
''';

/// Search-results fixture with a `a.next.page-numbers` link: `haveNextPage`
/// is true.
const _nextPageHtml = '''
<div class="page-item-detail manga">
  <div class="item-summary">
    <div class="post-title">
      <h3><a href="https://manhuaplus.com/manga/one-piece/">One Piece</a></h3>
    </div>
  </div>
</div>
<div class="wp-pagenavi" role="navigation">
  <a class="next page-numbers" href="https://manhuaplus.com/page/2/?s=one+piece">Next</a>
</div>
''';

/// Series-detail fixture (manhuaplus.com /manga/one-piece/): Madara
/// `div.post-content_item` info rows, `div.description-summary` synopsis,
/// badge-stripped `h1`, and `li.wp-manga-chapter` rows.
const _detailHtml = '''
<html><body>
  <div class="tab-summary">
    <div class="summary_image">
      <img src="https://manhuaplus.com/wp-content/uploads/2025/01/one-piece.jpg" alt="cover">
    </div>
  </div>
  <div class="post-title">
    <h1>One Piece <span class="manga-title-badges">New</span></h1>
  </div>
  <div class="description-summary">
    <p>Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.</p>
  </div>
  <div class="post-content">
    <div class="post-content_item">
      <div class="summary-heading"><h5>Rating</h5></div>
      <div class="summary-content">4.5</div>
    </div>
    <div class="post-content_item">
      <div class="summary-heading"><h5>Status</h5></div>
      <div class="summary-content">OnGoing</div>
    </div>
    <div class="post-content_item">
      <div class="summary-heading"><h5>Author(s)</h5></div>
      <div class="summary-content author-content">
        <a href="https://manhuaplus.com/author/oda-eiichiro/">ODA Eiichiro</a>
      </div>
    </div>
    <div class="post-content_item">
      <div class="summary-heading"><h5>Genres</h5></div>
      <div class="summary-content genres-content">
        <a href="https://manhuaplus.com/manga-genre/action/">Action</a>,
        <a href="https://manhuaplus.com/manga-genre/adventure/">Adventure</a>
      </div>
    </div>
  </div>
  <div class="listing-chapters_wrap">
    <ul class="main version-chap">
      <li class="wp-manga-chapter">
        <a href="https://manhuaplus.com/manga/one-piece/chapter-1100/">Chapter 1100</a>
        <span class="chapter-release-date"><i>August 7, 2026</i></span>
      </li>
      <li class="wp-manga-chapter">
        <a href="https://manhuaplus.com/manga/one-piece/chapter-1099/">Chapter 1099</a>
        <span class="chapter-release-date"><i>August 1, 2026</i></span>
      </li>
    </ul>
  </div>
</body></html>
''';

/// Reader fixture (manhuaplus.com /manga/one-piece/chapter-1100/): page
/// <img>s inside `div.reading-content` carry real CDN URLs in `src`.
const _readerHtml = '''
<html><body>
  <div class="reading-content">
    <div class="page-break no-gap">
      <img class="wp-manga-chapter-img" src="https://cdn.mhpcdn.com/op/1100/1.jpg" alt="Page 1">
    </div>
    <div class="page-break no-gap">
      <img class="wp-manga-chapter-img" src="https://cdn.mhpcdn.com/op/1100/2.jpg" alt="Page 2">
    </div>
    <div class="page-break no-gap">
      <img class="wp-manga-chapter-img" src="https://cdn.mhpcdn.com/op/1100/3.jpg" alt="Page 3">
    </div>
  </div>
</body></html>
''';

/// Genre-index fixture (manhuaplus.com /manga-genre/): `a` links grouped by
/// genre.
const _genreHtml = '''
<html><body>
  <div class="genres">
    <a href="/manga-genre/action/">Action</a>
    <a href="/manga-genre/adventure/">Adventure</a>
    <a href="/manga-genre/comedy/">Comedy</a>
  </div>
</body></html>
''';

void main() {
  final source = ManhuaPlusSourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Manhua Plus');
    expect(source.baseUrl, 'https://manhuaplus.com');
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
      'https://manhuaplus.com/?s=One+Piece',
    );
  });

  test('search url maps page 2 to paginated search path', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece', page: 2),
      ),
      'https://manhuaplus.com/page/2/?s=One+Piece',
    );
  });

  test('browse url maps empty title to homepage (search page is empty)', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(),
      ),
      'https://manhuaplus.com/',
    );
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(page: 2),
      ),
      'https://manhuaplus.com/page/2/',
    );
  });

  test(
    'search parses a slider__item result block with absolute webUrl',
    () async {
      final results = await source.searchMangaUseCase.parse(
        root: html_parser.parse(_searchHtml),
      );
      expect(results, hasLength(1));
      expect(results.single.title, 'Martial Peak');
      expect(
        results.single.webUrl,
        'https://manhuaplus.com/manga/martial-peak/',
      );
      expect(
        results.single.coverUrl,
        'https://manhuaplus.com/wp-content/uploads/2020/07/thumbbbbb-125x180.jpg',
      );
    },
  );

  test('search parses archive page-item-detail cards', () async {
    const archiveHtml = '''
    <div class="page-listing-item">
      <div class="page-item-detail text">
        <div class="item-thumb c-image-hover" data-post-id="28594">
          <a href="https://manhuaplus.com/manga/i-am-the-fated-villain/" title="I Am the Fated Villain">
            <img data-src="https://manhuaplus.com/wp-content/uploads/2024/01/3-1-175x238.jpg" alt="3 (1)">
          </a>
        </div>
        <div class="item-summary">
          <div class="post-title font-title">
            <h4><a href="https://manhuaplus.com/manga/i-am-the-fated-villain/">I Am the Fated Villain</a></h4>
          </div>
        </div>
      </div>
    </div>
    ''';
    final results = await source.searchMangaUseCase.parse(
      root: html_parser.parse(archiveHtml),
    );
    expect(results, hasLength(1));
    expect(results.single.title, 'I Am the Fated Villain');
    expect(
      results.single.webUrl,
      'https://manhuaplus.com/manga/i-am-the-fated-villain/',
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
    expect(manga.status, 'OnGoing');
    expect(
      manga.description,
      'Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.',
    );
    expect(manga.tags, ['Action', 'Adventure']);
    expect(
      manga.coverUrl,
      'https://manhuaplus.com/wp-content/uploads/2025/01/one-piece.jpg',
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
      'https://manhuaplus.com/manga/one-piece/chapter-1100/',
    );
    expect(chapters.first.publishAt, 'August 7, 2026');
  });

  test(
    'reader parses real srcs and serves a lazyload-resolving script',
    () async {
      final images = await source.getChapterImageUseCase.parse(
        root: html_parser.parse(_readerHtml),
      );
      expect(images, [
        'https://cdn.mhpcdn.com/op/1100/1.jpg',
        'https://cdn.mhpcdn.com/op/1100/2.jpg',
        'https://cdn.mhpcdn.com/op/1100/3.jpg',
      ]);
      expect(
        source.getChapterImageUseCase.scripts.join('\n'),
        contains('data-src'),
      );
    },
  );

  test('tags parse genre page links', () async {
    final tags = await source.listTagUseCase.parse(
      root: html_parser.parse(_genreHtml),
    );
    expect(tags, hasLength(3));
    expect(tags.first.id, 'action');
    expect(tags.first.name, 'Action');
  });
}
