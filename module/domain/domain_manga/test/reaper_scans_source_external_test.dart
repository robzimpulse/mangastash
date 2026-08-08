import 'package:domain_manga/src/sources/reaper_scans_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';

/// Search-results fixture (one `div.page-item-detail` block), mirroring the
/// Madara search markup.
const _searchHtml = '''
<div class="page-item-detail manga">
  <div class="item-thumb">
    <a href="https://reaperscans.co.in/manga/one-piece/">
      <img data-src="https://cdn.reaperscans.co.in/uploads/2025/01/one-piece.jpg"
           src="https://reaperscans.co.in/wp-content/uploads/2025/01/one-piece-lazy.jpg"
           alt="cover">
    </a>
  </div>
  <div class="item-summary">
    <div class="post-title">
      <h3><a href="https://reaperscans.co.in/manga/one-piece/">One Piece</a></h3>
    </div>
  </div>
</div>
''';

/// Search-results fixture without a next-page link: `haveNextPage` is false.
const _noNextPageHtml = '''
<div class="page-item-detail manga">
  <div class="item-thumb">
    <a href="https://reaperscans.co.in/manga/one-piece/">
      <img src="https://reaperscans.co.in/wp-content/uploads/2025/01/one-piece.jpg" alt="cover">
    </a>
  </div>
  <div class="item-summary">
    <div class="post-title">
      <h3><a href="https://reaperscans.co.in/manga/one-piece/">One Piece</a></h3>
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
      <h3><a href="https://reaperscans.co.in/manga/one-piece/">One Piece</a></h3>
    </div>
  </div>
</div>
<div class="wp-pagenavi" role="navigation">
  <a class="next page-numbers" href="https://reaperscans.co.in/page/2/?s=one+piece">Next</a>
</div>
''';

/// Series-detail fixture (reaperscans.co.in /manga/one-piece/): Madara
/// `div.post-content_item` info rows, `div.description-summary` synopsis,
/// badge-stripped `h1`, and `li.wp-manga-chapter` rows.
const _detailHtml = '''
<html><body>
  <div class="tab-summary">
    <div class="summary_image">
      <img src="https://reaperscans.co.in/wp-content/uploads/2025/01/one-piece.jpg" alt="cover">
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
        <a href="https://reaperscans.co.in/author/oda-eiichiro/">ODA Eiichiro</a>
      </div>
    </div>
    <div class="post-content_item">
      <div class="summary-heading"><h5>Genres</h5></div>
      <div class="summary-content genres-content">
        <a href="https://reaperscans.co.in/genre/action/">Action</a>,
        <a href="https://reaperscans.co.in/genre/adventure/">Adventure</a>
      </div>
    </div>
  </div>
  <div class="listing-chapters_wrap">
    <ul class="main version-chap">
      <li class="wp-manga-chapter">
        <a href="https://reaperscans.co.in/manga/one-piece/chapter-1100/">Chapter 1100</a>
        <span class="chapter-release-date"><i>August 7, 2026</i></span>
      </li>
      <li class="wp-manga-chapter">
        <a href="https://reaperscans.co.in/manga/one-piece/chapter-1099/">Chapter 1099</a>
        <span class="chapter-release-date"><i>August 1, 2026</i></span>
      </li>
    </ul>
  </div>
</body></html>
''';

/// Reader fixture (reaperscans.co.in /manga/one-piece/chapter-1100/): page
/// <img>s inside `div.reading-content`. The real CDN URL is in `data-src`
/// (lazyload) and `src` (resolved by the injected script before capture).
const _readerHtml = '''
<html><body>
  <div class="reading-content">
    <div class="page-break no-gap">
      <img class="wp-manga-chapter-img" data-src="https://cdn.reaperscans.co.in/op/1100/1.jpg" src="https://cdn.reaperscans.co.in/op/1100/1.jpg" alt="Page 1">
    </div>
    <div class="page-break no-gap">
      <img class="wp-manga-chapter-img" data-src="https://cdn.reaperscans.co.in/op/1100/2.jpg" src="https://cdn.reaperscans.co.in/op/1100/2.jpg" alt="Page 2">
    </div>
    <div class="page-break no-gap">
      <img class="wp-manga-chapter-img" data-src="https://cdn.reaperscans.co.in/op/1100/3.jpg" src="https://cdn.reaperscans.co.in/op/1100/3.jpg" alt="Page 3">
    </div>
  </div>
</body></html>
''';

/// Genre-index fixture (reaperscans.co.in /genre/): `a` links grouped by genre.
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
  final source = ReaperScansSourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Reaper Scans');
    expect(source.baseUrl, 'https://reaperscans.co.in');
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

  test('search url maps title to query', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece'),
      ),
      'https://reaperscans.co.in/?s=One+Piece',
    );
  });

  test('search url maps page 2 to paginated query', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece', page: 2),
      ),
      'https://reaperscans.co.in/page/2/?s=One+Piece',
    );
  });

  test('search parses a result block with absolute webUrl', () async {
    final results = await source.searchMangaUseCase.parse(
      root: html_parser.parse(_searchHtml),
    );
    expect(results, hasLength(1));
    expect(results.single.title, 'One Piece');
    expect(results.single.webUrl, 'https://reaperscans.co.in/manga/one-piece/');
    expect(
      results.single.coverUrl,
      'https://cdn.reaperscans.co.in/uploads/2025/01/one-piece.jpg',
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
      'https://reaperscans.co.in/wp-content/uploads/2025/01/one-piece.jpg',
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
      'https://reaperscans.co.in/manga/one-piece/chapter-1100/',
    );
    expect(chapters.first.publishAt, 'August 7, 2026');
  });

  test(
    'reader parses lazy srcs and serves a lazyload-resolving script',
    () async {
      final images = await source.getChapterImageUseCase.parse(
        root: html_parser.parse(_readerHtml),
      );
      expect(images, [
        'https://cdn.reaperscans.co.in/op/1100/1.jpg',
        'https://cdn.reaperscans.co.in/op/1100/2.jpg',
        'https://cdn.reaperscans.co.in/op/1100/3.jpg',
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
