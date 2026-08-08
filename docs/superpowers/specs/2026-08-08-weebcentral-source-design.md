# WeebCentral Source — Design

Date: 2026-08-08
Status: Approved (pending spec review)

## Goal

Add `weebcentral.com` as a new external manga source in `mangastash`, implementing all five `SourceExternal` use cases at parity with the existing Asura Scans and Manga Clash sources.

## Context

- Contract: `module/library/entity_manga_external/lib/src/source_external.dart` defines `SourceExternal` (source identity + five use cases) and the five abstract use-case interfaces. All parsing is over an `html.Document`; optional `scripts` run in a headless webview before `parse()`.
- Existing sources: `module/domain/domain_manga/lib/src/sources/` — `manga_dex_source_external.dart` (builtIn, API-backed), `asura_scan_source_external.dart` and `manga_clash_source_external.dart` (scraping, `builtIn: false`). New sources are added to `Sources.values` in `sources.dart`.
- WeebCentral is server-rendered HTML driven by htmx + Alpine. All content endpoints return parseable HTML with no Cloudflare JS challenge. The one dynamic part is the chapter reader, which loads images via an in-page Alpine `htmx.ajax` call.

## Verified WeebCentral endpoints

| Purpose | URL | Notes |
|---|---|---|
| Search data | `/search/data?text={title}&limit={n}&offset={n}&display_mode=Full+Display` | htmx fragment. One `<article class="bg-base-300 flex gap-4 p-4">` per result. Pagination via `hx-get="/search/data?...offset=..."` "View More Results…" button. |
| Series detail | `/series/{id}/{slug}` | Full details + chapter list server-rendered. |
| Chapter reader | `/chapters/{id}` | Alpine shell; no `<img>` in initial HTML. |
| Chapter images | `/chapters/{id}/images?is_prev=False&current_page=1&reading_style=long_strip` | Returns `<section id="chapter-images">` containing ordered `<img src="https://temp.compsci88.com/...">` per page. Fetched in-page by the reader's Alpine `singlePageNavigation`. |

## Scope

All five use cases:

1. `searchMangaUseCase`
2. `getMangaUseCase`
3. `listChapterUseCase`
4. `getChapterImageUseCase`
5. `listTagUseCase`

## Design

Single new file: `module/domain/domain_manga/lib/src/sources/weeb_central_source_external.dart`, mirroring the Asura source's structure (one public `WeebCentralSourceExternal` + private use-case classes). Registered in `sources.dart` `Sources.values`.

### `WeebCentralSourceExternal extends SourceExternal`

- `name` → `'Weeb Central'`
- `baseUrl` → `'https://weebcentral.com'`
- `iconUrl` → `'$baseUrl/favicon.ico'`
- `builtIn` → `false`
- Returns the five private use-case instances.

### Search (`_SearchMangaSourceExternalUseCase`)

- `timeout`: `Duration(seconds: 15)`; `scripts`: `[]`.
- `url(parameter)` → `'$baseUrl/search/data'` with query params, best-effort mapping of `SearchMangaParameter`:
  - `text` = `parameter.title`
  - `limit` = `parameter.limit` (default 32)
  - `offset` = `(parameter.page - 1) * parameter.limit`
  - `sort`: from `parameter.orders` → `Best Match` | `Alphabet` | `Popularity` | `Subscribers` | `Recently Added` | `Latest Updates`
  - `order`: `Ascending` | `Descending`
  - `included_status`: from `parameter.status` → `Ongoing` | `Complete` | `Hiatus` | `Canceled`
  - `included_tags`: `parameter.includedTags`, repeated per tag
  - `display_mode` = `Full Display`
- `parse(root)` → for each `<article class="bg-base-300 flex gap-4 p-4">`:
  - `title` from the result heading text
  - `coverUrl` from the `temp.compsci88.com` cover `<img src>`
  - `webUrl` = series link `href` (`/series/{id}/{slug}`)
  - `status`, `author`, `tags` from the result metadata rows
- `haveNextPage(root)` → `true` if a "View More Results…" button with `hx-get="/search/data?...offset=..."` is present.

### Series detail (`_GetMangaSourceExternalUseCase`)

- `timeout`: `Duration(seconds: 15)`; `scripts`: `[]`.
- Page: `/series/{id}/{slug}`.
- `parse(root)` → `MangaScrapped`:
  - `title` from the detail heading
  - `coverUrl` from the cover `img`
  - `author` from the `Author(s):` row
  - `tags` from the `Tags(s):` row
  - `status` from the `Status:` row
  - `webUrl` = the opened page URL

### Chapter list (`_ListChapterSourceExternalUseCase`)

- `timeout`: `Duration(seconds: 15)`; `scripts`: `[]`.
- Page: `/series/{id}/{slug}`.
- `parse(root)` → rows in `#chapter-list`:
  - `title` from the row text (e.g. `Chapter 1190`)
  - `chapter` = trailing whitespace-delimited token of the row text (e.g. `Chapter 1190` → `1190`)
  - `webUrl` = `'$baseUrl/chapters/{chapterId}'`
  - `readableAt`/`publishAt` from the row's `checkNewChapter('{ISO}')` timestamp when present

### Chapter images (`_GetChapterImageSourceExternalUseCase`)

- `timeout`: `Duration(seconds: 30)`.
- Page: `/chapters/{id}`.
- `scripts`: runs the reader's own `htmx.ajax('GET', '/chapters/{id}/images?is_prev=False&current_page=1&reading_style=long_strip')` into `#chapter-images` so the page images land in the DOM (same fetch the Alpine `singlePageNavigation` init performs; `reading_style=long_strip` injects all images).
- Fallback if the webview does not fire the Alpine init: the `scripts` may itself call `fetch('/chapters/{id}/images?…')` and inject the returned HTML into `#chapter-images`, then `parse()` reads the injected `<img>`s. Verify during implementation which path executes; both end with `parse()` reading `section#chapter-images img[src]`.
- `parse(root)` → `section#chapter-images img[src]` ordered, skipping `broken_image.jpg`, returning the `temp.compsci88.com` URLs.

### Tags (`_ListTagSourceExternalUseCase`)

- `timeout`: `Duration(seconds: 15)`.
- Page: `$baseUrl/search`.
- `scripts`: toggles the search page's Alpine `show_filter` state so the filter panel (which renders the genre list) is present in the DOM.
- `parse(root)` → `TagScrapped(id: name, name: name)` for each `included_tags` genre option (48 hardcoded genres: Action, Adult, Adventure, …, Yuri, Other).

## Error handling

Follow the existing sources' behavior — `parse()` returns empty lists / best-effort data on missing nodes (existing code uses optional-chaining and `.nonNulls`, no throwing on absent selectors). Timeouts and fetch errors are handled by the shared `HeadlessWebviewUseCase` layer.

## Testing

One runnable check verifying the source's parsing against a representative weebcentral search-data and chapter-images fixture (a small `flutter test` in `domain_manga`), consistent with the repo's `flutter_test`/`mocktail` conventions. Parser selectors are the primary regression risk; the fixtures pin them.

## Out of scope

- No changes to `SourceExternal` or the shared `SearchMangaParameter` contract.
- No Cloudflare-specific handling (site currently serves parseable HTML to a standard UA).
- No persistence/DB changes — reuse existing `sync`/cache machinery.
