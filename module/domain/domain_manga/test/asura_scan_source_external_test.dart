import 'package:domain_manga/src/sources/asura_scan_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;

/// Reader fixture trimmed to the nodes the parser reads. Mirrors the current
/// asurascans.com chapter reader (Astro rebuild): images live inside
/// <div data-page="n" class="w-full"> as <img class="w-full block">. The old
/// `div.relative.w-full > img.w-full.block.relative.z-10` chain matched
/// nothing on this markup, so all images were dropped.
const _readerHtml = '''
<html><body>
<div class="min-h-screen bg-black">
  <div class="select-none">
    <div class="max-w-full md:max-w-[720px] mx-auto overflow-hidden flex flex-col leading-[0]">
      <div data-page="0" class="w-full" style="aspect-ratio:1200 / 800">
        <img src="https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/001.webp?v=1770499638"
             alt="Page 1 - Chapter 1 - Ending Maker" data-page-index="0" class="w-full block" decoding="async"/>
      </div>
      <div data-page="1" class="w-full" style="aspect-ratio:1200 / 800">
        <img src="https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/002.webp?v=1770499638"
             alt="Page 2 - Chapter 1 - Ending Maker" data-page-index="1" class="w-full block" decoding="async"/>
      </div>
      <div data-page="2" class="w-full" style="aspect-ratio:1200 / 800">
        <img src="https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/003.webp?v=1770499638"
             alt="Page 3 - Chapter 1 - Ending Maker" data-page-index="2" class="w-full block" decoding="async"/>
      </div>
    </div>
  </div>
</div>
</body></html>
''';

/// Browse-results fixture (asurascans.com /browse), captured live 2026-10
/// after the site moved to rounded-md cards. The old selector required
/// `rounded-lg`, which no longer exists, so it matched zero cards.
/// Card shape: div.series-card > a (cover) + div.p-3 (h3 title, meta spans).
const _browseHtml = '''
<html><body>
<div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4 mt-6">
  <div class="series-card group bg-[#1f1a2e] rounded-md overflow-hidden transition-all duration-200 hover:ring-2 hover:ring-[#913FE2] hover:shadow-lg hover:shadow-[#913FE2]/20">
    <a href="/comics/solo-swordmaster-3ec3b16f" class="block relative aspect-[3/4] overflow-hidden" style="aspect-ratio:3/4">
      <img src="https://cdn.asurascans.com/asura-images/covers/solo-swordmaster.467196-400.webp" alt="Solo Swordmaster" class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105" loading="lazy">
    </a>
    <div class="p-3">
      <a href="/comics/solo-swordmaster-3ec3b16f">
        <h3 class="text-sm font-semibold text-white line-clamp-1 group-hover:text-[#913FE2] transition-colors"> Solo Swordmaster </h3>
      </a>
      <div class="flex items-center gap-2 mt-2">
        <span class="text-xs font-medium text-white bg-white/10 px-2 py-1 rounded"> 10 Chapters </span>
        <span class="text-xs font-medium px-2 py-1 rounded capitalize bg-[#913FE2]/20 text-[#A78BFA]"> ongoing </span>
      </div>
    </div>
  </div>
</div>
<nav class="flex items-center justify-center mt-8 pb-8">
  <button class="w-8 h-8 flex items-center justify-center rounded-md bg-white/10 transition-all" aria-label="Previous page" disabled=""> &lt; </button>
  <button class="w-8 h-8 flex items-center justify-center rounded-md bg-white/10 transition-all" aria-label="Page 1"> 1 </button>
  <button class="w-8 h-8 flex items-center justify-center rounded-md bg-white/10 transition-all" aria-label="Next page"> &gt; </button>
</nav>
</body></html>
''';

/// Last browse page: the Next-page button exists but is disabled.
const _browseLastPageHtml = '''
<html><body>
<nav class="flex items-center justify-center mt-8 pb-8">
  <button aria-label="Next page" disabled=""> &gt; </button>
</nav>
</body></html>
''';

/// Series-detail fixture (asurascans.com /comics/{slug}), captured live
/// 2026-10. Stable anchors: h1 title, img#mobile-cover-img cover,
/// #description-text synopsis, label cell "Status" + span.capitalize value,
/// a[href^="/browse?author="], a[href^="/browse?genres="].
const _detailHtml = '''
<html><body><main>
  <div class="lg:hidden relative h-[300px]">
    <div class="relative w-[180px]" id="mobile-cover-container">
      <img src="https://cdn.asurascans.com/asura-images/covers/solo-swordmaster.467196-400.webp" alt="Solo Swordmaster" class="w-full h-full object-cover" id="mobile-cover-img">
    </div>
  </div>
  <div class="lg:flex lg:gap-9">
    <div class="lg:max-w-[400px] w-full flex flex-col gap-3 relative">
      <div class="flex gap-3 pt-4 border-t border-white/10">
        <div class="flex-1 bg-[#1C1924] rounded px-4 py-3">
          <div class="text-xs text-white/50 mb-1">Status</div>
          <div class="flex items-center gap-2">
            <span class="w-2.5 h-2.5 rounded-full bg-[#A78BFA]"></span>
            <span class="text-base font-bold text-[#A78BFA] capitalize"> ongoing </span>
          </div>
        </div>
        <div class="flex-1 bg-[#1C1924] rounded px-4 py-3">
          <div class="text-xs text-white/50 mb-1">Type</div>
          <div class="flex items-center gap-2">
            <span class="text-base font-bold text-[#913FE2] uppercase"> manhwa </span>
          </div>
        </div>
      </div>
      <div class="flex flex-col gap-2 pt-4 border-t border-white/10 mt-4">
        <div class="flex items-center justify-between bg-[#1C1924] rounded px-4 py-2.5">
          <div class="flex items-center gap-2">
            <span class="text-xs text-white/50">Author</span>
          </div>
          <a href="/browse?author=Shadowless" class="text-sm font-medium hover:text-[#913FE2] transition-colors">Shadowless</a>
        </div>
      </div>
      <div class="hidden lg:flex max-w-full gap-2 flex-wrap">
        <a href="/browse?genres=action" class="inline-flex text-xs font-medium px-3 py-1.5 bg-white/5 rounded-md border border-white/5"> Action </a>
        <a href="/browse?genres=adventure" class="inline-flex text-xs font-medium px-3 py-1.5 bg-white/5 rounded-md border border-white/5"> Adventure </a>
        <a href="/browse?genres=fantasy" class="inline-flex text-xs font-medium px-3 py-1.5 bg-white/5 rounded-md border border-white/5"> Fantasy </a>
      </div>
    </div>
    <div class="w-full mt-3 lg:mt-0">
      <article class="bg-[#1C1924] rounded-md px-3 py-4 lg:p-8">
        <h1 class="text-xl lg:text-[32px] font-semibold leading-tight"> Solo Swordmaster </h1>
        <div class="mt-3 relative">
          <div id="description-text" class="text-sm lg:text-base font-light text-white/80 leading-relaxed prose prose-invert max-w-full line-clamp-3 lg:cursor-pointer"><p>In an age when everyone draws upon the power of Constellations, there is but one man who believes in the sword.</p><p>The Last Swordmaster, Limón Asphelder.</p></div>
          <div class="hidden lg:flex justify-end mt-2">
            <button id="expand-description" class="flex items-center gap-1 text-[#913FE2] text-xs font-medium px-2 py-1 rounded"><span id="expand-text">Show more</span></button>
          </div>
        </div>
      </article>
    </div>
  </div>
</main></body></html>
''';

/// Chapter-list fixture: the Astro SSR fallback rows (astro-island
/// await-children). Premium ("Read Offline"-gated) chapters render with the
/// exact same markup as free ones — there is no per-row lock marker in the
/// current DOM, so the parser must not filter rows.
const _chapterListHtml = '''
<html><body>
<div class="mt-4">
  <astro-island uid="ZKJYEk" component-url="/_astro/ChapterListReact.BMxpg3iO.js" ssr client="load" await-children>
    <div class="bg-[#1C1924] rounded-md overflow-hidden">
      <div class="max-h-[500px] overflow-y-auto">
        <div class="divide-y divide-white/5">
          <a href="/comics/solo-swordmaster-3ec3b16f/chapter/10" data-astro-prefetch="hover" class="group flex items-center justify-between px-4 py-4 transition-colors hover:bg-white/5">
            <div class="flex items-center gap-3 min-w-0 flex-1">
              <div class="min-w-0 flex-1">
                <div class="flex items-center gap-2">
                  <span class="font-medium transition-colors text-white group-hover:text-[#913FE2]">Chapter 10</span>
                </div>
              </div>
            </div>
            <div class="flex-shrink-0 ml-3 text-right"><span class="text-sm text-white/40">Just now</span></div>
          </a>
          <a href="/comics/solo-swordmaster-3ec3b16f/chapter/9" data-astro-prefetch="hover" class="group flex items-center justify-between px-4 py-4 transition-colors hover:bg-white/5">
            <div class="flex items-center gap-3 min-w-0 flex-1">
              <div class="min-w-0 flex-1">
                <div class="flex items-center gap-2">
                  <span class="font-medium transition-colors text-white group-hover:text-[#913FE2]">Chapter 9</span>
                </div>
              </div>
            </div>
            <div class="flex-shrink-0 ml-3 text-right"><span class="text-sm text-white/40">1 day ago</span></div>
          </a>
        </div>
      </div>
    </div>
  </astro-island>
</div>
</body></html>
''';

/// Genre-filter island fixture (asurascans.com /browse): the genre list
/// ships server-rendered in the astro-island `props` attribute as
/// devalue-encoded `availableGenres` — no dropdown click needed.
const _genresIslandHtml = '''
<html><body>
<astro-island uid="Zd5p2V" component-url="/_astro/SeriesFilters.js" component-export="default" renderer-url="/_astro/client.js" props="{&quot;initialQuery&quot;:[0,&quot;&quot;],&quot;availableGenres&quot;:[1,[[0,{&quot;id&quot;:[0,1],&quot;name&quot;:[0,&quot;Action&quot;],&quot;slug&quot;:[0,&quot;action&quot;]}],[0,{&quot;id&quot;:[0,4],&quot;name&quot;:[0,&quot;Adventure&quot;],&quot;slug&quot;:[0,&quot;adventure&quot;]}],[0,{&quot;id&quot;:[0,16],&quot;name&quot;:[0,&quot;Fantasy&quot;],&quot;slug&quot;:[0,&quot;fantasy&quot;]}]]],&quot;totalCount&quot;:[0,351]}" ssr client="load" await-children>
  <button data-dropdown="true" class="h-[45px] px-3 bg-[#1f1a2e] border"><span>Genres</span></button>
</astro-island>
</body></html>
''';

void main() {
  final source = AsuraScanSourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Asura Scans');
    expect(source.baseUrl, 'https://asurascans.com');
    expect(source.builtIn, isFalse);
    expect(source.getChapterImageUseCase, isA<GetChapterImageSourceExternalUseCase>());
  });

  test('reader parses all page images in order', () async {
    final images = await source.getChapterImageUseCase
        .parse(root: html_parser.parse(_readerHtml));
    expect(images, hasLength(3));
    expect(
      images,
      [
        'https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/001.webp?v=1770499638',
        'https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/002.webp?v=1770499638',
        'https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/003.webp?v=1770499638',
      ],
    );
  });

  test('reader scripts target the current reader container', () {
    final scripts = source.getChapterImageUseCase.scripts;
    expect(scripts, isNotEmpty);
    expect(scripts.join(), contains('select-none'));
  });

  test('reader scripts are one self-contained entry', () {
    // wrapScript evaluates every entry inside its own async IIFE, so `var`
    // declarations do NOT leak between entries — an entry reading an
    // identifier declared by an earlier one throws ReferenceError, which
    // fails the whole chapter read. Scripts sharing state must be merged
    // into a single entry.
    final scripts = source.getChapterImageUseCase.scripts;

    expect(scripts, hasLength(1));
    expect(scripts.first, contains('querySelectorAll'));
    expect(scripts.first, contains('scrollIntoView'));
  });

  test('reader declares readiness on the page-image selector', () {
    expect(
      source.getChapterImageUseCase.readyWhenSelectors,
      contains('div.select-none img[data-page-index]'),
    );
  });

  test('manga scripts click the show-more toggle by text, not by position', () {
    final scripts = source.getMangaUseCase.scripts;

    expect(scripts.join(), contains('show more'));
    expect(scripts.join(), isNot(contains(')[0]')));
  });

  group('browse cards (Astro rebuild, captured live 2026-10)', () {
    test('search parses div.series-card cards', () async {
      final results = await source.searchMangaUseCase.parse(
        root: html_parser.parse(_browseHtml),
      );

      expect(results, hasLength(1));
      expect(results.single.title, 'Solo Swordmaster');
      expect(
        results.single.webUrl,
        'https://asurascans.com/comics/solo-swordmaster-3ec3b16f',
      );
      expect(
        results.single.coverUrl,
        'https://cdn.asurascans.com/asura-images/covers/solo-swordmaster.467196-400.webp',
      );
      expect(results.single.status, 'ongoing');
    });

    test('search haveNextPage true while the next-page button is enabled', () async {
      final next = await source.searchMangaUseCase.haveNextPage(
        root: html_parser.parse(_browseHtml),
      );
      expect(next, isTrue);
    });

    test('search haveNextPage false when the next-page button is disabled', () async {
      final next = await source.searchMangaUseCase.haveNextPage(
        root: html_parser.parse(_browseLastPageHtml),
      );
      expect(next, isFalse);
    });
  });

  group('series detail (Astro rebuild, captured live 2026-10)', () {
    test('parses title, cover, description, status, author and genres', () async {
      final manga = await source.getMangaUseCase.parse(
        root: html_parser.parse(_detailHtml),
      );

      expect(manga.title, 'Solo Swordmaster');
      expect(
        manga.coverUrl,
        'https://cdn.asurascans.com/asura-images/covers/solo-swordmaster.467196-400.webp',
      );
      expect(manga.description, contains('Limón Asphelder'));
      expect(manga.status, 'ongoing');
      expect(manga.author, 'Shadowless');
      expect(manga.tags, ['Action', 'Adventure', 'Fantasy']);
    });
  });

  group('chapter list (Astro SSR fallback rows)', () {
    test('parses chapter rows anchored on data-astro-prefetch', () async {
      final chapters = await source.listChapterUseCase.parse(
        root: html_parser.parse(_chapterListHtml),
      );

      expect(chapters, hasLength(2));
      expect(chapters.first.title, 'Chapter 10');
      expect(chapters.first.chapter, '10');
      expect(
        chapters.first.webUrl,
        'https://asurascans.com/comics/solo-swordmaster-3ec3b16f/chapter/10',
      );
      expect(chapters.first.readableAt, 'Just now');
    });
  });

  group('tags (astro-island props)', () {
    test('parses availableGenres from the island props without any script', () async {
      final tags = await source.listTagUseCase.parse(
        root: html_parser.parse(_genresIslandHtml),
      );

      expect(tags, hasLength(3));
      expect(tags.map((e) => e.name).toList(), [
        'Action',
        'Adventure',
        'Fantasy',
      ]);
    });

    test('needs no injected scripts and waits only for the island', () {
      expect(source.listTagUseCase.scripts, isEmpty);
      expect(source.listTagUseCase.readyWhenSelectors, ['astro-island']);
    });
  });
}
