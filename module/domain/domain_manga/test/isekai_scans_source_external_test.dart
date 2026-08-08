import 'package:domain_manga/src/sources/isekai_scans_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';

/// Search-results fixture: the theme's `div.listupd > div.bs > div.bsx` cards
/// (isekaiscans.org /?s=one+piece).
const _searchHtml = '''
<div class="listupd">
  <div class="bs">
    <div class="bsx">
      <a href="https://isekaiscans.org/manga/one-piece/">
        <div class="limit">
          <img src="https://isekaiscans.org/wp-content/uploads/2025/01/one-piece.jpg"
               data-src="https://cdn.isekaiscans.org/2025/01/one-piece.jpg"
               alt="cover">
        </div>
        <div class="tt">One Piece</div>
      </a>
    </div>
  </div>
  <div class="bs">
    <div class="bsx">
      <a href="https://isekaiscans.org/manga/one-punch-man/">
        <div class="limit">
          <img src="https://isekaiscans.org/wp-content/uploads/2025/01/opm.jpg" alt="cover">
        </div>
        <div class="tt">One Punch Man</div>
      </a>
    </div>
  </div>
</div>
''';

/// Search-results fixture without a next-page link: `haveNextPage` is false.
const _noNextPageHtml = '''
<div class="listupd">
  <div class="bs">
    <div class="bsx">
      <a href="https://isekaiscans.org/manga/one-piece/">
        <div class="limit">
          <img src="https://isekaiscans.org/wp-content/uploads/2025/01/one-piece.jpg" alt="cover">
        </div>
        <div class="tt">One Piece</div>
      </a>
    </div>
  </div>
</div>
''';

/// Search-results fixture with a `a.next.page-numbers` link: `haveNextPage`
/// is true.
const _nextPageHtml = '''
<div class="listupd">
  <div class="bs">
    <div class="bsx">
      <a href="https://isekaiscans.org/manga/one-piece/">
        <div class="tt">One Piece</div>
      </a>
    </div>
  </div>
</div>
<div class="wp-pagenavi" role="navigation">
  <a class="next page-numbers" href="https://isekaiscans.org/page/2/?s=one+piece">Next</a>
</div>
''';

/// Search-results fixture in the generic Madara layout: `div.page-item-detail`
/// blocks fall back to the generic parser.
const _genericSearchHtml = '''
<div class="page-item-detail manga">
  <div class="item-thumb">
    <a href="https://isekaiscans.org/manga/one-piece/">
      <img src="https://isekaiscans.org/wp-content/uploads/2025/01/one-piece.jpg" alt="cover">
    </a>
  </div>
  <div class="item-summary">
    <div class="post-title">
      <h3><a href="https://isekaiscans.org/manga/one-piece/">One Piece</a></h3>
    </div>
  </div>
</div>
''';

/// Series-detail fixture (isekaiscans.org /manga/one-piece/): Madara
/// `div.post-content_item` info rows, `.summary_image` cover, and
/// `div.eplister` chapter rows.
const _detailHtml = '''
<html><body>
  <div class="summary_image">
    <img src="https://isekaiscans.org/wp-content/uploads/2025/01/one-piece.jpg" alt="cover">
  </div>
  <h1>One Piece <span class="manga-title-badges">Hot</span></h1>
  <div class="summary__content">
    <p>Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.</p>
  </div>
  <div class="post-content">
    <div class="post-content_item">
      <div class="summary-heading"><h5>Status</h5></div>
      <div class="summary-content">Ongoing</div>
    </div>
    <div class="post-content_item">
      <div class="summary-heading"><h5>Author(s)</h5></div>
      <div class="summary-content author-content">
        <a href="https://isekaiscans.org/author/oda-eiichiro/">ODA Eiichiro</a>
      </div>
    </div>
    <div class="post-content_item">
      <div class="summary-heading"><h5>Genres</h5></div>
      <div class="summary-content genres-content">
        <a href="https://isekaiscans.org/genres/action/">Action</a>,
        <a href="https://isekaiscans.org/genres/adventure/">Adventure</a>
      </div>
    </div>
  </div>
  <div class="eplister">
    <ul>
      <li>
        <a href="https://isekaiscans.org/manga/one-piece/chapter-1100/">
          <span class="chapternum">Chapter 1100</span>
          <span class="chapterdate">August 7, 2026</span>
        </a>
      </li>
      <li>
        <a href="https://isekaiscans.org/manga/one-piece/chapter-1099/">
          <span class="chapternum">Chapter 1099</span>
          <span class="chapterdate">August 1, 2026</span>
        </a>
      </li>
    </ul>
  </div>
</body></html>
''';

/// Series-detail fixture using the alternate Madara `div.summary-meta` status
/// layout: no `post-content_item` Status row, status lives in
/// `span.status`.
const _detailSummaryMetaHtml = '''
<html><body>
  <div class="post-content">
    <div class="post-content_item">
      <div class="summary-heading"><h5>Author(s)</h5></div>
      <div class="summary-content author-content">ODA Eiichiro</div>
    </div>
  </div>
  <div class="summary-meta">
    <span class="summary-meta-item status">Ongoing</span>
  </div>
</body></html>
''';

/// Reader fixture (isekaiscans.org /manga/one-piece/chapter-1100/): page
/// <img>s inside `div.reading-content` with lazyload `data-src`.
const _readerHtml = '''
<html><body>
  <div class="reading-content">
    <div class="page-break">
      <img class="wp-manga-chapter-img" data-src="https://cdn.isekaiscans.org/op/1100/1.jpg" src="https://isekaiscans.org/lazy.jpg" alt="Page 1">
    </div>
    <div class="page-break">
      <img class="wp-manga-chapter-img" data-src="https://cdn.isekaiscans.org/op/1100/2.jpg" src="https://isekaiscans.org/lazy.jpg" alt="Page 2">
    </div>
  </div>
</body></html>
''';

/// Genre-index fixture (isekaiscans.org /genres/): `a` links grouped by
/// genre.
const _genreHtml = '''
<html><body>
  <div class="genres">
    <a href="/genres/action/">Action</a>
    <a href="/genres/adventure/">Adventure</a>
    <a href="/genres/comedy/">Comedy</a>
  </div>
</body></html>
''';

void main() {
  final source = IsekaiScansSourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Isekai Scans');
    expect(source.baseUrl, 'https://isekaiscans.org');
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

  test('search url maps title to WordPress query', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece'),
      ),
      'https://isekaiscans.org/?s=One+Piece',
    );
  });

  test('search url maps page 2 to paginated search path', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'One Piece', page: 2),
      ),
      'https://isekaiscans.org/page/2/?s=One+Piece',
    );
  });

  test('search parses bsx cards with absolute webUrl', () async {
    final results = await source.searchMangaUseCase.parse(
      root: html_parser.parse(_searchHtml),
    );
    expect(results, hasLength(2));
    expect(results.first.title, 'One Piece');
    expect(results.first.webUrl, 'https://isekaiscans.org/manga/one-piece/');
    expect(
      results.first.coverUrl,
      'https://cdn.isekaiscans.org/2025/01/one-piece.jpg',
    );
    expect(results.last.title, 'One Punch Man');
  });

  test('search parses generic page-item-detail fallback', () async {
    final results = await source.searchMangaUseCase.parse(
      root: html_parser.parse(_genericSearchHtml),
    );
    expect(results, hasLength(1));
    expect(results.single.title, 'One Piece');
    expect(results.single.webUrl, 'https://isekaiscans.org/manga/one-piece/');
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

  test('detail falls back to summary-meta for status', () async {
    final manga = await source.getMangaUseCase.parse(
      root: html_parser.parse(_detailSummaryMetaHtml),
    );
    expect(manga.status, 'Ongoing');
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
      'https://isekaiscans.org/wp-content/uploads/2025/01/one-piece.jpg',
    );
  });

  test('chapter list parses eplister rows in order', () async {
    final chapters = await source.listChapterUseCase.parse(
      root: html_parser.parse(_detailHtml),
    );
    expect(chapters, hasLength(2));
    expect(chapters.first.title, 'Chapter 1100');
    expect(chapters.first.chapter, '1100');
    expect(
      chapters.first.webUrl,
      'https://isekaiscans.org/manga/one-piece/chapter-1100/',
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
        'https://isekaiscans.org/lazy.jpg',
        'https://isekaiscans.org/lazy.jpg',
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
