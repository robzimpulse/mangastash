# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> This file is the canonical AI context for the repo. `AGENTS.md` is a symlink to it — edit only `CLAUDE.md`.

## 1. Commands

All commands are Melos-scoped and run from the repo root (FVM-managed Flutter, see `.fvmrc`).

| Task | Command |
|------|---------|
| Bootstrap workspace (link all packages) | `melos run refresh` (or `melos bootstrap`) |
| Install deps after pubspec changes | `melos run get` |
| Codegen (Drift, JsonSerializable, build_runner) | `melos run generate` |
| Drift migration generation | `melos run generate:migration` |
| Lint / analyze all packages | `melos run analyze` |
| Run all tests (all packages) | `melos run test` |
| Run a single test | `fvm flutter test test/<file>_test.dart` (from the module dir) |
| Run the app | `fvm flutter run` |
| Merged coverage report (lcov + cobertura) | `melos run coverage:merged` (open with `coverage:merged:open`) |

Notes:
- Run `melos run generate` after modifying any table, model, or API interface to refresh `*.g.dart` files. `*.g.dart` is excluded from analysis in `analysis_options.yaml`.
- After adding a new module or changing a package's deps, run `melos run refresh` — it cleans, bootstraps, and re-links the whole workspace.
- Lint rules enforced globally via `analysis_options.yaml`: strict trailing commas (`require_trailing_commas`), relative imports within a package (`prefer_relative_imports`), single quotes, grouped/sorted imports (`directives_ordering`), and mandatory declared return types (`always_declare_return_types`).

## 2. Tech Stack & Environment
- **Framework**: Flutter (version managed by FVM in `.fvmrc`)
- **Language**: Dart (SDK specified in `pubspec.yaml`)
- **Monorepo Management**: [Melos](https://melos.invertase.dev/) for package orchestration.
- **State Management**: BLoC/Cubit via internal `safe_bloc` module. Uses `SafeCubit` to prevent emits after closure and `AutoSubscriptionMixin` for stream management.
- **Dependency Injection**: Custom `Registrar` pattern built on top of `GetIt` (abstracted in `service_locator` module).
- **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite) for local persistence in `manga_service_drift`. Uses cross-platform `Executor` for Web/IO support.
- **Networking**: [Dio](https://pub.dev/packages/dio) for API requests in `core_network`.
- **Routing**: [go_router](https://pub.dev/packages/go_router) in `core_route`.
- **Linting**: Rules enforced via `analysis_options.yaml` (see §1).

## 3. Architecture & Directory Structure
The project follows a **Modular Clean Architecture** pattern with a sharded directory structure in `module/`:
- **root (`/`)**: Main entry point (`lib/main.dart`) where `WrapperScreen` handles global service registration.
- **`module/entity/`**: Pure data models and value objects (`entity_manga`) plus scraped-source DTOs (`entity_manga_external`).
- **`module/domain/`**: Business logic, use cases, and repository interfaces (`domain_manga`).
- **`module/core/`**: Infrastructure and cross-cutting concerns (Auth, Route, Network, Storage, Analytics, Environment). `core_storage` wires the database, DAOs, and caches.
- **`module/library/`**: Internal utility libraries and 3rd-party wrappers (Drift service, Service Locator, BLoC, MangaDex API, Firebase).
- **`module/ui/`**: Reusable UI components, themes, and shared widgets (`ui_common`). Feature-specific UI modules (e.g., `ui_browse`) contain both Screens and their colocated Cubits.
- **`module/feature/`**: High-level feature orchestration and routing. Bridges UI with Domain and Core; the only layer that knows navigation.

**Big-picture wiring to understand before editing:**
- **Bootstrap order is load-bearing.** `lib/main.dart` → `WrapperScreen` → `locatorBuilder()` runs `locator.reset()`, registers registrars sequentially (CoreAnalytics first, then CoreStorage, CoreNetwork, CoreEnvironment, CoreRoute, DomainManga), then awaits `locator.allReady()`. Circular dependencies between registrars cause startup failures.
- **Registrar/Initiator pattern**: every module exposes a `Registrar` (library modules use the `Initiator` alias) that registers its services into the shared `ServiceLocator` (GetIt-backed). Interfaces are registered via `alias<Interface, Manager>()` — e.g. `PathManager` implements `GetRootPathUseCase`/`GetBackupPathUseCase`/`GetDownloadPathUseCase`.
- **Data flow**: `core_network` (Dio + headless WebView scraping) and `manga_dex_api` (MangaDex REST) feed `domain_manga` use cases, which sync into Drift DAOs (`manga_service_drift` via `core_storage`) and cache managers. UI modules consume use cases via `locator()`, never services directly.
- **Scraping sources**: `SourceExternal` (in `entity_manga_external`) defines a plugin contract for non-MangaDex sources (e.g. AsuraScan). Mangadex is `builtIn` and goes through `manga_dex_api`; its source use-case getters `throw UnimplementedError()`.
- **UI convention**: `ui_*` screens are pure widgets that take `onTapX`/`onTapY` callbacks and a static `create(locator:, ...)` factory; `feature_*` route builders supply navigation via `BaseRouteBuilder` (`root()`, `routes()`, aggregated in `lib/main_route.dart`).
- **Gotcha — orphaned auth module**: `CoreAuthRegistrar` is *not* registered in `lib/main.dart` (there is a `// TODO: register module registrar here` at `lib/main.dart:37`). Auth screens/use cases exist in `core_auth` but nothing wires them into the running app.
- **Gotcha — download is unimplemented**: the "Download" action is a no-op TODO across `ui_browse` and `ui_more`.
- **Web vs IO**: conditional imports select platform implementations (e.g. `PathManager` filesystem adapter — in-memory temp dir on web, app-documents dir on IO; `Executor` in `manga_service_drift`). When DB or path errors appear only on one platform, check the `adapter/` directories.

## 4. Implementation Rules
- **Consistency**: Match existing style and patterns.
- **Code Style**: Single quotes for strings, mandatory trailing commas.
- **Imports**: Grouped (Dart, Package, Relative) and sorted alphabetically. Use relative imports within the same package.
- **Type Safety**: Always declare return types for functions and methods.
- **DI Registration**: Every module MUST provide a Registrar (or Initiator) that registers its services into the ServiceLocator.
- **Generated Code**: Run `melos run generate` after modifying models, tables, or API interfaces to update `.g.dart` files.
- **Result Wrappers**: Network operations (especially in `core_network`) should return a `Result` type (`Success`/`Error`) for explicit error handling.
- **Path Abstraction**: Avoid direct file system access; use `PathManager` or dedicated use cases in `core_storage`.
- **Naming Conventions**: Models in `entity_manga_external` should be suffixed with `Scrapped` to distinguish them from official API entities.
- **Action Delegation**: UI components should delegate navigation and high-level actions via callbacks to remain agnostic of the routing table.
- **Safe BLoC**: Cubits should extend `safe_bloc`'s `Cubit` (swallows emits after close) and mix in `AutoSubscriptionMixin` (cancels tracked subscriptions before `close()`) for any external stream subscription.

## 5. Testing Conventions
- **Framework**: Standard `flutter_test`.
- **Mocks**: Use `mocktail` for behavior-driven testing.
- **E2E**: Use `patrol` for integration and finders.
- **Commands**:
    - `melos run test`: Runs all tests across all modules.
    - `melos run coverage:merged`: Generates a unified code coverage report using `lcov` and `cobertura`.
- **Test harness**: `test/extension/patrol_tester_extension.dart` provides `testScreen(...)` — sets up a GetIt locator (allowing reassignment), in-memory DB executor, mocked caches, and registers the same registrars as `main.dart`. Note it also does not register `CoreAuthRegistrar`.

## 6. Known Blockers & Troubleshooting (Self-Learning)
> **⚠️ DIRECTIVE FOR ALL FUTURE AI AGENTS:** If you encounter a new architectural blocker, undocumented workaround, or persistent bug while working in this codebase, you MUST append it to this section with troubleshooting steps before completing your task.

- **Monorepo Dependency Synchronization**
  - **Location**: Project Root / `pubspec.yaml`
  - **Context**: Updating a package's dependencies or adding a new module requires a workspace-wide refresh to link everything correctly.
  - **Troubleshooting**: Run `melos run refresh` (or `melos bootstrap`) to synchronize `pubspec.lock` files and path references.

- **Drift DAO & Code Generation**
  - **Location**: `module/library/manga_service_drift/`
  - **Context**: The database uses many DAOs and split table definitions. Code generation is required for `part 'filename.g.dart';`.
  - **Troubleshooting**: If you change a table or add a DAO, run `melos run generate`. If migrations are needed, use `melos run generate:migration`.

- **Registrar Initialization Order**
  - **Location**: `lib/main.dart`
  - **Context**: Modules are registered in a specific order within `WrapperScreen`. Circular dependencies between registrars will cause app startup failures.
  - **Troubleshooting**: Check the `WrapperScreen` locator builder in `main.dart` if services are not found or injection fails.

- **Merged Coverage Script Complexity**
  - **Location**: `melos.yaml` (`coverage:merged`)
  - **Context**: The merged coverage script uses complex `sed` commands and `lcov` to unify reports across modules.
  - **Troubleshooting**: Ensure `lcov` and `cobertura` tools are installed on the system if this script fails.

- **Database Cross-Platform Implementation**
  - **Location**: `module/library/manga_service_drift/lib/src/database/executor.dart`
  - **Context**: Uses conditional imports (`adapter/filesystem` and `adapter/query_executor`) to handle Web and IO differences.
  - **Troubleshooting**: If database errors occur on specific platforms, check the corresponding adapter files in the `adapter/` directory.

- **UI-Logic Coupling in UI Modules**
  - **Location**: `module/ui/` (e.g., `ui_browse/lib/src/browse_manga_screen/`)
  - **Context**: Screens and their business logic (Cubits) are often colocated in the same UI module rather than separate feature modules.
  - **Troubleshooting**: When looking for logic related to a specific screen, check the same directory as the screen widget for `*_cubit.dart` and `*_state.dart` files.

- **External Source Reader Selectors Drift with Site Redesigns**
  - **Location**: `module/domain/domain_manga/lib/src/sources/` (e.g. `asura_scan_source_external.dart`)
  - **Context**: AsuraScans (and other scraped sources) rebuilt their site on Astro; the chapter reader DOM changed from `div.relative.w-full > img.w-full.block.relative.z-10` to `<div data-page="n" class="w-full"><img data-page-index="n" class="w-full block">`. The old hardcoded Tailwind-class chain matched **0** images, so the reader silently showed no/incomplete pages while the web version showed all.
  - **Troubleshooting**: Symptom "app reader has fewer/missing images than the site" → the source's `getChapterImageUseCase` selector is stale. Fetch a live chapter page (`curl -A '<mobile UA>' https://asurascans.com/comics/<slug>/chapter/<n>`), inspect the reader `<img>` attributes, and update `parse`/`scripts`. Prefer stable attributes (`data-page-index`, `data-page`) over Tailwind classes — they survive redesigns. The reader also relies on the injected scroll script (`scrollIntoView`) to trigger lazy `src` population before `getHtml()` snapshots; keep that timing in sync with the container it queries.

- **Empty-Query Browse URLs Render Empty Pages in the App Webview**
  - **Location**: `module/domain/domain_manga/lib/src/sources/` (e.g. `mangakatana_source_external.dart`, `manhua_plus_source_external.dart`)
  - **Context**: Scraped sources' `searchMangaUseCase.url()` built the site's *search* URL with the empty browse query. Manga Katana `?search=&search_by=m_name` renders "Not found any results" in `#book_list`, and its <768px inline JS empties the `#hot_book` sidebar widget (repopulated only from `#hot_update`, which exists solely on the homepage), leaving **0** `div.item[data-id]` cards in the post-JS DOM. Manhua Plus `?s=` renders WordPress's "You searched for" page with **0** cards. Curl-only checks are misleading because the raw HTML still contains sidebar widgets that the app's rendered DOM drops.
  - **Troubleshooting**: Symptom "browse shows no cards but search works" → check `searchMangaUseCase.url()` for empty-title handling; browse must hit a real listing (homepage/archive), not the search route. Verify with a JS-enabled render (e.g. headless Chrome `--dump-dom` with the app webview UA) rather than curl alone, because the headless webview snapshots the post-JS DOM.

- **Cloudflare JS Challenge Blocks Browse for Some Scraped Sources**
  - **Location**: `module/core/core_network/lib/src/manager/headless_webview_manager.dart` + `module/domain/domain_manga/lib/src/sources/`
  - **Context**: Some sites (e.g. Toonily) put their homepage and any `/?s=` search behind a Cloudflare "Just a moment…" JavaScript challenge. Detail pages pass, but browse/search are unusable: the webview aborts when `getTitle()` == `'Just a moment...'` (`headless_webview_manager.dart:385`). No User-Agent tweak passes it; `curl` sees the challenge for search but not detail. Toonily was removed as a source (2026-08-11).
  - **Troubleshooting**: Before adding a scraped source, curl its homepage + a search URL with the app's webview UA (`Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) … Chrome/127 Safari/537.36` — see `user_agent_mixin.dart`). If you see `<title>Just a moment...</title>`, the source cannot browse; remove it or find a non-challenged listing endpoint (some sites only challenge search, not genre/archive pages).

- **Next.js/SSG Sites Parse from `__NEXT_DATA__` JSON, Not the DOM**
  - **Location**: `module/domain/domain_manga/lib/src/sources/flame_comics_source_external.dart`
  - **Context**: Flame Comics migrated from Madara WordPress to a Next.js/Mantine SPA (2026-08). All Madara selectors (`div.item__wrap`, `div.reading-content`, `li.wp-manga-chapter`, `div.post-content_item`) disappeared. Content is server-rendered into a `<script id="__NEXT_DATA__">` JSON blob (SSG): browse/search → `props.pageProps.series[]`, detail → `props.pageProps.series` + `pageProps.chapters[]`, reader → `props.pageProps.chapter.images` (dict `"0" → {name, …}`), covers → `https://cdn.flamecomics.xyz/uploads/images/series/{series_id}/{cover}?t={last_edit}`.
  - **Troubleshooting**: For any source whose markup is a Next.js SPA, fetch the page and parse `#__NEXT_DATA__` JSON instead of the DOM — it's stable and complete, and needs **no injected scripts**. Two gotchas: (1) the `html` package does NOT decode HTML entities inside `<script>` text — titles with apostrophes arrive raw (`The Novel's Extra`, not `&#x27;`); (2) when the site's search is client-side only (Fuse.js over the full SSG list), there is no server endpoint — filter the embedded series array in Dart using the `searchTerm` threaded through `SearchMangaSourceExternalUseCase.parse` (add the optional param to the interface + caller).

- **Bumping a Constraint That Intersects a Git-Pinned Dep Requires a Lockfile Commit**
  - **Location**: all committed `pubspec.lock` files (17 at root + every module except `ui_updates` and `feature_common`, whose `.gitignore` excludes their lockfiles)
  - **Context**: `core_analytics` (and several modules) depend on `log_box_*` packages via git with `ref: master`. `flutter pub get` (what `melos get` runs) **reuses the `resolved-ref` pinned in pubspec.lock and never floats a git dep to the branch tip** — only `pub upgrade <pkg>` does. So when commit 18e6558d bumped `rxdart` to `^0.28.0` in pubspec.yamls without regenerating lockfiles, CI's `melos get` kept resolving log_box at the pinned commit `550868b` (still `rxdart ^0.27.7`) and version solving failed with "every version of X from path depends on log_box_dio_logger from git which depends on rxdart ^0.27.7" — even though log_box master already had `^0.28.0`. The resolver's error message tells you which commit it looked at: if it names `^0.27.7`, it read the pin, not the tip.
  - **Troubleshooting**: After changing any constraint that touches a git-pinned dependency, run `flutter pub upgrade log_box log_box_navigation_logger log_box_dio_logger log_box_in_app_webview_logger log_box_persistent_storage_drift` at root and in every module whose lockfile pins the old ref (or full `melos run upgrade`), verify no lockfile still contains the stale `resolved-ref`, then **commit the updated lockfiles together with the pubspec.yaml bump**. `melos run get` alone cannot fix it.

- **Widget Tests Against ScaffoldScreen Cannot Use pumpAndSettle — and a Single Long pump Is Not Enough**
  - **Location**: `module/ui/ui_common/lib/src/scaffold_screen.dart` (ShimmerAreaWidget) + any `ui_*` screen test
  - **Context**: `ScaffoldScreen` embeds an infinitely-animating shimmer, so `WidgetTester.pumpAndSettle` always times out. Replacing it with one long `pump(Duration)` is also wrong: `pump` advances the fake clock and paints a single frame, and `ExpansionTile`/`AnimatedCrossFade` schedule their post-completion rebuild for the *next* frame — the tree is left mid-transition with both layers stacked, and taps then hit the wrong render object ("tap() with finder ... would not hit test"). First observed in the data_storage_screen widget tests (2026-09).
  - **Troubleshooting**: Use a loop helper (e.g. `pumpFrames` = several `pump(200ms)` iterations) after every interaction (tile expansion, popup menu, snackbar). See `module/ui/ui_more/test/src/data_storage_screen/data_storage_screen_test.dart`.

- **drift_flutter Typing and path_provider Quirks in IO Adapters and VM Tests**
  - **Location**: `module/library/manga_service_drift/lib/src/database/adapter/query_executor/` + tests under `test/database/`
  - **Context**: drift_flutter 0.2.x deliberately types `DriftNativeOptions.databaseDirectory` as `Future<Object> Function()` so the same options class compiles for web — on IO adapters you must cast the resolved value to `dart:io` `Directory` (drift uses dart:io's Directory, NOT package:file's). Additionally `driftDatabase` resolves sqlite3's temp dir via path_provider (`getTemporaryDirectory`) unless `tempDirectoryPath` is supplied, and defaults to `shareAcrossIsolates` — both break plain `flutter_test` VM runs with "Binding has not yet been initialized" or MissingPluginException.
  - **Troubleshooting**: In tests that exercise `queryExecutor`/`driftDatabase` directly, pass `DriftNativeOptions(databaseDirectory: () async => Directory(tmp), tempDirectoryPath: () async => tmp, shareAcrossIsolates: false)`. In adapter code, cast `await ioOptions.databaseDirectory?.call() as Directory?`.

- **macOS Debug Build Blocked by Pod Deployment Targets (pre-existing on master)**
  - **Location**: `macos/Pods` — `flutter_inappwebview_macos 1.1.2`
  - **Context**: `flutter run -d macos` fails to compile: `WebAuthenticationSession.swift:85: protocol 'ASWebAuthenticationPresentationContextProviding' requires 'presentationAnchor(for:)' to be available in macOS 10.14 and newer`, while `abseil`/`BoringSSL-GRPC` pod targets pin `MACOSX_DEPLOYMENT_TARGET` 10.11/10.12. Confirmed 2026-09 while verifying the backup/restore fix; unrelated to any Dart change.
  - **Troubleshooting**: Raise the pod deployment targets to ≥ 10.14 in `macos/Podfile`'s `post_install` hook (or bump `flutter_inappwebview`) to unblock desktop builds. Until then, desktop verification is impossible locally — rely on tests, or run the web build in Chrome.

- **CustomCacheStore Is a Fork of Upstream CacheStore — File Deletion Is Gated**
  - **Location**: `module/core/core_storage/lib/src/manager/custom_cache_manager/custom_cache_store.dart`
  - **Context**: `CustomCacheStore` forks flutter_cache_manager's `CacheStore`. Upstream deletes evicted files inline in `_removeCachedFile`; this fork gates that behind `deleteFileOnEviction` (default `true`). `ImagesCacheManager` is the sole opt-out (`false`): `JobManager` "rescues" its evicted files via `deleteFileEvent` → `persistentImage` job → `FileDao.addFromFile` copy → delete. `deleteFileEvent` therefore fires **only** in rescue mode (issue #103: rows were deleted but files leaked forever for every non-images cache). `_cleanupCache`/`emptyCache` await file deletions **before** `provider.deleteAll` (deliberate divergence from upstream) so a crash cannot orphan files with no index rows.
  - **Troubleshooting**: If a cache leaks files on eviction, check the manager wasn't constructed with `deleteFileOnEviction: false`. New `CustomCacheManager` subclasses must not pass the flag unless a `deleteFileEvent` listener rescues the files. If eviction tests hang, remember `_scheduleCleanup` arms a real timer — drive it with `fakeAsync` + `flushTimers` and `cleanupRunMinInterval = Duration.zero`. Also note the `DeletedFileData` record type is `(CacheObject object, File file)` — those names are doc-only; access fields positionally (`final (object, file) = event;`), and mocktail needs `registerFallbackValue` for `Duration` and `CacheObject` when stubbing with `any()`.
