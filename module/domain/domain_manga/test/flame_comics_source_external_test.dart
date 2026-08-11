import 'package:domain_manga/src/sources/flame_comics_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';

/// Browse-page fixture: the full series list is server-rendered into the
/// `#__NEXT_DATA__` JSON script tag (SSG).
const _browseHtml = '''
<html><head>
<script id="__NEXT_DATA__" type="application/json">{"props":{"__N_SSG":true,"pageProps":{"series":[
{"series_id":83,"title":"The Novel's Extra (Remake)","description":"<p>Waking up...</p>","language":"English","type":"Manhwa","categories":["Action","Fantasy"],"country":"KR","author":["Jee Gab Song"],"artist":["Carrotoon"],"publisher":["Kakao"],"year":2022,"status":"Ongoing","likes":304,"cover":"thumbnail.png","last_edit":1770648760},
{"series_id":165,"title":"Solo Leveling","description":"<p>...</p>","language":"English","type":"Manhwa","categories":["Action"],"country":"KR","author":["Chugong"],"artist":[],"publisher":[],"year":2018,"status":"Ongoing","likes":100,"cover":"thumbnail.webp","last_edit":0}
]}}}</script>
</head><body>
  <a class="DescSeriesCard_imageLink__abc123" href="/series/83"><img alt="The Novel's Extra (Remake)" src="/_next/image?url=..."></a>
  <a class="DescSeriesCard_imageLink__abc124" href="/series/165"><img alt="Solo Leveling" src="/_next/image?url=..."></a>
</body></html>
''';

/// Series-detail fixture: `pageProps.series` plus `pageProps.chapters`.
const _detailHtml = '''
<html><head>
<script id="__NEXT_DATA__" type="application/json">{"props":{"__N_SSG":true,"pageProps":{"series":{
"series_id":83,"title":"The Novel's Extra (Remake)","description":"<p>Waking up...</p>","language":"English","type":"Manhwa","categories":["Action","Fantasy"],"country":"KR","author":["Jee Gab Song"],"artist":["Carrotoon"],"publisher":["Kakao"],"year":2022,"status":"Ongoing","likes":304,"cover":"thumbnail.png","last_edit":1770648760},
"chapters":[
{"chapter_id":12085,"series_id":83,"chapter":"168.00","title":"","cover":1,"release_date":1786371624,"token":"9d98b865a4d0531d"},
{"chapter_id":12084,"series_id":83,"chapter":"167.00","title":"","cover":1,"release_date":1786285224,"token":"ab12cd34ef567890"}
]}}}</script>
</head><body>
  <a class="ChapterCard_chapterWrapper__xyz" href="/series/83/9d98b865a4d0531d">
    <p class="mantine-Text-root">Chapter 168</p>
  </a>
</body></html>
''';

/// Reader fixture: `pageProps.chapter.images` is a dict keyed by page index.
const _readerHtml = '''
<html><head>
<script id="__NEXT_DATA__" type="application/json">{"props":{"__N_SSG":true,"pageProps":{"chapter":{
"series_id":83,"chapter_id":12085,"chapter":"168.00","token":"9d98b865a4d0531d","release_date":1786371624,
"images":{"0":{"size":494766,"type":"image/jpeg","name":"TNE-168-00.jpg","width":1778,"height":1000},
"1":{"size":1797715,"type":"image/jpeg","name":"TNE-168-01.jpg","width":800,"height":12040}}
}}}}</script>
</head><body>
  <img alt="TNE-168-00.jpg" src="https://cdn.flamecomics.xyz/uploads/images/series/83/9d98b865a4d0531d/TNE-168-00.jpg?1786371624">
</body></html>
''';

/// Genre-nav fixture: `a[href="/genre/{Name}"]` links.
const _genreHtml = '''
<html><body>
  <a href="/genre/Action">Action</a>
  <a href="/genre/Fantasy">Fantasy</a>
</body></html>
''';

void main() {
  final source = FlameComicsSourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Flame Comics');
    expect(source.baseUrl, 'https://flamecomics.xyz');
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

  test('search url with empty title maps to browse', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(),
      ),
      'https://flamecomics.xyz/browse',
    );
  });

  test('search url with includedTags maps to genre', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(includedTags: ['Action']),
      ),
      'https://flamecomics.xyz/genre/Action',
    );
  });

  test('search url with title maps to browse (client-side filter)', () {
    expect(
      source.searchMangaUseCase.url(
        parameter: const SearchMangaParameter(title: 'Solo Leveling'),
      ),
      'https://flamecomics.xyz/browse',
    );
  });

  test('search parses the embedded series array', () async {
    final results = await source.searchMangaUseCase.parse(
      root: html_parser.parse(_browseHtml),
    );
    expect(results, hasLength(2));
    expect(results.first.title, "The Novel's Extra (Remake)");
    expect(
      results.first.coverUrl,
      'https://cdn.flamecomics.xyz/uploads/images/series/83/thumbnail.png?t=1770648760',
    );
    expect(results.first.webUrl, 'https://flamecomics.xyz/series/83');
    expect(results.first.tags, ['Action', 'Fantasy']);
    expect(results.last.title, 'Solo Leveling');
  });

  test('search parse filters by searchTerm case-insensitively', () async {
    final results = await source.searchMangaUseCase.parse(
      root: html_parser.parse(_browseHtml),
      searchTerm: 'solo',
    );
    expect(results, hasLength(1));
    expect(results.single.title, 'Solo Leveling');
  });

  test('search haveNextPage is always false', () async {
    final next = await source.searchMangaUseCase.haveNextPage(
      root: html_parser.parse(_browseHtml),
    );
    expect(next, isFalse);
  });

  test('detail parses series and chapters from NEXT_DATA', () async {
    final manga = await source.getMangaUseCase.parse(
      root: html_parser.parse(_detailHtml),
    );
    expect(manga.title, "The Novel's Extra (Remake)");
    expect(manga.status, 'Ongoing');
    expect(manga.tags, ['Action', 'Fantasy']);

    final chapters = await source.listChapterUseCase.parse(
      root: html_parser.parse(_detailHtml),
    );
    expect(chapters, hasLength(2));
    expect(
      chapters.first.webUrl,
      'https://flamecomics.xyz/series/83/9d98b865a4d0531d',
    );
    expect(chapters.first.chapter, '168.00');
    expect(chapters.first.title, 'Chapter 168.00');
  });

  test('reader parses ordered CDN urls and serves no scripts', () async {
    final images = await source.getChapterImageUseCase.parse(
      root: html_parser.parse(_readerHtml),
    );
    expect(images, [
      'https://cdn.flamecomics.xyz/uploads/images/series/83/9d98b865a4d0531d/TNE-168-00.jpg?1786371624',
      'https://cdn.flamecomics.xyz/uploads/images/series/83/9d98b865a4d0531d/TNE-168-01.jpg?1786371624',
    ]);
    expect(source.getChapterImageUseCase.scripts, isEmpty);
  });

  test('tags parse genre links', () async {
    final tags = await source.listTagUseCase.parse(
      root: html_parser.parse(_genreHtml),
    );
    expect(tags, hasLength(2));
    expect(tags.first.id, 'Action');
    expect(tags.first.name, 'Action');
  });
}
