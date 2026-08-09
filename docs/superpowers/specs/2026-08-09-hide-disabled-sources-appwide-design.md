# Hide Disabled Sources App-Wide

**Date:** 2026-08-09
**Status:** Approved design
**Scope:** `domain_manga`, `ui_browse`, `ui_updates`

## Problem

`GlobalOptionsManager` keeps a persisted list of *enabled* sources (the Browse-screen
checkboxes). Today that list only controls **entry points**: search tabs and the
Browse source list render only enabled sources. But a source that was enabled, used,
then disabled still leaks its content through every read surface:

- **Library** — `LibraryMangaScreenCubit` seeds `sources: Sources.values` (all sources,
  ignoring the enabled list) and `filteredMangas` filters only by title. All library
  manga from a now-disabled source remain visible.
- **Updates / History** — `LibraryManager` / `HistoryManager` stream unfiltered Drift
  rows; the cubits have no source awareness, so disabled-source manga/chapters still
  appear.
- **Deep links / direct fetches** — route params carry a `source` name string and
  screens resolve it via `Sources.fromName(name)`, which resolves *any* source with no
  enablement check. `SearchMangaUseCase` / `SearchChapterUseCase` / `GetMangaUseCase` /
  `GetChapterUseCase` all fetch from a disabled source (detail, similar-manga, chapters,
  reader images) when reached directly.

Goal: "hidden" means **disabled sources — and their saved content — are hidden across
the whole app**.

## Decisions (confirmed with user)

1. **Enabled list = visible.** Disabled (unticked) sources are hidden. No separate hide
   mechanism; no new UI concept.
2. **Hide everywhere, incl. saved.** A disabled source's manga/chapters/tags are hidden
   from Library, Updates, History, Search, Browse.
3. **Keep rows, filter at read.** Rows stay in Drift; every read surface filters by the
   enabled set. Re-enabling a source restores everything instantly. No data deletion.
4. **Discovery-only enforcement.** Deep links directly into a disabled source's detail or
   reader page are NOT blocked — they keep working. Only discovery surfaces hide the
   content. (This matches "keep rows, filter at read" and keeps the diff small.)
5. **Search empty state.** When the search screen has zero enabled sources, show an
   in-place empty state ("No sources enabled") with a button to open the source list
   (Browse). No auto-pop; no blank tab bar.

## Architecture

Single source of truth: `GlobalOptionsManager`'s `_sources` subject (persisted, exposed
as `sourceStateStream` via `ListenSourcesUseCase`). Every read surface filters against
the enabled source names derived from it.

```
                   ┌─────────────────────────────────────┐
                   │ GlobalOptionsManager._sources       │  ← persisted enabled list
                   │ (ListenSourcesUseCase.sourceState)  │
                   └─────────────────────────────────────┘
                          │  inject into managers
          ┌───────────────┴───────────────────────────┐
          ▼                                            ▼
   LibraryManager.filtered            HistoryManager.filtered
   (libraryStateStream)               (read/unreadHistoryStream)
          │                                            │
          ▼                                            ▼
   Library screen                     Updates / History screens
   (already renders state.sources)    (cubits already reactive)
```

- Search tabs and Browse source list **already** render only `state.sources` — no change
  needed there beyond the empty state.
- Domain fetch use cases are **unchanged**: `Sources.fromName` keeps resolving any name
  (deep-link fetches stay functional per decision 4).

## Changes

### `module/domain/domain_manga/lib/src/manager/library_manager.dart`
- Constructor gains `ListenSourcesUseCase listenSourcesUseCase`.
- `_stateSubject`: combine the raw library stream with the enabled-source-names stream;
  filter out rows whose `manga.source` is not in the enabled set.
- `libraryMangaIds` derives from the filtered stream (already does via `_stateSubject`).

### `module/domain/domain_manga/lib/src/manager/history_manager.dart`
- Constructor gains `ListenSourcesUseCase listenSourcesUseCase`.
- Both `readHistoryStream` and `unreadHistoryStream` filter `MangaChapter`s whose
  `manga?.source` is not in the enabled set.

### `module/domain/domain_manga/lib/src/domain_manga_registrar.dart`
- Pass `listenSourcesUseCase: locator()` into `LibraryManager` and `HistoryManager`.

### `module/ui/ui_browse/lib/src/library_manga_screen/library_manga_screen_cubit.dart`
- Fix the `Sources.values` seed: initial `sources` comes from
  `listenSourcesUseCase.sourceStateStream.valueOrNull` (or add a subscription). Rows
  already filtered upstream, so `filteredMangas` is unchanged.

### `module/ui/ui_browse/lib/src/search_manga_screen/search_manga_screen.dart`
- When `state.sources.isEmpty`, render the empty state instead of the tab bar:
  message + button that invokes a new `onTapBrowseSources` callback (wired in
  `BrowseRouteBuilder` to `context.push(BrowseRoutePath.browse)`).

### `module/feature/feature_browse/lib/src/route_builder.dart`
- Pass `onTapBrowseSources` into `SearchMangaScreen.create`.

## Data flow

1. User unticks a source on Browse → `GlobalOptionsManager.updateSources` persists and
   emits the new enabled list.
2. `LibraryManager` / `HistoryManager` streams re-emit with that source's rows filtered
   out. `libraryMangaIds` / prefetch state update automatically.
3. Library, Updates, History re-render without the disabled source's content.
4. Search tabs / Browse source list re-render (already reactive) without the source.
5. Nothing is deleted; re-ticking restores everything instantly.
6. Deep links to a disabled source's detail/reader still work (unchanged domain path).

## Error handling

- No new user-facing errors. Disabled-source content simply does not appear.
- Filtering is name-based (`manga.source` string vs enabled source names); a row whose
  source name no longer maps to any `SourceExternal` is treated as disabled (filtered).

## Testing

- **`LibraryManager`**: unit test — enabled list excludes a source → its manga filtered
  from `libraryStateStream` / `libraryMangaIds`.
- **`HistoryManager`**: unit test — read/unread streams filter disabled-source rows.
- **`SearchMangaScreen`**: widget test — empty enabled set → empty state shown, button
  callback fired.
- Existing search/browse source-list tests continue to pass (tabs already source-aware).

## Out of scope

- Blocking deep-link fetches (decision 4) — intentionally left open.
- Any UI change to the Browse source checkboxes.
- Deleting DB rows on disable (decision 3).
- `core_auth` (orphaned module — unrelated).
