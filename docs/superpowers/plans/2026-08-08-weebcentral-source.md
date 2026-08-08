# WeebCentral Source Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `weebcentral.com` as a new external manga source in `mangastash` implementing all five `SourceExternal` use cases.

**Architecture:** One new file `module/domain/domain_manga/lib/src/sources/weeb_central_source_external.dart` mirroring the Asura source's structure: a public `WeebCentralSourceExternal` plus private per-use-case classes. Registered in `Sources.values`. All parsing is over the `html.Document` returned by `HeadlessWebviewUseCase.open`; `scripts` run in the webview after page load and before HTML capture. The reader's images require a script that triggers the page's own htmx fetch to inject `<img>`s, because the initial chapter HTML contains none.

**Tech Stack:** Flutter/Dart, `html` parser, `collection`, `manga_dex_api` (enums `SearchOrders`/`OrderDirections`/`MangaStatus`, `SearchMangaParameter`), `entity_manga_external` (contract + `MangaScrapped`/`ChapterScrapped`/`TagScrapped`).

## Global Constraints

- Single quotes for strings; mandatory trailing commas; relative imports within a package; sorted/grouped imports (Dart, package, relative).
- Always declare return types for functions/methods.
- `Sources.values` list in `module/domain/domain_manga/lib/src/sources/sources.dart` is the registration point.
- Parsers must not throw on absent nodes — optional-chaining and `nonNulls` only (matches existing sources).
- Generated code: none needed (no models/tables/API changed).
- Run `melos run refresh` only if the workspace link breaks (not expected — no new deps).
- Non-trivial parsers leave ONE runnable check behind: a `flutter test` in `domain_manga` pinning the selectors.

---

### Task 1: WeebCentral source file — search, detail, chapters

**Files:**
- Create: `module/domain/domain_manga/lib/src/sources/weeb_central_source_external.dart`
- Test: `module/domain/domain_manga/test/weeb_central_source_external_test.dart`

**Interfaces:**
- Consumes: `SourceExternal`, `GetMangaSourceExternalUseCase`, `SearchMangaSourceExternalUseCase`, `ListChapterSourceExternalUseCase`, `ListChapterSourceExternalUseCase`, `MangaScrapped`, `ChapterScrapped` (from `package:entity_manga_external/entity_manga_external.dart`); `SearchMangaParameter`, `SearchOrders`, `OrderDirections`, `MangaStatus` (from `package:manga_dex_api/manga_dex_api.dart`).
- Produces: `WeebCentralSourceExternal` — implements `SourceExternal` with `name`/`iconUrl`/`baseUrl`/`builtIn=false` and five use-case getters. `_SearchMangaSourceExternalUseCase` exposes `url({required SearchMangaParameter parameter})` (Task 2 extends it). `_ListTagSourceExternalUseCase` is a stub here, fully implemented in Task 3.

- [ ] **Step 1: Write the failing test**

Create `test/weeb_central_source_external_test.dart`:

```dart
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:domain_manga/src/sources/weeb_central_source_external.dart';

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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd module/domain/domain_manga && flutter test test/weeb_central_source_external_test.dart`
Expected: FAIL — `weeb_central_source_external.dart` does not exist / `WeebCentralSourceExternal` undefined.

- [ ] **Step 3: Write the source file**

Create `lib/src/sources/weeb_central_source_external.dart`:

```dart
import 'package:collection/collection.dart';
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
      _ListTagSourceExternalUseCase(baseUrl);
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

    String? rowValue(Document root, String label) {
      final node = root.querySelector('strong');
      for (final strong in [...?root.querySelectorAll('strong')]) {
        if (strong.text.trim().contains(label)) {
          final container = strong.parent;
          final value = container?.querySelector('span');
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
    for (final strong in [...?root.querySelectorAll('strong')]) {
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
      final link = article.querySelector('a[href*="/series/"]');
      final title = link?.text.trim();
      final coverUrl = article
          .querySelector('img[src*="temp.compsci88.com"]')
          ?.attributes['src'];
      final metadata = article.querySelectorAll('section').lastOrNull;

      // Scan the metadata rows for the "Status:" label — Year is the first
      // .opacity-70 row, so we cannot rely on position.
      String? rowValue(Element container, String label) {
        for (final strong in [...?container.querySelectorAll('strong')]) {
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
    return [
      [_baseUrl, 'search', 'data'].join('/'),
      [
        MapEntry('text', parameter.title ?? ''),
        MapEntry('limit', '${parameter.limit}'),
        MapEntry('offset', '${(parameter.page - 1) * parameter.limit}'),
        const MapEntry('display_mode', 'Full Display'),
      ].map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&'),
    ].join('?');
  }
}

class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {
  final String _baseUrl;

  const _ListTagSourceExternalUseCase(this._baseUrl);

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
```

Note: `_SearchMangaSourceExternalUseCase` and `_ListTagSourceExternalUseCase` are stubbed here; Task 2 and Task 3 replace their bodies. Keep the file compiling.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd module/domain/domain_manga && flutter test test/weeb_central_source_external_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add module/domain/domain_manga/lib/src/sources/weeb_central_source_external.dart module/domain/domain_manga/test/weeb_central_source_external_test.dart
git commit -m "feat(domain_manga): add weebcentral source (search, detail, chapters)"
```

---

### Task 2: Search URL mapping for sort/status/tags

**Files:**
- Modify: `module/domain/domain_manga/lib/src/sources/weeb_central_source_external.dart` (the `_SearchMangaSourceExternalUseCase.url` method)
- Modify: `module/domain/domain_manga/test/weeb_central_source_external_test.dart`

**Interfaces:**
- Consumes: `SearchMangaParameter` fields `title`, `limit`, `page`, `orders` (`Map<SearchOrders, OrderDirections>`), `status` (`List<MangaStatus>`), `includedTags` (`List<String>`).
- Produces: `String url({required SearchMangaParameter parameter})` with the full weebcentral query.

- [ ] **Step 1: Add the failing test**

In `test/weeb_central_source_external_test.dart`, append:

```dart
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
    '?text=One%20Piece&limit=32&offset=0&display_mode=Full%20Display'
    '&sort=Popularity&order=Descending&included_status=Ongoing'
    '&included_tags=Action&included_tags=Adventure',
  );
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd module/domain/domain_manga && flutter test test/weeb_central_source_external_test.dart`
Expected: FAIL on the new test (url lacks sort/order/status/tags).

- [ ] **Step 3: Implement the mapping**

Replace the `url` method body in `_SearchMangaSourceExternalUseCase`:

```dart
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

    return [
      [_baseUrl, 'search', 'data'].join('/'),
      [
        MapEntry('text', parameter.title ?? ''),
        MapEntry('limit', '${parameter.limit}'),
        MapEntry('offset', '${(parameter.page - 1) * parameter.limit}'),
        const MapEntry('display_mode', 'Full Display'),
        if (sort != null) MapEntry('sort', sort),
        if (order?.value == OrderDirections.ascending)
          const MapEntry('order', 'Ascending'),
        if (status != null) MapEntry('included_status', status),
        for (final tag in parameter.includedTags ?? <String>[])
          MapEntry('included_tags', tag),
      ].map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&'),
    ].join('?');
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd module/domain/domain_manga && flutter test test/weeb_central_source_external_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add module/domain/domain_manga/lib/src/sources/weeb_central_source_external.dart module/domain/domain_manga/test/weeb_central_source_external_test.dart
git commit -m "feat(domain_manga): map weebcentral search sort/status/tags"
```

---

### Task 3: Chapter images script + parse, and tags

**Files:**
- Modify: `module/domain/domain_manga/lib/src/sources/weeb_central_source_external.dart` (`_GetChapterImageSourceExternalUseCase` and `_ListTagSourceExternalUseCase`)
- Modify: `module/domain/domain_manga/test/weeb_central_source_external_test.dart`

**Interfaces:**
- Consumes: the `baseUrl` passed into `_ListTagSourceExternalUseCase(baseUrl)`.
- Produces: `_GetChapterImageSourceExternalUseCase.scripts` (2-element `List<String>`) and `.parse` returning `List<String>`; `_ListTagSourceExternalUseCase.parse` returning `List<TagScrapped>`.

- [ ] **Step 1: Add the failing tests**

In `test/weeb_central_source_external_test.dart`, append:

```dart
const _imagesHtml = '''
<html><body>
<section id="chapter-images" class="w-full flex-1 flex flex-col pb-4">
  <img src="https://temp.compsci88.com/manga/One-Piece/1190-001.png" alt="Page 1">
  <img src="https://temp.compsci88.com/manga/One-Piece/1190-002.png" alt="Page 2">
  <img src="/static/images/broken_image.jpg" alt="broken">
</section>
</body></html>
''';

const _tagPanelHtml = '''
<html><body>
<section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mt-4">
  <fieldset class="fieldset text-base mt-2">
    <label class="fieldset-label">
      <input type="radio" class="radio" name="sort" value="Best Match" checked>
      <span class="ml-2 cursor-pointer">Best Match</span>
    </label>
  </fieldset>
  <fieldset class="fieldset text-base mt-2">
    <label class="fieldset-label">
      <input type="checkbox" class="checkbox" name="included_tags" value="Action">
      <span class="ml-2 cursor-pointer">Action</span>
    </label>
  </fieldset>
  <fieldset class="fieldset text-base mt-2">
    <label class="fieldset-label">
      <input type="checkbox" class="checkbox" name="included_tags" value="Adventure">
      <span class="ml-2 cursor-pointer">Adventure</span>
    </label>
  </fieldset>
</section>
</body></html>
''';

test('chapter images parse orders srcs and skips broken', () async {
  final images = await source.getChapterImageUseCase
      .parse(root: html_parser.parse(_imagesHtml));
  expect(
    images,
    [
      'https://temp.compsci88.com/manga/One-Piece/1190-001.png',
      'https://temp.compsci88.com/manga/One-Piece/1190-002.png',
    ],
  );
});

test('tags parse genre checkboxes', () async {
  final tags = await source.listTagUseCase
      .parse(root: html_parser.parse(_tagPanelHtml));
  expect(tags, hasLength(2));
  expect(tags.first.id, 'Action');
  expect(tags.first.name, 'Action');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd module/domain/domain_manga && flutter test test/weeb_central_source_external_test.dart`
Expected: FAIL — `_GetChapterImageSourceExternalUseCase.parse` returns empty, `_ListTagSourceExternalUseCase.parse` returns empty.

- [ ] **Step 3: Implement chapter images**

Replace `_GetChapterImageSourceExternalUseCase`:

```dart
class _GetChapterImageSourceExternalUseCase
    implements GetChapterImageSourceExternalUseCase {
  @override
  Duration? get timeout => Duration(seconds: 30);

  @override
  Future<List<String>> parse({required Document root}) async {
    final region = root.querySelector('section#chapter-images');
    final images = region?.querySelectorAll('img') ?? [];

    return [
      for (final image in images)
        if (!(image.attributes['src']?.contains('broken_image') ?? false))
          image.attributes['src'],
    ].nonNulls.toList();
  }

  @override
  List<String> get scripts {
    return [
      // The source class does not know the chapter id (the use case receives
      // only the Document), so the script derives it from the page URL:
      // /chapters/{id}. It then triggers the same htmx ajax the reader's
      // Alpine singlePageNavigation init performs. reading_style=long_strip
      // injects all page <img>s into #chapter-images before getHtml().
      '''
      (function() {
        const el = document.getElementById('chapter-images');
        if (!el || typeof htmx === 'undefined') return;
        const segments = location.pathname.split('/').filter(Boolean);
        const chapterId = segments[segments.length - 1];
        if (!chapterId) return;
        const url = location.origin + '/chapters/' + chapterId +
          '/images?is_prev=False&current_page=1&reading_style=long_strip';
        htmx.ajax('GET', url, {
          target: el,
          swap: 'outerHTML',
          values: { reading_style: 'long_strip' },
        });
      })();
      ''',
      // Allow the ajax to resolve and inject the <img>s before getHtml().
      'setTimeout(function(){}, 2500);',
    ];
  }
}
```

The chapter id is derived from `location.pathname` (the last segment), so no placeholder is needed and the script is deterministic.

- [ ] **Step 4: Verify the chapter-id derivation is robust**

The chapter page URL is `https://weebcentral.com/chapters/{id}`. Confirm `location.pathname` ends with the bare chapter id (`/chapters/01KZECDZH06AWDQEJZAAQA9C2P`, no trailing slug — unlike `/series/{id}/{slug}`). If a future URL shape appends a slug, fall back to reading the absolute images URL embedded in the page's Alpine `singlePageNavigation` init (`htmx.ajax('GET', "…/images?…")`). No code change required today.

- [ ] **Step 5: Implement tags**

Replace `_ListTagSourceExternalUseCase`:

```dart
class _ListTagSourceExternalUseCase implements ListTagSourceExternalUseCase {
  final String _baseUrl;

  const _ListTagSourceExternalUseCase(this._baseUrl);

  @override
  Duration? get timeout => Duration(seconds: 15);

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    final labels = root
        .querySelectorAll('label.fieldset-label input[name="included_tags"]')
        .map((input) => input.parent?.querySelector('span.ml-2')?.text.trim())
        .where((e) => e != null && e.isNotEmpty)
        .toSet();

    return [
      for (final name in labels)
        TagScrapped(id: name, name: name),
    ];
  }

  @override
  // TODO: implement scripts
  List<String> get scripts => [];
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `cd module/domain/domain_manga && flutter test test/weeb_central_source_external_test.dart`
Expected: PASS (all tests).

- [ ] **Step 7: Commit**

```bash
git add module/domain/domain_manga/lib/src/sources/weeb_central_source_external.dart module/domain/domain_manga/test/weeb_central_source_external_test.dart
git commit -m "feat(domain_manga): weebcentral chapter images + tags"
```

---

### Task 4: Register source + repo-wide checks

**Files:**
- Modify: `module/domain/domain_manga/lib/src/sources/sources.dart`

**Interfaces:**
- Consumes: `WeebCentralSourceExternal` from `weeb_central_source_external.dart`.
- Produces: `Sources.values` including WeebCentral.

- [ ] **Step 1: Add the source to the registry**

In `sources.dart`, add the import and append to `values`:

```dart
import 'weeb_central_source_external.dart';
// ...
  static List<SourceExternal> values = [
    MangaDexSourceExternal(),
    AsuraScanSourceExternal(),
    MangaClashSourceExternal(),
    WeebCentralSourceExternal(),
  ];
```

- [ ] **Step 2: Verify the full domain_manga test suite**

Run: `cd module/domain/domain_manga && flutter test`
Expected: PASS (including the new weebcentral tests).

- [ ] **Step 3: Verify the analyzer is clean**

Run: `cd module/domain/domain_manga && flutter analyze`
Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add module/domain/domain_manga/lib/src/sources/sources.dart
git commit -m "feat(domain_manga): register weebcentral source"
```

---

## Self-Review Notes

- **Spec coverage:** all five use cases map to tasks 1–3; registration in Task 4; out-of-scope items (no contract changes, no cache changes) honored.
- **Chapter-image script risk:** the script derives the chapter id from `location.pathname` (last segment of `/chapters/{id}`) — no placeholder. Task 3 Step 4 documents the fallback to reading the embedded Alpine images URL if the URL shape ever changes.
- **Type consistency:** `WeebCentralSourceExternal`, `_SearchMangaSourceExternalUseCase`, `_ListTagSourceExternalUseCase(baseUrl)`, `_ListChapterSourceExternalUseCase(baseUrl)` names match across tasks.
